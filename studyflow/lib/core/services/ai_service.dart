import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../data/local/hive_storage.dart';
import '../../data/local/premade_local_plans.dart';
import '../../data/models/task_model.dart';
import '../../data/models/lesson_module_model.dart';
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

  // 5. Geração de Micro-Aulas com Tutor de Voz a partir de Documento / Ementa
  Future<List<LessonModuleModel>> generatePlanFromDocument({
    required String contentText,
    int durationMinutes = 10,
    String methodology = 'teoria_exercicios',
    int lessonsCount = 5,
    String languageCode = 'pt',
  }) async {
    final prompt = '''
Você é um Tutor Acadêmico de Áudio especialista em microlearning e fixação de aprendizado.
Analise com rigor o seguinte conteúdo/ementa/documento e crie exatamente $lessonsCount micro-aulas narradas (cada uma com $durationMinutes minutos de duração estimada) e exercícios de fixação comentados.

CONTEÚDO DO DOCUMENTO:
$contentText

REQUISITOS IMPORTANTES:
1. Retorne APENAS um JSON válido bruto (sem crases ``` nem markdown).
2. O formato deve ser um array de objetos:
[
  {
    "id": "aula_1",
    "title": "Título conciso da micro-aula",
    "category": "Nome da disciplina ou tópico",
    "durationMinutes": $durationMinutes,
    "summaryLesson": "Texto completo, didático e envolvente da aula, escrito em tom de fala natural de professor explicando diretamente ao aluno para ser lido pelo leitor de voz. Use analogias, exemplos práticos e resuma as regras fundamentais.",
    "exercises": [
      {
        "question": "Enunciado claro da questão sobre o que acabou de ser ensinado",
        "options": ["Opção A", "Opção B", "Opção C", "Opção D"],
        "correctIndex": 0,
        "explanation": "Comentário falado pelo tutor justificando por que a opção está correta e alertando sobre as armadilhas das opções incorretas."
      }
    ]
  }
]
''';

    // Rota A: Chave Própria (BYOK)
    if (customApiKey.trim().isNotEmpty) {
      final key = customApiKey.trim();
      try {
        if (key.startsWith('AIza')) {
          final geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$key';
          final res = await http.post(
            Uri.parse(geminiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [{'parts': [{'text': prompt}]}],
              'generationConfig': {'temperature': 0.7}
            }),
          ).timeout(const Duration(seconds: 20));

          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            final raw = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
            return _parseLessonsJson(raw);
          }
        } else {
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
          ).timeout(const Duration(seconds: 20));

          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            final raw = data['choices']?[0]?['message']?['content'] ?? '';
            return _parseLessonsJson(raw);
          }
        }
      } catch (_) {}
    }

    // Rota B: Backend da VPS
    try {
      final res = await http.post(
        Uri.parse('$backendUrl/api/plans/generate-from-doc'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contentText': contentText,
          'durationMinutes': durationMinutes,
          'methodology': methodology,
          'lessonsCount': lessonsCount,
          'languageCode': languageCode,
        }),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['lessons'] is List) {
          final list = data['lessons'] as List;
          return list.map((e) => LessonModuleModel.fromJson(Map<String, dynamic>.from(e))).toList();
        }
      }
    } catch (_) {}

    // Rota C: Fallback Local Estruturado
    return _generateLocalLessons(contentText, lessonsCount, durationMinutes);
  }

  List<LessonModuleModel> _parseLessonsJson(String raw) {
    final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();
    final List<dynamic> list = jsonDecode(clean);
    return list.map((e) => LessonModuleModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  List<LessonModuleModel> _generateLocalLessons(String content, int count, int duration) {
    final lines = content.split('\n').where((l) => l.trim().length > 3).toList();
    final List<LessonModuleModel> lessons = [];

    for (int i = 0; i < count; i++) {
      final topic = i < lines.length ? lines[i].trim() : 'Tópico Fundamental ${i + 1}';
      lessons.add(
        LessonModuleModel(
          id: 'local_mod_${i + 1}',
          title: topic.length > 40 ? '${topic.substring(0, 37)}...' : topic,
          category: 'Estudo Focado',
          durationMinutes: duration,
          summaryLesson: 'Olá! Nesta micro-aula de $duration minutos, vamos focar em $topic. '
              'Este conteúdo é essencial para a sua preparação. A ideia principal aqui é compreender as bases '
              'estruturais e aplicá-las em questões práticas com atenção aos detalhes e conceitos fundamentais.',
          exercises: [
            LessonExercise(
              question: 'Com base no conceito de $topic, qual é a alternativa correta?',
              options: [
                'A compreensão dos fundamentos é essencial para resolução de problemas.',
                'O tema é irrelevante e não exige atenção do estudante.',
                'Não é necessário praticar exercícios para fixar este conteúdo.',
                'A teoria pode ser ignorada em exames e testes práticos.',
              ],
              correctIndex: 0,
              explanation: 'A alternativa A está correta porque a base teórica estruturada é indispensável para resolver questões e fixar o conhecimento de forma duradoura.',
            ),
          ],
        ),
      );
    }
    return lessons;
  }
}
