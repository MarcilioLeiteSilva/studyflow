import 'package:hive_flutter/hive_flutter.dart';
import '../../core/services/widget_service.dart';
import '../../core/services/sync_service.dart';
import '../models/task_model.dart';
import '../models/pomodoro_session_model.dart';
import '../models/achievement_model.dart';
import '../models/flashcard_model.dart';

class HiveStorage {
  static const String tasksBoxName = 'tasksBox';
  static const String sessionsBoxName = 'sessionsBox';
  static const String achievementsBoxName = 'achievementsBox';
  static const String settingsBoxName = 'settingsBox';
  static const String flashcardsBoxName = 'flashcards';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(PomodoroSessionModelAdapter());
    Hive.registerAdapter(AchievementModelAdapter());
    Hive.registerAdapter(FlashcardAdapter());

    await Hive.openBox<TaskModel>(tasksBoxName);
    await Hive.openBox<PomodoroSessionModel>(sessionsBoxName);
    await Hive.openBox<AchievementModel>(achievementsBoxName);
    await Hive.openBox<Flashcard>(flashcardsBoxName);
    await Hive.openBox(settingsBoxName);
  }

  // Tasks
  static Box<TaskModel> get tasksBox => Hive.box<TaskModel>(tasksBoxName);
  
  static Future<void> addTask(TaskModel task) async {
    await tasksBox.put(task.id, task);
    WidgetService.updateWidget(getTasks());
    SyncService().syncTasks(getTasks());
  }

  static Future<void> updateTask(TaskModel task) async {
    await tasksBox.put(task.id, task);
    WidgetService.updateWidget(getTasks());
    SyncService().syncTasks(getTasks());
  }

  static Future<void> deleteTask(String id) async {
    await tasksBox.delete(id);
    WidgetService.updateWidget(getTasks());
    SyncService().syncTasks(getTasks());
  }

  static List<TaskModel> getTasks() {
    return tasksBox.values.toList();
  }

  // Sessions
  static Box<PomodoroSessionModel> get sessionsBox => Hive.box<PomodoroSessionModel>(sessionsBoxName);

  static Future<void> saveSession(PomodoroSessionModel session) async {
    await sessionsBox.put(session.id, session);
  }

  static List<PomodoroSessionModel> getSessions() {
    return sessionsBox.values.toList();
  }

  // Achievements
  static Box<AchievementModel> get achievementsBox => Hive.box<AchievementModel>(achievementsBoxName);

  static Future<void> addAchievement(AchievementModel achievement) async {
    await achievementsBox.put(achievement.badgeName, achievement);
  }

  static List<AchievementModel> getAchievements() {
    return achievementsBox.values.toList();
  }

  // Flashcards
  static Box<Flashcard> get flashcardsBox => Hive.box<Flashcard>(flashcardsBoxName);

  static Future<void> addFlashcard(Flashcard card) async {
    await flashcardsBox.put(card.id, card);
  }

  static List<Flashcard> getFlashcards() {
    return flashcardsBox.values.toList();
  }

  // Settings
  static Box get settingsBox => Hive.box(settingsBoxName);

  static dynamic getSetting(String key, {dynamic defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }

  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }
}
