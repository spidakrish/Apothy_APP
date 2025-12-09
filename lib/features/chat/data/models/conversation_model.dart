import 'package:hive/hive.dart';

import '../../domain/entities/conversation.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

/// Data model for Conversation entity with Hive persistence
@HiveType(typeId: ChatHiveTypeIds.conversationModel)
class ConversationModel extends HiveObject {
  ConversationModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.messageCount = 0,
    this.lastMessagePreview,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final int messageCount;

  @HiveField(5)
  final String? lastMessagePreview;

  /// Creates a ConversationModel from a Conversation entity
  factory ConversationModel.fromEntity(Conversation conversation) {
    return ConversationModel(
      id: conversation.id,
      title: conversation.title,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      messageCount: conversation.messageCount,
      lastMessagePreview: conversation.lastMessagePreview,
    );
  }

  /// Converts to Conversation entity
  Conversation toEntity() {
    return Conversation(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      messageCount: messageCount,
      lastMessagePreview: lastMessagePreview,
    );
  }

  /// Creates a copy with updated fields
  ConversationModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? messageCount,
    String? lastMessagePreview,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messageCount: messageCount ?? this.messageCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
    );
  }
}
