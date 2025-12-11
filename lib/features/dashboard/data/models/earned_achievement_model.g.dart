// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earned_achievement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EarnedAchievementModelAdapter
    extends TypeAdapter<EarnedAchievementModel> {
  @override
  final int typeId = 21;

  @override
  EarnedAchievementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EarnedAchievementModel(
      achievementId: fields[0] as String,
      earnedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EarnedAchievementModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.achievementId)
      ..writeByte(1)
      ..write(obj.earnedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EarnedAchievementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
