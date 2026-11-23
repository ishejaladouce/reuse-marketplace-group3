
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessageModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String conversationId,
  ) {
    final data = snapshot.data()!;

    return ChatMessageModel(
      id: snapshot.id,
      conversationId: conversationId,
      senderId: data['senderId'] as String,
      text: data['text'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Checks whether the message belongs to the current user.
  bool isMine(String currentUserId) {
    return senderId == currentUserId;
  }
}
