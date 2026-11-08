import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../../data/local/hive_storage.dart';
import '../../data/models/task_model.dart';
import '../../data/models/lesson_module_model.dart';
import '../voice_tutor/voice_tutor_lesson_screen.dart';
import '../pomodoro/focus_mode_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;
  late int _priority;
  DateTime? _deadline;
  late bool _isCompleted;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _categoryController = TextEditingController(text: widget.task.category);
    _notesController = TextEditingController(text: widget.task.notes);
    _priority = widget.task.priority;
    _deadline = widget.task.deadline;
    _isCompleted = widget.task.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      widget.task.title = _titleController.text;
      widget.task.category = _categoryController.text;
      widget.task.notes = _notesController.text;
      widget.task.priority = _priority;
      widget.task.deadline = _deadline;
      widget.task.isCompleted = _isCompleted;
      _isEditing = false;
    });

    HiveStorage.updateTask(widget.task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.taskUpdated)),
    );
  }

  void _deleteTask() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dialogDeleteTaskTitle),
        content: Text(l10n.dialogDeleteTaskContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () {
              HiveStorage.deleteTask(widget.task.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.btnDelete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_isEditing ? l10n.taskEdit : l10n.taskDetails),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveTask,
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCompleted 
                    ? Colors.green.withValues(alpha: 0.1) 
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isCompleted 
                      ? Colors.green.withValues(alpha: 0.3) 
                      : Colors.orange.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCompleted ? Icons.check_circle : Icons.pending,
                    color: _isCompleted ? Colors.green : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCompleted ? l10n.dashboardDone : l10n.dashboardPending,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isCompleted ? Colors.green : Colors.orange,
                          ),
                        ),
                        if (!_isCompleted && _deadline != null)
                          Text(
                            '${l10n.labelDue}${DateFormat('MMM d, h:mm a', locale).format(_deadline!)}',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isCompleted,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setState(() => _isCompleted = val);
                      if (!_isEditing) {
                         widget.task.isCompleted = val;
                         HiveStorage.updateTask(widget.task);
                      }
                    },
                  ),
                ],
              ),
            ),
            // Tutor de Voz Button se a tarefa tiver micro-aula e exercícios
            Builder(
              builder: (ctx) {
                final audioLesson = LessonModuleModel.fromTaskModel(widget.task);
                if (audioLesson == null) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.primaryColor.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.headphones, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Micro-Aula com Tutor de Voz',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              '${audioLesson.durationMinutes} min narrados • ${audioLesson.exercises.length} exercícios comentados',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VoiceTutorLessonScreen(
                                lesson: audioLesson,
                                parentTask: widget.task,
                              ),
                            ),
                          );
                        },
                        child: const Text('Ouvir Aula', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Title & Category
            _buildSectionTitle(l10n.sectionTaskInfo),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: l10n.labelTitle,
                    icon: Icons.title,
                    enabled: _isEditing,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _categoryController,
                          label: l10n.taskCategory,
                          icon: Icons.category,
                          enabled: _isEditing,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_isEditing)
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _priority,
                            decoration: InputDecoration(
                              labelText: l10n.taskPriority,
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: [
                              DropdownMenuItem(value: 0, child: Text(l10n.taskPriorityLow)),
                              DropdownMenuItem(value: 1, child: Text(l10n.taskPriorityMedium)),
                              DropdownMenuItem(value: 2, child: Text(l10n.taskPriorityHigh)),
                            ],
                            onChanged: (val) => setState(() => _priority = val!),
                          ),
                        )
                      else
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.flag, color: _getPriorityColor(_priority), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  _getPriorityLabel(_priority, l10n),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getPriorityColor(_priority),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Deadline
            _buildSectionTitle(l10n.sectionDeadline),
            const SizedBox(height: 12),
            InkWell(
              onTap: _isEditing
                  ? () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _deadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        locale: Localizations.localeOf(context),
                      );
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(_deadline ?? DateTime.now()),
                        );
                        if (time != null) {
                          setState(() {
                            _deadline = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          });
                        }
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.calendar_month, color: theme.primaryColor),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _deadline == null ? l10n.noDeadline : DateFormat('MMMM d, yyyy', locale).format(_deadline!),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (_deadline != null)
                          Text(
                            DateFormat('h:mm a', locale).format(_deadline!),
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                          ),
                      ],
                    ),
                    if (_isEditing) ...[
                      const Spacer(),
                      const Icon(Icons.edit, color: Colors.grey),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            _buildSectionTitle(l10n.sectionNotes),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildTextField(
                controller: _notesController,
                label: l10n.hintNotes,
                icon: Icons.notes,
                enabled: _isEditing,
                maxLines: 5,
                borderless: true,
              ),
            ),
            const SizedBox(height: 40),

            // Start Focus Session Button
            if (!_isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to Focus Mode
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FocusModeScreen(
                          initialTime: 25 * 60, // Default 25 minutes
                          onSessionComplete: () {
                            // Optional: Update task time spent or show completion message
                          },
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.timer),
                  label: Text(l10n.taskStartFocus),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool enabled = true,
    int maxLines = 1,
    bool borderless = false,
    TextStyle? style,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: style,
      decoration: InputDecoration(
        labelText: borderless ? null : label,
        hintText: borderless ? label : null,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: borderless ? InputBorder.none : const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        contentPadding: borderless ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: !enabled && !borderless,
        fillColor: enabled ? null : Colors.grey.withValues(alpha: 0.05),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2: return Colors.red;
      case 1: return Colors.orange;
      default: return Colors.green;
    }
  }

  String _getPriorityLabel(int priority, AppLocalizations l10n) {
    switch (priority) {
      case 2: return l10n.taskPriorityHigh;
      case 1: return l10n.taskPriorityMedium;
      default: return l10n.taskPriorityLow;
    }
  }
}
