// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashcardAdapter extends TypeAdapter<Flashcard> {
  @override
  final int typeId = 4;

  @override
  Flashcard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Flashcard(
      id: fields[0] as String,
      question: fields[1] as String,
      answer: fields[2] as String,
      subject: fields[3] as String,
      nextReviewDate: fields[4] as DateTime,
      easeFactor: fields[5] as double,
      interval: fields[6] as int,
      repetitions: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Flashcard obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.answer)
      ..writeByte(3)
      ..write(obj.subject)
      ..writeByte(4)
      ..write(obj.nextReviewDate)
      ..writeByte(5)
      ..write(obj.easeFactor)
      ..writeByte(6)
      ..write(obj.interval)
      ..writeByte(7)
      ..write(obj.repetitions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
