import 'package:equatable/equatable.dart';

/// Message sender types
enum MessageSender {
  user,
  assistant,
}

/// Message entity representing a single chat message
class Message extends Equatable {
  const Message({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.createdAt,
    this.isStreaming = false,
  });

  /// Unique message identifier
  final String id;

  /// ID of the conversation this message belongs to
  final String conversationId;

  /// Message content text
  final String content;

  /// Who sent the message (user or assistant)
  final MessageSender sender;

  /// When the message was created
  final DateTime createdAt;

  /// Whether the message is currently being streamed
  final bool isStreaming;

  /// Creates an empty message
  static Message empty = Message(
    id: '',
    conversationId: '',
    content: '',
    sender: MessageSender.user,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Whether this message is empty
  bool get isEmpty => id.isEmpty;

  /// Whether this message is not empty
  bool get isNotEmpty => !isEmpty;

  /// Whether this is a user message
  bool get isUser => sender == MessageSender.user;

  /// Whether this is an assistant message
  bool get isAssistant => sender == MessageSender.assistant;

  @override
  List<Object?> get props => [
        id,
        conversationId,
        content,
        sender,
        createdAt,
        isStreaming,
      ];

  /// Creates a copy with updated fields
  Message copyWith({
    String? id,
    String? conversationId,
    String? content,
    MessageSender? sender,
    DateTime? createdAt,
    bool? isStreaming,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
