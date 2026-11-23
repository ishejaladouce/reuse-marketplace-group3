
import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String listingId;
  final String listingTitle;
  final String sellerId;
  final String buyerId;
  final List<String> participantIds;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ConversationModel({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.sellerId,
    required this.buyerId,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConversationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;

    return ConversationModel(
      id: snapshot.id,
      listingId: data['listingId'] as String,
      listingTitle: data['listingTitle'] as String,
      sellerId: data['sellerId'] as String,
      buyerId: data['buyerId'] as String,
      participantIds: List<String>.from(
        data['participantIds'] ?? [],
      ),
      lastMessage: data['lastMessage'] as String? ?? '',
      lastMessageSenderId:
          data['lastMessageSenderId'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'listingId': listingId,
      'listingTitle': listingTitle,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Returns the other participant's Firebase UID.
  String otherParticipantId(String currentUserId) {
    if (currentUserId == buyerId) return sellerId;
    if (currentUserId == sellerId) return buyerId;

    throw StateError(
      'The current user is not part of this conversation.',
    );
  }

  /// Whether the current user is buying the item.
  bool isBuying(String currentUserId) {
    return buyerId == currentUserId;
  }
}
