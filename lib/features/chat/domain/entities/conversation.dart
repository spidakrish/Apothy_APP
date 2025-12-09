import 'package:equatable/equatable.dart';

/// Conversation entity representing a chat conversation/thread
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.lastMessagePreview,
  });

  /// Unique conversation identifier
  final String id;

  /// Conversation title (auto-generated or user-defined)
  final String title;

  /// When the conversation was created
  final DateTime createdAt;

  /// When the conversation was last updated
  final DateTime updatedAt;

  /// Number of messages in this conversation
  final int messageCount;

  /// Preview of the last message (for list display)
  final String? lastMessagePreview;

  /// Creates an empty conversation
  static Conversation empty = Conversation(
    id: '',
    title: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// Whether this conversation is empty
  bool get isEmpty => id.isEmpty;

  /// Whether this conversation is not empty
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [
        id,
        title,
        createdAt,
        updatedAt,
        messageCount,
        lastMessagePreview,
      ];

  /// Creates a copy with updated fields
  Conversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    String? lastMessagePreview,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
    );
  }
}
