// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 10;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      conversationId: fields[1] as String,
      content: fields[2] as String,
      sender: fields[3] as MessageSenderHive,
      createdAt: fields[4] as DateTime,
      isStreaming: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.sender)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isStreaming);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageSenderHiveAdapter extends TypeAdapter<MessageSenderHive> {
  @override
  final int typeId = 12;

  @override
  MessageSenderHive read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageSenderHive.user;
      case 1:
        return MessageSenderHive.assistant;
      default:
        return MessageSenderHive.user;
    }
  }

  @override
  void write(BinaryWriter writer, MessageSenderHive obj) {
    switch (obj) {
      case MessageSenderHive.user:
        writer.writeByte(0);
        break;
      case MessageSenderHive.assistant:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSenderHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
