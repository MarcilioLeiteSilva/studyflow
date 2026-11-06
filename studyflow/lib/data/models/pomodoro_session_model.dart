import 'package:hive/hive.dart';

part 'pomodoro_session_model.g.dart';

@HiveType(typeId: 1)
class PomodoroSessionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int durationMinutes;

  @HiveField(2)
  final DateTime completedDate;

  @HiveField(3)
  final String? taskId;

  PomodoroSessionModel({
    required this.id,
    required this.durationMinutes,
    required this.completedDate,
    this.taskId,
  });
}
