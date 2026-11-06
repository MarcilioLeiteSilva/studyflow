import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../data/local/hive_storage.dart';
import '../../data/local/premade_local_plans.dart';
import '../../data/models/task_model.dart';
import '../config/ai_config.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  String get backendUrl =>
      HiveStorage.getSetting('backendUrl', defaultValue: AIConfig.defaultBackendUrl) as String;

  String get customApiKey =>
      HiveStorage.getSetting('customApiKey', defaultValue: '') as String;

  // 1. Planos Locais Embarcados (Offline)
  List<PremadeLocalPlan> getEmbeddedPlans() {
    return PremadeLocalPlans.embeddedPlans;
  }

  // 2. Buscar Planos Remotos no Backend
  Future<List<Map<String, dynamic>>> fetchRemotePlans() async {
    try {
      final uri = Uri.parse('$backendUrl/api/plans');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['plans'] is List) {
          return List<Map<String, dynamic>>.from(data['plans']);
        }
      }
    } catch (_) {
      // Backend inacessível ou offline
    }
    return [];
  }

  // 3. Baixar Plano Remoto do Backend e converter em Tarefas
  Future<List<TaskModel>> downloadRemotePlan(String planId, {DateTime? startDate}) async {
    try {
      final uri = Uri.parse('$backendUrl/api/plans/$planId');
      final response = await http.get(uri).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['plan'] != null) {
          final tasksJson = data['plan']['tasks'] as List<dynamic>? ?? [];
          final baseDate = startDate ?? DateTime.now();

          return tasksJson.map((t) {
            final offset = (t['dayOffset'] as num?)?.toInt() ?? 0;
            final deadline = baseDate.add(Duration(days: offset));
            final priorityInt = (t['priority'] as num?)?.toInt() ?? 1;

            return TaskModel.create(
              title: t['title']?.toString() ?? 'Tarefa',
              category: t['category']?.toString() ?? 'Geral',
              priority: priorityInt,
              deadline: deadline,
            );
          }).toList();
        }
      }
    } catch (e) {
      // Falha ao baixar do backend
    }
    return [];
  }

  // 4. Geração Inteligente com Hierarquia (Chave do Usuário -> Backend -> Fallback Offline)
  Future<List<TaskModel>> generateStudyPlan({
    required String subjects,
    required DateTime examDate,
    required String languageCode,
  }) async {
    final now = DateTime.now();
    final daysUntilExam = examDate.difference(now).inDays;

    final prompt = '''
Atue como um tutor acadêmico especialista. Crie um plano de estudos estruturado para as seguintes disciplinas: $subjects.
A prova será em ${DateFormat('yyyy-MM-dd').format(examDate)} (em $daysUntilExam dias).
Requisitos:
1. Retorne APENAS um JSON válido bruto (sem markdown, sem crases ```).
2. Uma lista de objetos com os campos:
   - "title": Título curto da tarefa (traduzido para o idioma: $languageCode)
   - "category": Nome da disciplina correspondente
   - "priority": "High", "Medium" ou "Low"
   - "days_from_now": Número inteiro de dias a partir de hoje (0 para hoje, 1 para amanhã, etc.)
Exemplo:
[
  {"title": "Revisar Álgebra Básica", "category": "Matemática", "priority": "High", "days_from_now": 0},
  {"title": "Leitura Capítulo 1", "category": "História", "priority": "Medium", "days_from_now": 1}
]
''';

    // Rota A: Usuário configurou chave própria nos Ajustes
    if (customApiKey.trim().isNotEmpty) {
      final key = customApiKey.trim();
      try {
        if (key.startsWith('AIza')) {
          // Google Gemini Direct
          final geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$key';
          final res = await http.post(
            Uri.parse(geminiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [{'parts': [{'text': prompt}]}],
              'generationConfig': {'temperature': 0.7}
            }),
          ).timeout(const Duration(seconds: 15));

          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            final raw = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
            return _parseTasksJson(raw, now);
          }
        } else {
          // OpenRouter Direct
          final res = await http.post(
            Uri.parse(AIConfig.openRouterUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $key',
              'HTTP-Referer': AIConfig.siteUrl,
              'X-Title': AIConfig.appName,
            },
            body: jsonEncode({
              'model': AIConfig.defaultModelId,
              'messages': [{'role': 'user', 'content': prompt}],
              'temperature': 0.7,
            }),
          ).timeout(const Duration(seconds: 15));

          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            final raw = data['choices']?[0]?['message']?['content'] ?? '';
            return _parseTasksJson(raw, now);
          }
        }
      } catch (_) {
        // Fall through para o backend ou local
      }
    }

    // Rota B: Chamar o Backend com a chave protegida do servidor
    try {
      final res = await http.post(
        Uri.parse('$backendUrl/api/plans/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subjects': subjects,
          'examDate': examDate.toIso8601String(),
          'languageCode': languageCode,
        }),
      ).timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['tasks'] is List) {
          final list = data['tasks'] as List;
          return list.map((json) {
            final days = (json['days_from_now'] as num?)?.toInt() ?? 0;
            final taskDate = now.add(Duration(days: days));
            int priorityInt = 1;
            final p = json['priority']?.toString().toLowerCase() ?? '';
            if (p.contains('high')) {
              priorityInt = 2;
            } else if (p.contains('low')) {
              priorityInt = 0;
            }

            return TaskModel.create(
              title: json['title']?.toString() ?? 'Tarefa',
              category: json['category']?.toString() ?? 'Geral',
              priority: priorityInt,
              deadline: taskDate,
            );
          }).toList();
        }
      }
    } catch (_) {
      // Backend offline ou falhou
    }

    // Rota C: Fallback Local Heurístico 100% Offline
    return _generateLocalPlan(subjects, examDate, languageCode);
  }

  List<TaskModel> _parseTasksJson(String raw, DateTime now) {
    final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final List<dynamic> jsonTasks = jsonDecode(clean);
    return jsonTasks.map((json) {
      final days = (json['days_from_now'] as num?)?.toInt() ?? 0;
      final taskDate = now.add(Duration(days: days));
      int priorityInt = 1;
      final p = json['priority']?.toString().toLowerCase() ?? '';
      if (p.contains('high')) {
        priorityInt = 2;
      } else if (p.contains('low')) {
        priorityInt = 0;
      }

      return TaskModel.create(
        title: json['title']?.toString() ?? 'Tarefa',
        category: json['category']?.toString() ?? 'Geral',
        priority: priorityInt,
        deadline: taskDate,
      );
    }).toList();
  }

  // Fallback Logic: Offline Rule-Based Generation
  List<TaskModel> _generateLocalPlan(String subjects, DateTime examDate, String languageCode) {
    final now = DateTime.now();
    final daysUntilExam = examDate.difference(now).inDays;
    final subjectList = subjects.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    if (subjectList.isEmpty) return [];

    List<TaskModel> tasks = [];
    const int tasksPerDay = 3;

    for (int i = 0; i <= daysUntilExam && i < 30; i++) {
      final date = now.add(Duration(days: i));

      for (int j = 0; j < tasksPerDay; j++) {
        final subject = subjectList[(i + j) % subjectList.length];
        String title = '';
        int priority = 1;

        if (i == 0) {
          title = _getLocalizedStartReview(languageCode, subject);
          priority = 2;
        } else if (i == daysUntilExam - 1) {
          title = _getLocalizedFinalRevision(languageCode, subject);
          priority = 2;
        } else {
          title = _getLocalizedStudyChapter(languageCode, subject, (i % 5) + 1);
          priority = 1;
        }

        tasks.add(TaskModel.create(
          title: title,
          category: subject,
          priority: priority,
          deadline: date,
        ));
      }
    }
    return tasks;
  }

  String _getLocalizedStartReview(String code, String subject) {
    if (code.startsWith('pt')) return 'Comece a revisar os conceitos básicos de $subject';
    if (code.startsWith('es')) return 'Comienza a repasar conceptos básicos de $subject';
    return 'Start reviewing $subject basic concepts';
  }

  String _getLocalizedFinalRevision(String code, String subject) {
    if (code.startsWith('pt')) return 'Revisão final de $subject';
    if (code.startsWith('es')) return 'Revisión final para $subject';
    return 'Final revision for $subject';
  }

  String _getLocalizedStudyChapter(String code, String subject, int chapter) {
    if (code.startsWith('pt')) return 'Estude o Capítulo $chapter de $subject';
    if (code.startsWith('es')) return 'Estudiar Capítulo $chapter de $subject';
    return 'Study Chapter $chapter of $subject';
  }
}
