import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../../core/services/ads_service.dart';
import '../../data/local/hive_storage.dart';
import '../../data/models/task_model.dart';
import '../dashboard/app_drawer.dart';
import '../ai_assistant/ai_routine_screen.dart';
import 'calendar_screen.dart';
import 'task_detail_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      drawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                tooltip: 'Menu',
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                l10n.dashboardMyTasks,
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIRoutineScreen())),
                tooltip: l10n.tooltipAIAssistant,
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
                tooltip: l10n.tooltipCalendarView,
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: ValueListenableBuilder(
              valueListenable: HiveStorage.tasksBox.listenable(),
              builder: (context, Box<TaskModel> box, _) {
                final allTasks = box.values.toList();
                final pendingCount = allTasks.where((t) => !t.isCompleted).length;
                final doneCount = allTasks.where((t) => t.isCompleted).length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: l10n.dashboardPending,
                          count: pendingCount,
                          color: Colors.orange,
                          icon: Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SummaryCard(
                          title: l10n.dashboardDone,
                          count: doneCount,
                          color: Colors.green,
                          icon: Icons.task_alt,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: HiveStorage.tasksBox.listenable(),
            builder: (context, Box<TaskModel> box, _) {
              final tasks = box.values.toList()
                ..sort((a, b) {
                  // Sort by completion (incomplete first), then priority (high first), then date
                  if (a.isCompleted != b.isCompleted) {
                    return a.isCompleted ? 1 : -1;
                  }
                  if (a.priority != b.priority) {
                    return b.priority.compareTo(a.priority);
                  }
                  return b.createdAt.compareTo(a.createdAt);
                });

              if (tasks.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_add, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                            const SizedBox(height: 20),
                            Text(
                          l10n.dashboardNoTasks,
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _showAddTaskDialog(context),
                          child: Text(l10n.dashboardCreateFirstTask),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return AnimationLimiter(
                child: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
              final task = tasks[index];
                      // Show ad after every few tasks or at the top
                      if (index == 0) {
                        return Column(
                          children: [
                            AdsService().getBannerAd(),
                            _buildTaskItem(task, index, tasks.length, l10n, locale),
                          ],
                        );
                      }
                      return _buildTaskItem(task, index, tasks.length, l10n, locale);
                    },
                    childCount: tasks.length,
                  ),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.btnAddTask),
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task, int index, int total, dynamic l10n, String locale) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Dismissible(
            key: Key(task.id),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              HiveStorage.deleteTask(task.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.dashboardTaskDeleted)),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(task: task),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    shape: const CircleBorder(),
                    activeColor: Theme.of(context).primaryColor,
                    value: task.isCompleted,
                    onChanged: (val) {
                      task.isCompleted = val ?? false;
                      HiveStorage.updateTask(task);
                      if (task.isCompleted) {
                        AdsService().showInterstitialIfReady();
                      }
                    },
                  ),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted ? Colors.grey : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            task.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (task.deadline != null)
                          Row(
                            children: [
                              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, h:mm a', locale).format(task.deadline!),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: _getPriorityIcon(task.priority),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getPriorityIcon(int priority) {
    Color color;
    switch (priority) {
      case 2:
        color = Colors.red;
        break;
      case 1:
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Text(
        '!',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final titleController = TextEditingController();
    final categoryController = TextEditingController();
    int priority = 0;
    DateTime? deadline;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.taskNewTask,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n.taskTitleHint,
                  prefixIcon: const Icon(Icons.check_circle_outline),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: l10n.taskCategory,
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: priority,
                      decoration: InputDecoration(
                        labelText: l10n.taskPriority,
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                      items: [
                        DropdownMenuItem(value: 0, child: Text(l10n.taskPriorityLow)),
                        DropdownMenuItem(value: 1, child: Text(l10n.taskPriorityMedium)),
                        DropdownMenuItem(value: 2, child: Text(l10n.taskPriorityHigh)),
                      ],
                      onChanged: (val) => setState(() => priority = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    locale: Localizations.localeOf(context),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        deadline = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        deadline == null
                            ? l10n.taskSetDeadline
                            : DateFormat('MMM d, h:mm a', locale).format(deadline!),
                        style: TextStyle(
                          color: deadline == null ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: deadline == null ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    final newTask = TaskModel.create(
                      title: titleController.text,
                      category: categoryController.text.isEmpty
                          ? l10n.taskDefaultCategory
                          : categoryController.text,
                      priority: priority,
                      deadline: deadline,
                    );
                    HiveStorage.addTask(newTask);
                    Navigator.pop(context);
                  }
                },
                child: Text(l10n.taskCreate),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension OnTapExtension on Widget {
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
