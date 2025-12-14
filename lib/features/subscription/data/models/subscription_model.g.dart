// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionModelAdapter extends TypeAdapter<SubscriptionModel> {
  @override
  final int typeId = 40;

  @override
  SubscriptionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubscriptionModel(
      tier: fields[0] as SubscriptionTierHive,
      status: fields[1] as SubscriptionStatusHive,
      expiresAt: fields[2] as DateTime?,
      willRenew: fields[3] as bool,
      productId: fields[4] as String?,
      originalPurchaseDate: fields[5] as DateTime?,
      lastSyncedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SubscriptionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.tier)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.expiresAt)
      ..writeByte(3)
      ..write(obj.willRenew)
      ..writeByte(4)
      ..write(obj.productId)
      ..writeByte(5)
      ..write(obj.originalPurchaseDate)
      ..writeByte(6)
      ..write(obj.lastSyncedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubscriptionTierHiveAdapter extends TypeAdapter<SubscriptionTierHive> {
  @override
  final int typeId = 41;

  @override
  SubscriptionTierHive read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionTierHive.free;
      case 1:
        return SubscriptionTierHive.plus;
      case 2:
        return SubscriptionTierHive.pro;
      default:
        return SubscriptionTierHive.free;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionTierHive obj) {
    switch (obj) {
      case SubscriptionTierHive.free:
        writer.writeByte(0);
        break;
      case SubscriptionTierHive.plus:
        writer.writeByte(1);
        break;
      case SubscriptionTierHive.pro:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionTierHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubscriptionStatusHiveAdapter
    extends TypeAdapter<SubscriptionStatusHive> {
  @override
  final int typeId = 42;

  @override
  SubscriptionStatusHive read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubscriptionStatusHive.active;
      case 1:
        return SubscriptionStatusHive.expired;
      case 2:
        return SubscriptionStatusHive.cancelled;
      case 3:
        return SubscriptionStatusHive.trial;
      case 4:
        return SubscriptionStatusHive.gracePeriod;
      default:
        return SubscriptionStatusHive.active;
    }
  }

  @override
  void write(BinaryWriter writer, SubscriptionStatusHive obj) {
    switch (obj) {
      case SubscriptionStatusHive.active:
        writer.writeByte(0);
        break;
      case SubscriptionStatusHive.expired:
        writer.writeByte(1);
        break;
      case SubscriptionStatusHive.cancelled:
        writer.writeByte(2);
        break;
      case SubscriptionStatusHive.trial:
        writer.writeByte(3);
        break;
      case SubscriptionStatusHive.gracePeriod:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionStatusHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
