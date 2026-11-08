import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/ai_service.dart';
import '../../data/local/hive_storage.dart';
import '../../data/models/lesson_module_model.dart';
import 'voice_tutor_lesson_screen.dart';

class DocumentPlanCreatorScreen extends StatefulWidget {
  const DocumentPlanCreatorScreen({super.key});

  @override
  State<DocumentPlanCreatorScreen> createState() => _DocumentPlanCreatorScreenState();
}

class _DocumentPlanCreatorScreenState extends State<DocumentPlanCreatorScreen> {
  final TextEditingController _contentController = TextEditingController();
  String? _pickedFileName;
  int _pickedFileSize = 0;

  int _durationMinutes = 10;
  String _methodology = 'teoria_exercicios';
  int _lessonsCount = 4;

  bool _isLoading = false;
  String _loadingMessage = '';
  List<LessonModuleModel>? _generatedLessons;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'md', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _pickedFileName = result.files.single.name;
          _pickedFileSize = result.files.single.size;
        });

        // Se for arquivo de texto, carrega o conteúdo direto
        final ext = _pickedFileName!.split('.').last.toLowerCase();
        if (ext == 'txt' || ext == 'md') {
          final content = await file.readAsString();
          _contentController.text = content;
        } else if (ext == 'pdf') {
          // Para PDF, adiciona metadados informativos
          if (_contentController.text.trim().isEmpty) {
            _contentController.text = 'Arquivo selecionado: $_pickedFileName (${(_pickedFileSize / 1024).toStringAsFixed(1)} KB).\n\nConteúdo Programático: Analisar os tópicos principais e fatiar em micro-aulas narradas de $_durationMinutes minutos com exercícios comentados.';
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar arquivo: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _fillSample(String type) {
    if (type == 'oab') {
      _contentController.text = '''
Conteúdo Programático - Direito Constitucional:
1. Princípios Fundamentais da República (Art. 1º ao 4º CF/88)
2. Direitos e Deveres Individuais e Coletivos (Art. 5º CF/88)
3. Remédios Constitucionais (Habeas Corpus, Mandado de Segurança, Ação Popular)
4. Controle de Constitucionalidade (ADI, ADC e ADPF)
''';
    } else if (type == 'enem') {
      _contentController.text = '''
Conteúdo Programático - Ecologia e Meio Ambiente (ENEM):
1. Cadeias e Teias Alimentares, Níveis Tróficos e Fluxo de Energia
2. Ciclos Biogeoquímicos: Carbono, Nitrogênio e Ciclo da Água
3. Dinâmica das Populações e Relações Ecológicas (Harmônicas e Desarmônicas)
4. Impactos Ambientais: Efeito Estufa, Eutrofização e Poluição por Plásticos
''';
    } else if (type == 'dev') {
      _contentController.text = '''
Ementa - Fundamentos de Arquitetura de Software:
1. Princípios SOLID e Programação Limpa (Clean Code)
2. Arquitetura em Camadas vs. Clean Architecture
3. Padrões de Projeto: Singleton, Factory e Repository
4. Testes Automatizados: Pirâmide de Testes e TDD
''';
    }
  }

  Future<void> _generatePlan() async {
    final text = _contentController.text.trim();
    if (text.isEmpty && _pickedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um arquivo ou cole o conteúdo da ementa.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Analisando conteúdo programático...';
      _generatedLessons = null;
    });

    try {
      final lessons = await AIService().generatePlanFromDocument(
        contentText: text,
        durationMinutes: _durationMinutes,
        methodology: _methodology,
        lessonsCount: _lessonsCount,
      );

      setState(() {
        _generatedLessons = lessons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar plano: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _applyAllToPlanner() {
    if (_generatedLessons == null || _generatedLessons!.isEmpty) return;

    final now = DateTime.now();
    for (int i = 0; i < _generatedLessons!.length; i++) {
      final lesson = _generatedLessons![i];
      final task = lesson.toTaskModel(
        deadline: now.add(Duration(days: i)),
        priority: 1,
      );
      HiveStorage.addTask(task);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_generatedLessons!.length} micro-aulas com áudio e exercícios adicionadas ao seu planejador!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _openLesson(LessonModuleModel lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VoiceTutorLessonScreen(lesson: lesson),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor de Voz por Arquivo / Edital'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.record_voice_over, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Crie Aulas Narradas com IA',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Envie seu edital ou conteúdo e ouça seu tutor dar a aula e comentar os exercícios!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Step 1: File Upload Box
            const Text(
              '1. Envie um Arquivo ou Cole o Conteúdo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),

            // Upload Button
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _pickedFileName != null ? Icons.check_circle : Icons.upload_file,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pickedFileName ?? 'Selecionar PDF, DOC ou TXT',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _pickedFileName != null ? Colors.green.shade800 : Colors.black87,
                            ),
                          ),
                          Text(
                            _pickedFileName != null
                                ? '${(_pickedFileSize / 1024).toStringAsFixed(1)} KB selecionados'
                                : 'Edital de concurso, ementa ou apostila',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _pickedFileName != null ? Icons.edit : Icons.add_circle_outline,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Fast sample chips
            Row(
              children: [
                const Text('Ou teste com:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(width: 8),
                _sampleChip('OAB Direito', () => _fillSample('oab')),
                const SizedBox(width: 6),
                _sampleChip('ENEM Biologia', () => _fillSample('enem')),
                const SizedBox(width: 6),
                _sampleChip('Software', () => _fillSample('dev')),
              ],
            ),

            const SizedBox(height: 10),

            // Text Area
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Cole aqui o conteúdo programático, tópicos da ementa ou matérias...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
            ),

            const SizedBox(height: 24),

            // Step 2: Methodology Settings
            const Text(
              '2. Como Você Quer Estudar?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),

            // Format Selection (10m vs 20m)
            Row(
              children: [
                Expanded(
                  child: _optionCard(
                    icon: Icons.bolt,
                    title: 'Micro-Aulas de 10 min',
                    subtitle: 'Direto ao ponto, ritmo leve',
                    isSelected: _durationMinutes == 10,
                    onTap: () => setState(() => _durationMinutes = 10),
                    primaryColor: primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _optionCard(
                    icon: Icons.timer,
                    title: 'Aulas de 20 min',
                    subtitle: 'Maior aprofundamento',
                    isSelected: _durationMinutes == 20,
                    onTap: () => setState(() => _durationMinutes = 20),
                    primaryColor: primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Lessons count selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quantidade de Aulas:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  DropdownButton<int>(
                    value: _lessonsCount,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3 Micro-Aulas')),
                      DropdownMenuItem(value: 4, child: Text('4 Micro-Aulas')),
                      DropdownMenuItem(value: 5, child: Text('5 Micro-Aulas')),
                      DropdownMenuItem(value: 7, child: Text('7 Micro-Aulas')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _lessonsCount = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              onPressed: _isLoading ? null : _generatePlan,
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Text(_loadingMessage, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.auto_awesome, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Gerar Plano com Tutor de Voz',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
            ),

            // Generated Results List
            if (_generatedLessons != null && _generatedLessons!.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_generatedLessons!.length} Micro-Aulas Geradas',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.playlist_add_check, size: 20),
                    label: const Text('Salvar no Planejador', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _applyAllToPlanner,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ..._generatedLessons!.asMap().entries.map((entry) {
                final idx = entry.key;
                final lesson = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '#${idx + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                    ),
                    title: Text(
                      lesson.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.headphones, size: 14, color: Colors.purple.shade400),
                            const SizedBox(width: 4),
                            Text('${lesson.durationMinutes} min narrados', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(width: 12),
                            Icon(Icons.quiz, size: 14, color: Colors.teal.shade400),
                            const SizedBox(width: 4),
                            Text('${lesson.exercises.length} exercícios comentados', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _openLesson(lesson),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.play_arrow, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Ouvir', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sampleChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? primaryColor : Colors.grey, size: 22),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? primaryColor : Colors.black87)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
