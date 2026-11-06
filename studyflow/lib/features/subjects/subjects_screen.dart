import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../../data/local/hive_storage.dart';
import '../../data/models/task_model.dart';
import '../planner/task_detail_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final List<String> _defaultSubjects = [
    'Matemática',
    'Português',
    'Geografia',
    'História',
    'Física',
    'Química',
    'Biologia',
    'Inglês',
    'Programação',
    'Direito',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.drawerSubjects,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveStorage.tasksBox.listenable(),
        builder: (context, Box<TaskModel> box, _) {
          final allTasks = box.values.toList();

          // Get all unique categories present in tasks plus defaults
          final taskCategories = allTasks.map((t) => t.category.trim()).where((c) => c.isNotEmpty).toSet();
          final subjectsSet = {...taskCategories, ..._defaultSubjects};
          final subjectsList = subjectsSet.toList()..sort();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.subjectsTitle,
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.subjectsSubtitle,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...subjectsList.map((subject) {
                final subjectTasks = allTasks.where((t) => t.category.toLowerCase() == subject.toLowerCase()).toList();
                final total = subjectTasks.length;
                final done = subjectTasks.where((t) => t.isCompleted).length;
                final progress = total > 0 ? (done / total) : 0.0;
                final color = _getSubjectColor(subject);
                final icon = _getSubjectIcon(subject);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _showSubjectTasks(context, subject, subjectTasks),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: color, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Text(
                                      '$done de $total concluídas',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withValues(alpha: 0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(l10n.subjectsAdd),
        onPressed: _addNewSubjectDialog,
      ),
    );
  }

  void _addNewSubjectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Matéria'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nome da Matéria / Disciplina',
            hintText: 'Ex: Literatura, Sociologia, Robótica',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                // Add a placeholder task for this new subject so it stays in Hive
                HiveStorage.addTask(TaskModel.create(
                  title: 'Começar estudos de $text',
                  category: text,
                  priority: 1,
                  deadline: DateTime.now().add(const Duration(days: 1)),
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Matéria "$text" criada com sucesso!')),
                );
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showSubjectTasks(BuildContext context, String subject, List<TaskModel> tasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    subject,
                    style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${tasks.length} tarefas',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text('Nenhuma tarefa cadastrada nesta matéria.', style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (val) {
                              task.isCompleted = val ?? false;
                              HiveStorage.updateTask(task);
                            },
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('mat') || s.contains('fís') || s.contains('fisi')) return Colors.blue;
    if (s.contains('port') || s.contains('redação') || s.contains('liter')) return Colors.red;
    if (s.contains('geo') || s.contains('bio') || s.contains('ecol')) return Colors.green;
    if (s.contains('hist') || s.contains('filo') || s.contains('soci')) return Colors.amber.shade800;
    if (s.contains('quím') || s.contains('quim')) return Colors.deepPurple;
    if (s.contains('ingl') || s.contains('idiom')) return Colors.teal;
    if (s.contains('prog') || s.contains('dev') || s.contains('comp')) return Colors.indigo;
    if (s.contains('dir') || s.contains('concur') || s.contains('oab')) return Colors.brown;
    return Colors.cyan;
  }

  IconData _getSubjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('mat') || s.contains('fís')) return Icons.calculate;
    if (s.contains('port') || s.contains('redação')) return Icons.edit_note;
    if (s.contains('geo')) return Icons.public;
    if (s.contains('hist')) return Icons.account_balance;
    if (s.contains('bio')) return Icons.eco;
    if (s.contains('quím')) return Icons.science;
    if (s.contains('ingl')) return Icons.translate;
    if (s.contains('prog')) return Icons.terminal;
    if (s.contains('dir') || s.contains('concur')) return Icons.gavel;
    return Icons.menu_book;
  }
}

