// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reflection_response_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReflectionResponseModelAdapter
    extends TypeAdapter<ReflectionResponseModel> {
  @override
  final int typeId = 32;

  @override
  ReflectionResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReflectionResponseModel(
      question: fields[0] as String,
      response: fields[1] as String,
      isAnswered: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReflectionResponseModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.response)
      ..writeByte(2)
      ..write(obj.isAnswered);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReflectionResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
