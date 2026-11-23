
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/chat_message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/repositories/chat_repository.dart';

/// Provides the Firestore-backed Chat repository.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl();
});

/// Watches the signed-in user's conversations in real time.
final conversationsProvider =
    StreamProvider.autoDispose<List<ConversationModel>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchConversations();
});

/// Watches one conversation and its latest information.
final conversationProvider =
    StreamProvider.autoDispose.family<ConversationModel?, String>(
  (ref, conversationId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.watchConversation(conversationId);
  },
);

/// Watches messages within a conversation in real time.
final chatMessagesProvider =
    StreamProvider.autoDispose.family<List<ChatMessageModel>, String>(
  (ref, conversationId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.watchMessages(conversationId);
  },
);

/// Provides methods for creating conversations and sending messages.
final chatControllerProvider = Provider<ChatController>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider));
});

class ChatController {
  final ChatRepository _repository;

  ChatController(this._repository);

  /// Starts or retrieves a conversation for a listing.
  Future<String> startConversation(String listingId) {
    return _repository.getOrCreateConversation(listingId);
  }

  /// Sends a message to an existing conversation.
  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) {
    return _repository.sendMessage(
      conversationId: conversationId,
      text: text,
    );
  }
}
