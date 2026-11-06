import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category;

  @HiveField(3)
  int priority; // 0: Low, 1: Medium, 2: High

  @HiveField(4)
  DateTime? deadline;

  @HiveField(5)
  String notes;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    this.priority = 0,
    this.deadline,
    this.notes = '',
    this.isCompleted = false,
    required this.createdAt,
  });

  factory TaskModel.create({
    required String title,
    required String category,
    int priority = 0,
    DateTime? deadline,
    String notes = '',
  }) {
    return TaskModel(
      id: const Uuid().v4(),
      title: title,
      category: category,
      priority: priority,
      deadline: deadline,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }
}
