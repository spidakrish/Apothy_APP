import 'package:hive_flutter/hive_flutter.dart';

import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Keys/names for Hive boxes
abstract class ChatStorageKeys {
  static const String messagesBox = 'messages';
  static const String conversationsBox = 'conversations';
  static const String currentConversationId = 'current_conversation_id';
}

/// Local data source for chat using Hive storage
///
/// Provides persistence for:
/// - Chat messages (organized by conversation)
/// - Conversation metadata
/// - Current active conversation tracking
abstract class ChatLocalDatasource {
  /// Initializes Hive boxes for chat storage
  /// Must be called before any other operations
  Future<void> initialize();

  // ============================================================================
  // Message Operations
  // ============================================================================

  /// Saves a message to the local store
  Future<void> saveMessage(MessageModel message);

  /// Retrieves all messages for a conversation
  Future<List<MessageModel>> getMessages(String conversationId);

  /// Gets a single message by ID
  Future<MessageModel?> getMessage(String messageId);

  /// Updates an existing message
  Future<void> updateMessage(MessageModel message);

  /// Deletes a message
  Future<void> deleteMessage(String messageId);

  /// Deletes all messages for a conversation
  Future<void> deleteConversationMessages(String conversationId);

  // ============================================================================
  // Conversation Operations
  // ============================================================================

  /// Saves or updates a conversation
  Future<void> saveConversation(ConversationModel conversation);

  /// Retrieves all conversations, sorted by updatedAt descending
  Future<List<ConversationModel>> getConversations();

  /// Gets a single conversation by ID
  Future<ConversationModel?> getConversation(String conversationId);

  /// Updates conversation metadata (title, message count, last message preview)
  Future<void> updateConversation(ConversationModel conversation);

  /// Deletes a conversation and all its messages
  Future<void> deleteConversation(String conversationId);

  // ============================================================================
  // Current Conversation Tracking
  // ============================================================================

  /// Gets the current active conversation ID
  Future<String?> getCurrentConversationId();

  /// Sets the current active conversation ID
  Future<void> setCurrentConversationId(String? conversationId);

  // ============================================================================
  // Utility Operations
  // ============================================================================

  /// Clears all chat data (messages and conversations)
  Future<void> clearAll();

  /// Gets the total number of messages across all conversations
  Future<int> getTotalMessageCount();

  /// Gets the total number of conversations
  Future<int> getConversationCount();
}

/// Implementation of ChatLocalDatasource using Hive
class ChatLocalDatasourceImpl implements ChatLocalDatasource {
  ChatLocalDatasourceImpl();

  Box<MessageModel>? _messagesBox;
  Box<ConversationModel>? _conversationsBox;

  /// Gets the messages box, throwing if not initialized
  Box<MessageModel> get _messages {
    if (_messagesBox == null || !_messagesBox!.isOpen) {
      throw StateError('Messages box not initialized. Call initialize() first.');
    }
    return _messagesBox!;
  }

  /// Gets the conversations box, throwing if not initialized
  Box<ConversationModel> get _conversations {
    if (_conversationsBox == null || !_conversationsBox!.isOpen) {
      throw StateError('Conversations box not initialized. Call initialize() first.');
    }
    return _conversationsBox!;
  }

  @override
  Future<void> initialize() async {
    _messagesBox = await Hive.openBox<MessageModel>(ChatStorageKeys.messagesBox);
    _conversationsBox = await Hive.openBox<ConversationModel>(ChatStorageKeys.conversationsBox);
  }

  // ============================================================================
  // Message Operations
  // ============================================================================

  @override
  Future<void> saveMessage(MessageModel message) async {
    await _messages.put(message.id, message);
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final messages = _messages.values
        .where((msg) => msg.conversationId == conversationId)
        .toList();

    // Sort by createdAt ascending (oldest first)
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return messages;
  }

  @override
  Future<MessageModel?> getMessage(String messageId) async {
    return _messages.get(messageId);
  }

  @override
  Future<void> updateMessage(MessageModel message) async {
    await _messages.put(message.id, message);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    await _messages.delete(messageId);
  }

  @override
  Future<void> deleteConversationMessages(String conversationId) async {
    final messagesToDelete = _messages.values
        .where((msg) => msg.conversationId == conversationId)
        .map((msg) => msg.id)
        .toList();

    await _messages.deleteAll(messagesToDelete);
  }

  // ============================================================================
  // Conversation Operations
  // ============================================================================

  @override
  Future<void> saveConversation(ConversationModel conversation) async {
    await _conversations.put(conversation.id, conversation);
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    final conversations = _conversations.values.toList();

    // Sort by updatedAt descending (most recent first)
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return conversations;
  }

  @override
  Future<ConversationModel?> getConversation(String conversationId) async {
    return _conversations.get(conversationId);
  }

  @override
  Future<void> updateConversation(ConversationModel conversation) async {
    await _conversations.put(conversation.id, conversation);
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    // Delete conversation
    await _conversations.delete(conversationId);

    // Delete all messages for this conversation
    await deleteConversationMessages(conversationId);
  }

  // ============================================================================
  // Current Conversation Tracking
  // ============================================================================

  @override
  Future<String?> getCurrentConversationId() async {
    // Store in conversations box as a special key
    final box = await Hive.openBox<String>('chat_settings');
    return box.get(ChatStorageKeys.currentConversationId);
  }

  @override
  Future<void> setCurrentConversationId(String? conversationId) async {
    final box = await Hive.openBox<String>('chat_settings');
    if (conversationId == null) {
      await box.delete(ChatStorageKeys.currentConversationId);
    } else {
      await box.put(ChatStorageKeys.currentConversationId, conversationId);
    }
  }

  // ============================================================================
  // Utility Operations
  // ============================================================================

  @override
  Future<void> clearAll() async {
    await _messages.clear();
    await _conversations.clear();
    await setCurrentConversationId(null);
  }

  @override
  Future<int> getTotalMessageCount() async {
    return _messages.length;
  }

  @override
  Future<int> getConversationCount() async {
    return _conversations.length;
  }
}
