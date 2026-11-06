import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../../core/services/ai_service.dart';
import '../../data/local/hive_storage.dart';
import '../../data/local/premade_local_plans.dart';
import '../../data/models/task_model.dart';

class AIRoutineScreen extends StatefulWidget {
  const AIRoutineScreen({super.key});

  @override
  State<AIRoutineScreen> createState() => _AIRoutineScreenState();
}

class _AIRoutineScreenState extends State<AIRoutineScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  DateTime? _examDate;
  bool _isGenerating = false;
  List<TaskModel> _generatedPlan = [];

  // Remote plans state
  bool _isLoadingRemote = true;
  List<Map<String, dynamic>> _remotePlans = [];
  String? _downloadingPlanId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRemotePlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _loadRemotePlans() async {
    setState(() => _isLoadingRemote = true);
    final plans = await AIService().fetchRemotePlans();
    if (mounted) {
      setState(() {
        _remotePlans = plans;
        _isLoadingRemote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.aiTitle,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(icon: const Icon(Icons.library_books), text: l10n.aiTabPremade),
            Tab(icon: const Icon(Icons.auto_awesome), text: l10n.aiTabCustom),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPremadeCatalogTab(l10n),
          _buildCustomAITab(l10n),
        ],
      ),
    );
  }

  // ================= TAB 1: CATÁLOGO DE PLANOS PRONTOS =================
  Widget _buildPremadeCatalogTab(AppLocalizations l10n) {
    final embeddedPlans = AIService().getEmbeddedPlans();

    return RefreshIndicator(
      onRefresh: _loadRemotePlans,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // SEÇÃO 1: EMBARCADOS OFFLINE
          Row(
            children: [
              const Icon(Icons.offline_pin, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.aiSectionEmbedded,
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...embeddedPlans.map((plan) => _buildEmbeddedPlanCard(plan, l10n)),

          const SizedBox(height: 24),

          // SEÇÃO 2: DISPONÍVEIS PARA DOWNLOAD (NUVEM / BACKEND)
          Row(
            children: [
              const Icon(Icons.cloud_download, color: Colors.blueAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.aiSectionDownloadable,
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _loadRemotePlans,
                tooltip: 'Atualizar',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingRemote)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_remotePlans.isEmpty)
            Card(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text(
                      'Backend não conectado no momento.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Os 3 planos acima funcionam 100% offline. Para baixar novos planos, inicie o backend na porta 3000.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ..._remotePlans.map((plan) => _buildRemotePlanCard(plan, l10n)),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmbeddedPlanCard(PremadeLocalPlan plan, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    plan.category,
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                const Text('Offline', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.title,
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              plan.description,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${plan.durationDays} dias', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.task_alt, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${plan.items.length} tarefas', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_task),
                label: Text(l10n.aiBtnApplyPlan),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _applyEmbeddedPlan(plan, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemotePlanCard(Map<String, dynamic> plan, AppLocalizations l10n) {
    final String id = plan['id']?.toString() ?? '';
    final String title = plan['title']?.toString() ?? '';
    final String category = plan['category']?.toString() ?? 'Geral';
    final String description = plan['description']?.toString() ?? '';
    final int durationDays = (plan['durationDays'] as num?)?.toInt() ?? 30;
    final int totalTasks = (plan['totalTasks'] as num?)?.toInt() ?? 10;
    final bool isDownloading = _downloadingPlanId == id;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.cloud_done, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 4),
                const Text('Nuvem', style: TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$durationDays dias', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 16),
                const Icon(Icons.task_alt, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$totalTasks tarefas', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: isDownloading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download),
                label: Text(isDownloading ? l10n.aiDownloading : l10n.aiBtnDownloadPlan),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isDownloading ? null : () => _downloadAndApplyRemotePlan(id, title, l10n),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyEmbeddedPlan(PremadeLocalPlan plan, AppLocalizations l10n) {
    final tasks = plan.toTaskModels(startDate: DateTime.now());
    for (final task in tasks) {
      HiveStorage.addTask(task);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plano "${plan.title}" aplicado! ${tasks.length} tarefas agendadas.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _downloadAndApplyRemotePlan(String planId, String title, AppLocalizations l10n) async {
    setState(() => _downloadingPlanId = planId);
    final tasks = await AIService().downloadRemotePlan(planId);
    setState(() => _downloadingPlanId = null);

    if (tasks.isNotEmpty) {
      for (final task in tasks) {
        HiveStorage.addTask(task);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plano "$title" baixado com sucesso! ${tasks.length} tarefas agendadas.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao baixar plano. Verifique a conexão com o servidor.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ================= TAB 2: GERADOR PERSONALIZADO COM IA =================
  Widget _buildCustomAITab(AppLocalizations l10n) {
    final customKey = AIService().customApiKey;
    final hasCustomKey = customKey.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: hasCustomKey
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasCustomKey ? Colors.green.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasCustomKey ? Icons.vpn_key : Icons.dns,
                  size: 18,
                  color: hasCustomKey ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasCustomKey ? l10n.aiStatusCustomKey : l10n.aiStatusBackend,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: hasCustomKey ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildInputSection(l10n),
          const SizedBox(height: 24),
          if (_isGenerating)
            const Center(child: CircularProgressIndicator())
          else if (_generatedPlan.isNotEmpty)
            _buildPlanSection(l10n),
        ],
      ),
    );
  }

  Widget _buildInputSection(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aiGenerateTitle,
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: l10n.aiInputSubjects,
                  hintText: l10n.aiInputSubjectsHint,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.menu_book),
                ),
                validator: (value) => value!.isEmpty ? l10n.snackEnterSubjects : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.aiInputExamDate,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _examDate == null
                        ? l10n.aiInputDateSelect
                        : DateFormat('MMM d, yyyy', locale).format(_examDate!),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generatePlan,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(l10n.aiBtnGenerate, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanSection(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.aiResultTitle,
          style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _generatedPlan.length,
            itemBuilder: (context, index) {
              final task = _generatedPlan[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColorForPriority(task.priority).withValues(alpha: 0.1),
                          child: Icon(Icons.assignment, color: _getColorForPriority(task.priority)),
                        ),
                        title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${task.deadline != null ? DateFormat('MMM d', locale).format(task.deadline!) : 'No Date'} • ${task.category}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                          onPressed: () => _addToPlanner(task),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _addAllToPlanner,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
            child: Text(l10n.aiBtnAddAll),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: Localizations.localeOf(context),
    );
    if (picked != null) {
      setState(() => _examDate = picked);
    }
  }

  void _generatePlan() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    if (!_formKey.currentState!.validate() || _examDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackEnterSubjects)),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final plan = await AIService().generateStudyPlan(
        subjects: _subjectController.text,
        examDate: _examDate!,
        languageCode: locale,
      );

      setState(() {
        _generatedPlan = plan;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.aiError(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToPlanner(TaskModel task) {
    final l10n = AppLocalizations.of(context)!;
    HiveStorage.addTask(task);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.snackAddedTask(task.title))),
    );
  }

  void _addAllToPlanner() {
    final l10n = AppLocalizations.of(context)!;
    for (var task in _generatedPlan) {
      HiveStorage.addTask(task);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.snackAddedAll(_generatedPlan.length))),
    );
    Navigator.pop(context);
  }

  Color _getColorForPriority(int priority) {
    switch (priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 0:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
