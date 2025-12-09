import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../data/datasources/chat_local_datasource.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

// =============================================================================
// Datasource Providers
// =============================================================================

/// Provider for ChatLocalDatasource
final chatLocalDatasourceProvider = Provider<ChatLocalDatasource>((ref) {
  return ChatLocalDatasourceImpl();
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
  factory ChatState.initial() => ChatState(
    currentConversation: Conversation.empty,
    messages: const [],
  );

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
        debugPrint('ChatNotifier: error loading conversation: ${failure.message}');
        return ChatState.initial().copyWith(failure: failure);
      },
      (conversation) async {
        debugPrint('ChatNotifier: loaded conversation ${conversation.id}');

        // Load messages for this conversation
        final messagesResult = await _repository.getMessages(conversation.id);

        return messagesResult.fold(
          (failure) {
            debugPrint('ChatNotifier: error loading messages: ${failure.message}');
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

  /// Sends a user message
  Future<void> sendMessage(String content) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    if (content.trim().isEmpty) return;

    // Set sending state
    state = AsyncValue.data(currentState.copyWith(isSending: true));

    // Send user message
    final result = await _repository.sendMessage(
      conversationId: currentState.currentConversation.id,
      content: content,
      sender: MessageSender.user,
    );

    result.fold(
      (failure) {
        state = AsyncValue.data(currentState.copyWith(
          isSending: false,
          failure: failure,
        ));
      },
      (message) {
        // Add message to list
        final updatedMessages = [...currentState.messages, message];
        state = AsyncValue.data(currentState.copyWith(
          messages: updatedMessages,
          isSending: false,
        ));

        // Update conversation metadata
        _updateConversationMetadata(message);
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

    state = AsyncValue.data(currentState.copyWith(
      currentConversation: updatedConversation,
    ));
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
        state = AsyncValue.data(currentState.copyWith(failure: failure));
      },
      (message) {
        final updatedMessages = [...currentState.messages, message];
        state = AsyncValue.data(currentState.copyWith(messages: updatedMessages));
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
        (conversation) => ChatState(
          currentConversation: conversation,
          messages: const [],
        ),
      ),
    );
  }

  /// Loads a specific conversation
  Future<void> loadConversation(String conversationId) async {
    state = const AsyncValue.loading();

    final conversationResult = await _repository.getConversation(conversationId);

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
          (messages) => ChatState(
            currentConversation: conversation,
            messages: messages,
          ),
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
