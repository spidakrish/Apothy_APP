import 'package:hive/hive.dart';

import '../../domain/entities/message.dart';

part 'message_model.g.dart';

/// Hive type IDs for chat models
/// Using 10-19 range to avoid conflicts with other features
abstract class ChatHiveTypeIds {
  static const int messageModel = 10;
  static const int conversationModel = 11;
  static const int messageSenderAdapter = 12;
}

/// Hive adapter for MessageSender enum
@HiveType(typeId: ChatHiveTypeIds.messageSenderAdapter)
enum MessageSenderHive {
  @HiveField(0)
  user,
  @HiveField(1)
  assistant,
}

/// Data model for Message entity with Hive persistence
@HiveType(typeId: ChatHiveTypeIds.messageModel)
class MessageModel extends HiveObject {
  MessageModel({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.createdAt,
    this.isStreaming = false,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String conversationId;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final MessageSenderHive sender;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool isStreaming;

  /// Creates a MessageModel from a Message entity
  factory MessageModel.fromEntity(Message message) {
    return MessageModel(
      id: message.id,
      conversationId: message.conversationId,
      content: message.content,
      sender: message.sender == MessageSender.user
          ? MessageSenderHive.user
          : MessageSenderHive.assistant,
      createdAt: message.createdAt,
      isStreaming: message.isStreaming,
    );
  }

  /// Converts to Message entity
  Message toEntity() {
    return Message(
      id: id,
      conversationId: conversationId,
      content: content,
      sender: sender == MessageSenderHive.user
          ? MessageSender.user
          : MessageSender.assistant,
      createdAt: createdAt,
      isStreaming: isStreaming,
    );
  }

  /// Creates a copy with updated fields
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? content,
    MessageSenderHive? sender,
    DateTime? createdAt,
    bool? isStreaming,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }
}
