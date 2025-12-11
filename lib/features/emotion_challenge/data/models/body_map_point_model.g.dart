// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_map_point_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BodyMapPointModelAdapter extends TypeAdapter<BodyMapPointModel> {
  @override
  final int typeId = 31;

  @override
  BodyMapPointModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyMapPointModel(
      positionX: fields[0] as double,
      positionY: fields[1] as double,
      intensity: fields[2] as double,
      radius: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BodyMapPointModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.positionX)
      ..writeByte(1)
      ..write(obj.positionY)
      ..writeByte(2)
      ..write(obj.intensity)
      ..writeByte(3)
      ..write(obj.radius);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BodyMapPointModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
