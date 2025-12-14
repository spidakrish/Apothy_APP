import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/ai_service.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../data/datasources/chat_local_datasource.dart';
import '../../data/datasources/chat_remote_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'ai_providers.dart';

// =============================================================================
// Datasource Providers
// =============================================================================

/// Provider for ChatLocalDatasource
final chatLocalDatasourceProvider = Provider<ChatLocalDatasource>((ref) {
  return ChatLocalDatasourceImpl();
});

/// Provider for ChatRemoteDatasource
final chatRemoteDatasourceProvider = Provider<ChatRemoteDatasource>((ref) {
  return ChatRemoteDatasourceImpl();
});

// =============================================================================
// Repository Provider
// =============================================================================

/// Provider for ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final localDatasource = ref.watch(chatLocalDatasourceProvider);
  return ChatRepositoryImpl(localDatasource: localDatasource);
});

// =============================================================================
// Chat State
// =============================================================================

/// Represents the current chat state
class ChatState {
  const ChatState({
    required this.currentConversation,
    required this.messages,
    this.isLoading = false,
    this.isSending = false,
    this.failure,
  });

  /// Initial empty state
  factory ChatState.initial() =>
      ChatState(currentConversation: Conversation.empty, messages: const []);

  /// The current active conversation
  final Conversation currentConversation;

  /// Messages in the current conversation
  final List<Message> messages;

  /// Whether initial data is loading
  final bool isLoading;

  /// Whether a message is being sent
  final bool isSending;

  /// Any failure that occurred
  final Failure? failure;

  /// Whether there's a conversation loaded
  bool get hasConversation => currentConversation.isNotEmpty;

  /// Whether there are messages
  bool get hasMessages => messages.isNotEmpty;

  /// Whether there's an error
  bool get hasError => failure != null;

  ChatState copyWith({
    Conversation? currentConversation,
    List<Message>? messages,
    bool? isLoading,
    bool? isSending,
    Failure? failure,
  }) {
    return ChatState(
      currentConversation: currentConversation ?? this.currentConversation,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      failure: failure,
    );
  }
}

// =============================================================================
// Chat Notifier
// =============================================================================

/// Notifier for managing chat state
class ChatNotifier extends AsyncNotifier<ChatState> {
  late ChatRepository _repository;
  late ChatLocalDatasource _localDatasource;

  @override
  Future<ChatState> build() async {
    _repository = ref.watch(chatRepositoryProvider);
    _localDatasource = ref.watch(chatLocalDatasourceProvider);

    // Initialize the datasource
    await _localDatasource.initialize();

    return _loadCurrentConversation();
  }

  /// Loads the current conversation and its messages
  Future<ChatState> _loadCurrentConversation() async {
    final conversationResult = await _repository.getCurrentConversation();

    return conversationResult.fold(
      (failure) {
        debugPrint(
          'ChatNotifier: error loading conversation: ${failure.message}',
        );
        return ChatState.initial().copyWith(failure: failure);
      },
      (conversation) async {
        debugPrint('ChatNotifier: loaded conversation ${conversation.id}');

        // Load messages for this conversation
        final messagesResult = await _repository.getMessages(conversation.id);

        return messagesResult.fold(
          (failure) {
            debugPrint(
              'ChatNotifier: error loading messages: ${failure.message}',
            );
            return ChatState(
              currentConversation: conversation,
              messages: const [],
              failure: failure,
            );
          },
          (messages) {
            debugPrint('ChatNotifier: loaded ${messages.length} messages');
            return ChatState(
              currentConversation: conversation,
              messages: messages,
            );
          },
        );
      },
    );
  }

  /// Sends a user message and requests AI response
  Future<void> sendMessage(String content) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    if (content.trim().isEmpty) return;

    // Set sending state
    state = AsyncValue.data(currentState.copyWith(isSending: true));

    // Send user message to local storage
    final result = await _repository.sendMessage(
      conversationId: currentState.currentConversation.id,
      content: content,
      sender: MessageSender.user,
    );

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(isSending: false, failure: failure),
        );
      },
      (message) {
        // Add message to list
        final updatedMessages = [...currentState.messages, message];
        state = AsyncValue.data(
          currentState.copyWith(
            messages: updatedMessages,
            // Keep isSending true while waiting for AI response
            isSending: true,
          ),
        );

        // Update conversation metadata
        _updateConversationMetadata(message);

        // Award XP for sending a message
        _awardXpForMessage();

        // Send to backend and handle streaming response
        _sendToBackendAndHandleResponse(content, updatedMessages);
      },
    );
  }

  /// Gets AI response for the user's message
  Future<void> _getAIResponse(
    String userMessage,
    List<Message> currentMessages,
  ) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    // Get AI service and style preference
    final aiService = ref.read(aiServiceProvider);
    final style = ref.read(aiResponseStyleProvider);

    // Convert messages to AI format
    final conversationHistory = currentMessages
        .map(
          (m) => AIMessage(
            role: m.isUser ? 'user' : 'assistant',
            content: m.content,
          ),
        )
        .toList();

    debugPrint('ChatNotifier: Requesting AI response...');

    // Request AI response
    final aiResult = await aiService.getResponse(
      conversationId: currentState.currentConversation.id,
      userMessage: userMessage,
      conversationHistory: conversationHistory,
      style: style,
    );

    aiResult.fold(
      (failure) {
        debugPrint('ChatNotifier: AI response failed - ${failure.message}');
        // Update state with failure but keep messages
        final updatedState = state.valueOrNull;
        if (updatedState != null) {
          state = AsyncValue.data(
            updatedState.copyWith(isSending: false, failure: failure),
          );
        }
      },
      (aiResponse) {
        debugPrint('ChatNotifier: AI response received successfully');
        // Add AI response as assistant message
        addAssistantMessage(aiResponse.content);

        // Award XP for receiving AI response
        _awardXpForAiResponse();
      },
    );
  }

  /// Updates conversation metadata after sending a message
  Future<void> _updateConversationMetadata(Message message) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedConversation = currentState.currentConversation.copyWith(
      updatedAt: DateTime.now(),
      messageCount: currentState.messages.length,
      lastMessagePreview: message.content.length > 100
          ? '${message.content.substring(0, 100)}...'
          : message.content,
    );

    await _repository.updateConversation(updatedConversation);

    state = AsyncValue.data(
      currentState.copyWith(currentConversation: updatedConversation),
    );
  }

  /// Adds an assistant message (for AI responses)
  Future<void> addAssistantMessage(String content) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final result = await _repository.sendMessage(
      conversationId: currentState.currentConversation.id,
      content: content,
      sender: MessageSender.assistant,
    );

    result.fold(
      (failure) {
        state = AsyncValue.data(
          currentState.copyWith(isSending: false, failure: failure),
        );
      },
      (message) {
        // Get latest state to include any recent updates
        final latestState = state.valueOrNull ?? currentState;
        final updatedMessages = [...latestState.messages, message];
        state = AsyncValue.data(
          latestState.copyWith(
            messages: updatedMessages,
            isSending: false, // Clear sending state after AI response
          ),
        );
        _updateConversationMetadata(message);
      },
    );
  }

  /// Starts a new conversation
  Future<void> startNewConversation() async {
    state = const AsyncValue.loading();

    final result = await _repository.startNewConversation();

    state = AsyncValue.data(
      result.fold(
        (failure) => ChatState.initial().copyWith(failure: failure),
        (conversation) =>
            ChatState(currentConversation: conversation, messages: const []),
      ),
    );
  }

  /// Loads a specific conversation
  Future<void> loadConversation(String conversationId) async {
    state = const AsyncValue.loading();

    final conversationResult = await _repository.getConversation(
      conversationId,
    );

    final newState = await conversationResult.fold(
      (failure) async => ChatState.initial().copyWith(failure: failure),
      (conversation) async {
        if (conversation == null) {
          return ChatState.initial().copyWith(
            failure: ChatFailure.conversationNotFound(),
          );
        }

        await _repository.setCurrentConversation(conversationId);

        final messagesResult = await _repository.getMessages(conversationId);

        return messagesResult.fold(
          (failure) => ChatState(
            currentConversation: conversation,
            messages: const [],
            failure: failure,
          ),
          (messages) =>
              ChatState(currentConversation: conversation, messages: messages),
        );
      },
    );

    state = AsyncValue.data(newState);
  }

  /// Deletes the current conversation
  Future<void> deleteCurrentConversation() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasConversation) return;

    final result = await _repository.deleteConversation(
      currentState.currentConversation.id,
    );

    result.fold(
      (failure) {
        state = AsyncValue.data(currentState.copyWith(failure: failure));
      },
      (_) async {
        // Start a new conversation after deletion
        await startNewConversation();
      },
    );
  }

  /// Clears any error state
  void clearError() {
    final currentState = state.valueOrNull;
    if (currentState != null && currentState.hasError) {
      state = AsyncValue.data(currentState.copyWith(failure: null));
    }
  }

  /// Sends message to backend and handles streaming response
  Future<void> _sendToBackendAndHandleResponse(
    String content,
    List<Message> updatedMessages,
  ) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final remoteDatasource = ref.read(chatRemoteDatasourceProvider);

    try {
      final streamResult = await remoteDatasource.sendMessageAndStream(
        chatId: currentState.currentConversation.id,
        message: content,
      );

      await streamResult.fold(
        (failure) async {
          debugPrint('ChatNotifier: Backend send failed - ${failure.message}');
          state = AsyncValue.data(
            currentState.copyWith(
              isSending: false,
              failure: failure,
              messages: updatedMessages,
            ),
          );
        },
        (stream) async {
          await _handleBackendStream(stream, currentState, updatedMessages);
        },
      );
    } catch (e) {
      debugPrint('ChatNotifier: Error sending to backend: $e');
      final failure = ChatFailure.unknown('Failed to send message');
      state = AsyncValue.data(
        currentState.copyWith(
          isSending: false,
          failure: failure,
          messages: updatedMessages,
        ),
      );
    }
  }

  /// Handles incoming streaming response from backend
  Future<void> _handleBackendStream(
    Stream<String> stream,
    ChatState currentState,
    List<Message> messageList,
  ) async {
    try {
      final buffer = StringBuffer();

      await stream
          .listen(
            (chunk) {
              buffer.write(chunk);
              debugPrint(
                'ChatNotifier: Received chunk - ${chunk.length} bytes',
              );
            },
            onError: (error) {
              debugPrint('ChatNotifier: Stream error - $error');
              final failure = ChatFailure.unknown(
                'Stream error: ${error.toString()}',
              );
              state = AsyncValue.data(
                currentState.copyWith(
                  isSending: false,
                  failure: failure,
                  messages: messageList,
                ),
              );
            },
            onDone: () async {
              final response = buffer.toString().trim();
              debugPrint(
                'ChatNotifier: Stream complete - response length: ${response.length}',
              );

              if (response.isNotEmpty) {
                // Add AI response as a new message
                await addAssistantMessage(response);
              } else {
                // Stream ended with no content
                final latestState = state.valueOrNull ?? currentState;
                state = AsyncValue.data(latestState.copyWith(isSending: false));
              }
            },
          )
          .asFuture();
    } catch (e) {
      debugPrint('ChatNotifier: Error handling stream: $e');
      final failure = ChatFailure.unknown(
        'Failed to process response: ${e.toString()}',
      );
      state = AsyncValue.data(
        currentState.copyWith(
          isSending: false,
          failure: failure,
          messages: messageList,
        ),
      );
    }
  }

  /// Awards XP for sending a message
  Future<void> _awardXpForMessage() async {
    try {
      await ref.read(dashboardProvider.notifier).recordMessageSent();
    } catch (e) {
      debugPrint('ChatNotifier: Error awarding XP for message: $e');
    }
  }

  /// Awards XP for receiving AI response
  Future<void> _awardXpForAiResponse() async {
    try {
      await ref.read(dashboardProvider.notifier).recordAiResponse();
    } catch (e) {
      debugPrint('ChatNotifier: Error awarding XP for AI response: $e');
    }
  }

  /// Refreshes the current conversation
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _loadCurrentConversation());
  }
}

// =============================================================================
// Main Chat Provider
// =============================================================================

/// Main provider for chat state
///
/// Usage:
/// ```dart
/// final chatState = ref.watch(chatProvider);
/// chatState.when(
///   data: (state) => ...,
///   loading: () => ...,
///   error: (e, st) => ...,
/// );
/// ```
final chatProvider = AsyncNotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);

// =============================================================================
// Convenience Providers
// =============================================================================

/// Provider that returns the current conversation
final currentConversationProvider = Provider<Conversation?>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.maybeWhen(
    data: (state) => state.hasConversation ? state.currentConversation : null,
    orElse: () => null,
  );
});

/// Provider that returns the current messages
final currentMessagesProvider = Provider<List<Message>>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.maybeWhen(
    data: (state) => state.messages,
    orElse: () => const [],
  );
});

/// Provider that returns whether a message is being sent
final isSendingMessageProvider = Provider<bool>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.maybeWhen(
    data: (state) => state.isSending,
    orElse: () => false,
  );
});

/// Provider that returns whether chat is loading
final isChatLoadingProvider = Provider<bool>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.isLoading ||
      chatState.maybeWhen(
        data: (state) => state.isLoading,
        orElse: () => false,
      );
});

// =============================================================================
// Conversations List Provider
// =============================================================================

/// Provider for the list of all conversations (for history screen)
final conversationsProvider = FutureProvider<List<Conversation>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  final datasource = ref.watch(chatLocalDatasourceProvider);

  // Ensure initialized
  await datasource.initialize();

  final result = await repository.getConversations();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (conversations) => conversations,
  );
});
