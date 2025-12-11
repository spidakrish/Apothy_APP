// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emotion_challenge_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmotionChallengeSessionModelAdapter
    extends TypeAdapter<EmotionChallengeSessionModel> {
  @override
  final int typeId = 30;

  @override
  EmotionChallengeSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmotionChallengeSessionModel(
      id: fields[0] as String,
      emotionId: fields[1] as String,
      emotionName: fields[2] as String,
      emotionColorValue: fields[3] as int,
      emotionIntensity: fields[4] as String,
      bodyMapPoints: (fields[5] as List).cast<BodyMapPointModel>(),
      cbtScore: fields[6] as int,
      reflections: (fields[7] as List).cast<ReflectionResponseModel>(),
      startedAt: fields[8] as DateTime,
      completedAt: fields[9] as DateTime,
      xpEarned: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, EmotionChallengeSessionModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.emotionId)
      ..writeByte(2)
      ..write(obj.emotionName)
      ..writeByte(3)
      ..write(obj.emotionColorValue)
      ..writeByte(4)
      ..write(obj.emotionIntensity)
      ..writeByte(5)
      ..write(obj.bodyMapPoints)
      ..writeByte(6)
      ..write(obj.cbtScore)
      ..writeByte(7)
      ..write(obj.reflections)
      ..writeByte(8)
      ..write(obj.startedAt)
      ..writeByte(9)
      ..write(obj.completedAt)
      ..writeByte(10)
      ..write(obj.xpEarned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmotionChallengeSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
