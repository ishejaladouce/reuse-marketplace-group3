
import '../../data/models/conversation_model.dart';
import '../../data/models/chat_message_model.dart';

/// Defines the operations supported by the Chat feature.
abstract class ChatRepository {
  /// Creates or retrieves a conversation for a marketplace listing.
  ///
  /// Prevents duplicate conversations between the same buyer,
  /// seller, and listing.
  Future<String> getOrCreateConversation(String listingId);

  /// Watches all conversations belonging to the current user.
  Stream<List<ConversationModel>> watchConversations();

  /// Watches a specific conversation.
  Stream<ConversationModel?> watchConversation(
    String conversationId,
  );

  /// Watches messages in a conversation in real time.
  Stream<List<ChatMessageModel>> watchMessages(
    String conversationId,
  );

  /// Sends a message to a conversation.
  Future<void> sendMessage({
    required String conversationId,
    required String text,
  });
}
