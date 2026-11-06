// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PomodoroSessionModelAdapter extends TypeAdapter<PomodoroSessionModel> {
  @override
  final int typeId = 1;

  @override
  PomodoroSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PomodoroSessionModel(
      id: fields[0] as String,
      durationMinutes: fields[1] as int,
      completedDate: fields[2] as DateTime,
      taskId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PomodoroSessionModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.durationMinutes)
      ..writeByte(2)
      ..write(obj.completedDate)
      ..writeByte(3)
      ..write(obj.taskId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PomodoroSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
