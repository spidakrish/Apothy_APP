import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';
import '../entities/message.dart';

/// Abstract repository interface for chat operations
///
/// Uses `Either<Failure, T>` for error handling following functional patterns
abstract class ChatRepository {
  // ============================================================================
  // Message Operations
  // ============================================================================

  /// Sends a new message and persists it
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    required MessageSender sender,
  });

  /// Gets all messages for a conversation
  Future<Either<Failure, List<Message>>> getMessages(String conversationId);

  /// Updates a message (e.g., for streaming updates)
  Future<Either<Failure, Message>> updateMessage(Message message);

  /// Deletes a message
  Future<Either<Failure, void>> deleteMessage(String messageId);

  // ============================================================================
  // Conversation Operations
  // ============================================================================

  /// Creates a new conversation
  Future<Either<Failure, Conversation>> createConversation({
    String? title,
  });

  /// Gets all conversations
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// Gets a specific conversation
  Future<Either<Failure, Conversation?>> getConversation(String conversationId);

  /// Updates conversation metadata
  Future<Either<Failure, Conversation>> updateConversation(Conversation conversation);

  /// Deletes a conversation and all its messages
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  // ============================================================================
  // Current Conversation
  // ============================================================================

  /// Gets or creates the current active conversation
  Future<Either<Failure, Conversation>> getCurrentConversation();

  /// Sets the current active conversation
  Future<Either<Failure, void>> setCurrentConversation(String conversationId);

  /// Starts a new conversation (creates new and sets as current)
  Future<Either<Failure, Conversation>> startNewConversation();

  // ============================================================================
  // Utility Operations
  // ============================================================================

  /// Clears all chat history
  Future<Either<Failure, void>> clearAllHistory();

  /// Gets statistics about chat history
  Future<Either<Failure, ChatStats>> getStats();
}

/// Chat statistics
class ChatStats {
  const ChatStats({
    required this.totalMessages,
    required this.totalConversations,
  });

  final int totalMessages;
  final int totalConversations;
}
