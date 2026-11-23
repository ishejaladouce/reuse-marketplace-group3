
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/chat_repository.dart';
import '../models/conversation_model.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> get _listings =>
      _firestore.collection('listings');

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('You must be signed in to use Chat.');
    }

    return user.uid;
  }

  @override
  Future<String> getOrCreateConversation(String listingId) async {
    final buyerId = _currentUserId;

    if (listingId.trim().isEmpty) {
      throw ArgumentError('A listing ID is required.');
    }

    final listingSnapshot = await _listings.doc(listingId).get();

    if (!listingSnapshot.exists) {
      throw StateError('This listing no longer exists.');
    }

    final listing = listingSnapshot.data()!;
    final sellerId = listing['sellerId'] as String;
    final listingTitle = listing['title'] as String;

    if (buyerId == sellerId) {
      throw StateError('You cannot message yourself.');
    }

    if (listing['status'] != 'available') {
      throw StateError('This listing is no longer available.');
    }

    // A stable ID prevents duplicate conversations for the same
    // listing and buyer. The seller is determined by the listing.
    final conversationId = '${listingId}_$buyerId';
    final conversationRef = _conversations.doc(conversationId);

    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(conversationRef);

      if (existing.exists) {
        final data = existing.data()!;

        if (data['buyerId'] != buyerId ||
            data['sellerId'] != sellerId ||
            data['listingId'] != listingId) {
          throw StateError('Conversation details do not match.');
        }

        return;
      }

      final now = Timestamp.now();

      transaction.set(conversationRef, {
        'listingId': listingId,
        'listingTitle': listingTitle,
        'sellerId': sellerId,
        'buyerId': buyerId,
        'participantIds': [buyerId, sellerId],
        'lastMessage': '',
        'lastMessageSenderId': '',
        'createdAt': now,
        'updatedAt': now,
      });
    });

    return conversationId;
  }

  @override
  Stream<List<ConversationModel>> watchConversations() {
    final uid = _currentUserId;

    return _conversations
        .where('participantIds', arrayContains: uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ConversationModel.fromFirestore)
              .toList(),
        );
  }

  @override
  Stream<ConversationModel?> watchConversation(
    String conversationId,
  ) {
    final uid = _currentUserId;

    return _conversations.doc(conversationId).snapshots().map(
      (snapshot) {
        if (!snapshot.exists) return null;

        final conversation = ConversationModel.fromFirestore(
          snapshot,
        );

        if (!conversation.participantIds.contains(uid)) {
          throw StateError(
            'You are not a participant in this conversation.',
          );
        }

        return conversation;
      },
    );
  }

  @override
  Stream<List<ChatMessageModel>> watchMessages(
    String conversationId,
  ) {
    _currentUserId;

    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatMessageModel.fromFirestore(
                  doc,
                  conversationId,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final senderId = _currentUserId;
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      throw ArgumentError('A message cannot be empty.');
    }

    if (trimmedText.length > 2000) {
      throw ArgumentError(
        'Messages cannot exceed 2000 characters.',
      );
    }

    final conversationRef = _conversations.doc(conversationId);
    final messageRef = conversationRef.collection('messages').doc();

    await _firestore.runTransaction((transaction) async {
      final conversationSnapshot = await transaction.get(
        conversationRef,
      );

      if (!conversationSnapshot.exists) {
        throw StateError('Conversation not found.');
      }

      final conversation = conversationSnapshot.data()!;
      final participants = List<String>.from(
        conversation['participantIds'] ?? [],
      );

      if (!participants.contains(senderId)) {
        throw StateError(
          'You cannot send messages to this conversation.',
        );
      }

      final now = Timestamp.now();

      transaction.set(messageRef, {
        'senderId': senderId,
        'text': trimmedText,
        'createdAt': now,
      });

      transaction.update(conversationRef, {
        'lastMessage': trimmedText,
        'lastMessageSenderId': senderId,
        'updatedAt': now,
      });
    });
  }
}
