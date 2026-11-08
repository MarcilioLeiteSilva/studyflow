import 'dart:convert';
import 'task_model.dart';

class LessonExercise {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  LessonExercise({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
  };

  factory LessonExercise.fromJson(Map<String, dynamic> json) {
    return LessonExercise(
      question: json['question']?.toString() ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

class LessonModuleModel {
  final String id;
  final String title;
  final String category;
  final int durationMinutes;
  final String summaryLesson;
  final List<LessonExercise> exercises;

  LessonModuleModel({
    required this.id,
    required this.title,
    required this.category,
    this.durationMinutes = 10,
    required this.summaryLesson,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'durationMinutes': durationMinutes,
    'summaryLesson': summaryLesson,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory LessonModuleModel.fromJson(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List<dynamic>? ?? [];
    return LessonModuleModel(
      id: json['id']?.toString() ?? 'mod_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Micro-Aula',
      category: json['category']?.toString() ?? 'Geral',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 10,
      summaryLesson: json['summaryLesson']?.toString() ?? '',
      exercises: rawExercises.map((e) => LessonExercise.fromJson(Map<String, dynamic>.from(e))).toList(),
    );
  }

  TaskModel toTaskModel({DateTime? deadline, int priority = 1}) {
    final payload = {
      'isAudioLesson': true,
      'durationMinutes': durationMinutes,
      'summaryLesson': summaryLesson,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };

    return TaskModel.create(
      title: '🎧 $title (${durationMinutes}m)',
      category: category,
      priority: priority,
      deadline: deadline ?? DateTime.now(),
      notes: jsonEncode(payload),
    );
  }

  static LessonModuleModel? fromTaskModel(TaskModel task) {
    if (task.notes.trim().isEmpty) return null;
    try {
      final data = jsonDecode(task.notes);
      if (data is Map && data['isAudioLesson'] == true) {
        return LessonModuleModel.fromJson({
          'id': task.id,
          'title': task.title.replaceAll(RegExp(r'^🎧\s*'), '').replaceAll(RegExp(r'\s*\(\d+m\)$'), ''),
          'category': task.category,
          'durationMinutes': data['durationMinutes'] ?? 10,
          'summaryLesson': data['summaryLesson'] ?? '',
          'exercises': data['exercises'] ?? [],
        });
      }
    } catch (_) {}
    return null;
  }
}

