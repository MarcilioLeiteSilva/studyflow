// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementModelAdapter extends TypeAdapter<AchievementModel> {
  @override
  final int typeId = 2;

  @override
  AchievementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AchievementModel(
      badgeName: fields[0] as String,
      iconPath: fields[1] as String,
      achievedDate: fields[2] as DateTime,
      description: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AchievementModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.badgeName)
      ..writeByte(1)
      ..write(obj.iconPath)
      ..writeByte(2)
      ..write(obj.achievedDate)
      ..writeByte(3)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
