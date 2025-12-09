import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_datasource.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Implementation of ChatRepository using local Hive storage
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.localDatasource,
  });

  final ChatLocalDatasource localDatasource;
  final _uuid = const Uuid();

  // ============================================================================
  // Message Operations
  // ============================================================================

  @override
  Future<Either<Failure, Message>> sendMessage({
    required String conversationId,
    required String content,
    required MessageSender sender,
  }) async {
    try {
      final message = MessageModel(
        id: _uuid.v4(),
        conversationId: conversationId,
        content: content,
        sender: sender == MessageSender.user
            ? MessageSenderHive.user
            : MessageSenderHive.assistant,
        createdAt: DateTime.now(),
        isStreaming: false,
      );

      await localDatasource.saveMessage(message);

      // Update conversation metadata
      final conversation = await localDatasource.getConversation(conversationId);
      if (conversation != null) {
        final updatedConversation = conversation.copyWith(
          updatedAt: DateTime.now(),
          messageCount: conversation.messageCount + 1,
          lastMessagePreview: content.length > 100
              ? '${content.substring(0, 100)}...'
              : content,
        );
        await localDatasource.updateConversation(updatedConversation);
      }

      return Right(message.toEntity());
    } catch (e) {
      return Left(ChatFailure.saveFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Message>>> getMessages(String conversationId) async {
    try {
      final models = await localDatasource.getMessages(conversationId);
      final messages = models.map((m) => m.toEntity()).toList();
      return Right(messages);
    } catch (e) {
      return Left(ChatFailure.loadFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Message>> updateMessage(Message message) async {
    try {
      final model = MessageModel.fromEntity(message);
      await localDatasource.updateMessage(model);
      return Right(message);
    } catch (e) {
      return Left(ChatFailure.saveFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMessage(String messageId) async {
    try {
      await localDatasource.deleteMessage(messageId);
      return const Right(null);
    } catch (e) {
      return Left(ChatFailure.deleteFailed(e.toString()));
    }
  }

  // ============================================================================
  // Conversation Operations
  // ============================================================================

  @override
  Future<Either<Failure, Conversation>> createConversation({
    String? title,
  }) async {
    try {
      final now = DateTime.now();
      final conversation = ConversationModel(
        id: _uuid.v4(),
        title: title ?? 'New Conversation',
        createdAt: now,
        updatedAt: now,
        messageCount: 0,
      );

      await localDatasource.saveConversation(conversation);
      return Right(conversation.toEntity());
    } catch (e) {
      return Left(ChatFailure.createConversationFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Conversation>>> getConversations() async {
    try {
      final models = await localDatasource.getConversations();
      final conversations = models.map((m) => m.toEntity()).toList();
      return Right(conversations);
    } catch (e) {
      return Left(ChatFailure.loadFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation?>> getConversation(String conversationId) async {
    try {
      final model = await localDatasource.getConversation(conversationId);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(ChatFailure.loadFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> updateConversation(Conversation conversation) async {
    try {
      final model = ConversationModel.fromEntity(conversation);
      await localDatasource.updateConversation(model);
      return Right(conversation);
    } catch (e) {
      return Left(ChatFailure.saveFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(String conversationId) async {
    try {
      await localDatasource.deleteConversation(conversationId);

      // If this was the current conversation, clear it
      final currentId = await localDatasource.getCurrentConversationId();
      if (currentId == conversationId) {
        await localDatasource.setCurrentConversationId(null);
      }

      return const Right(null);
    } catch (e) {
      return Left(ChatFailure.deleteFailed(e.toString()));
    }
  }

  // ============================================================================
  // Current Conversation
  // ============================================================================

  @override
  Future<Either<Failure, Conversation>> getCurrentConversation() async {
    try {
      final currentId = await localDatasource.getCurrentConversationId();

      if (currentId != null) {
        final existing = await localDatasource.getConversation(currentId);
        if (existing != null) {
          return Right(existing.toEntity());
        }
      }

      // No current conversation, create one
      final result = await createConversation();
      return result.fold(
        (failure) => Left(failure),
        (conversation) async {
          await localDatasource.setCurrentConversationId(conversation.id);
          return Right(conversation);
        },
      );
    } catch (e) {
      return Left(ChatFailure.loadFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setCurrentConversation(String conversationId) async {
    try {
      await localDatasource.setCurrentConversationId(conversationId);
      return const Right(null);
    } catch (e) {
      return Left(ChatFailure.saveFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Conversation>> startNewConversation() async {
    try {
      final result = await createConversation();
      return result.fold(
        (failure) => Left(failure),
        (conversation) async {
          await localDatasource.setCurrentConversationId(conversation.id);
          return Right(conversation);
        },
      );
    } catch (e) {
      return Left(ChatFailure.createConversationFailed(e.toString()));
    }
  }

  // ============================================================================
  // Utility Operations
  // ============================================================================

  @override
  Future<Either<Failure, void>> clearAllHistory() async {
    try {
      await localDatasource.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(ChatFailure.deleteFailed(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChatStats>> getStats() async {
    try {
      final totalMessages = await localDatasource.getTotalMessageCount();
      final totalConversations = await localDatasource.getConversationCount();

      return Right(ChatStats(
        totalMessages: totalMessages,
        totalConversations: totalConversations,
      ));
    } catch (e) {
      return Left(ChatFailure.loadFailed(e.toString()));
    }
  }
}
