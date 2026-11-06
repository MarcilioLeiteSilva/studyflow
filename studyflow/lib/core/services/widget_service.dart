import 'package:home_widget/home_widget.dart';
import '../../data/models/task_model.dart';

class WidgetService {
  static const String appGroupId = 'group.com.studyplanner.app'; // Replace with actual group id
  static const String iOSWidgetName = 'TodoWidget';
  static const String androidWidgetName = 'TodoWidgetProvider';

  static Future<void> updateWidget(List<TaskModel> tasks) async {
    try {
      // Get today's pending tasks
      final today = DateTime.now();
      final todayTasks = tasks.where((t) => 
        t.deadline != null &&
        t.deadline!.year == today.year && 
        t.deadline!.month == today.month && 
        t.deadline!.day == today.day &&
        !t.isCompleted
      ).toList();

      // Save data for widget
      await HomeWidget.saveWidgetData<int>('pending_count', todayTasks.length);
      
      // Save top 3 tasks titles
      for (int i = 0; i < 3; i++) {
        if (i < todayTasks.length) {
          await HomeWidget.saveWidgetData<String>('task_title_$i', todayTasks[i].title);
        } else {
          await HomeWidget.saveWidgetData<String>('task_title_$i', '');
        }
      }

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
}
