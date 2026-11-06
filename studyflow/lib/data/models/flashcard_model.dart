import 'package:hive/hive.dart';

part 'flashcard_model.g.dart';

@HiveType(typeId: 4)
class Flashcard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String question;

  @HiveField(2)
  final String answer;

  @HiveField(3)
  final String subject;

  @HiveField(4)
  DateTime nextReviewDate;

  @HiveField(5)
  double easeFactor;

  @HiveField(6)
  int interval;

  @HiveField(7)
  int repetitions;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.subject,
    required this.nextReviewDate,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
  });
}
