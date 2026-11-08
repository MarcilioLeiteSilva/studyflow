import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/voice_tutor_service.dart';
import '../../data/local/hive_storage.dart';
import '../../data/models/lesson_module_model.dart';
import '../../data/models/task_model.dart';

class VoiceTutorLessonScreen extends StatefulWidget {
  final LessonModuleModel lesson;
  final TaskModel? parentTask;

  const VoiceTutorLessonScreen({
    super.key,
    required this.lesson,
    this.parentTask,
  });

  @override
  State<VoiceTutorLessonScreen> createState() => _VoiceTutorLessonScreenState();
}

class _VoiceTutorLessonScreenState extends State<VoiceTutorLessonScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VoiceTutorService _voiceTutor = VoiceTutorService();

  // Audio Lesson State
  bool _isPlayingLesson = false;
  double _currentSpeed = 0.5; // Natural standard

  // Exercises State
  int _currentExerciseIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _voiceTutor.initialize();

    _voiceTutor.onSpeechStart = () {
      if (mounted) setState(() => _isPlayingLesson = true);
    };

    _voiceTutor.onSpeechComplete = () {
      if (mounted) setState(() => _isPlayingLesson = false);
    };

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _voiceTutor.stop();
        if (mounted) setState(() => _isPlayingLesson = false);
      }
    });
  }

  @override
  void dispose() {
    _voiceTutor.stop();
    _tabController.dispose();
    super.dispose();
  }

  void _togglePlayLesson() {
    if (_isPlayingLesson) {
      _voiceTutor.pause();
      setState(() => _isPlayingLesson = false);
    } else {
      final textToSpeak = 'Aula de hoje: ${widget.lesson.title}. ${widget.lesson.summaryLesson}';
      _voiceTutor.speak(textToSpeak);
      setState(() => _isPlayingLesson = true);
    }
  }

  void _changeSpeed(double speed, double displayLabel) {
    setState(() => _currentSpeed = speed);
    _voiceTutor.setSpeedRate(speed);
    if (_isPlayingLesson) {
      _togglePlayLesson();
      _togglePlayLesson();
    }
  }

  void _speakCurrentQuestion() {
    if (widget.lesson.exercises.isEmpty) return;
    final exercise = widget.lesson.exercises[_currentExerciseIndex];
    final buffer = StringBuffer();
    buffer.write('Questão ${_currentExerciseIndex + 1}. ');
    buffer.write('${exercise.question}. ');
    for (int i = 0; i < exercise.options.length; i++) {
      buffer.write('Opção ${String.fromCharCode(65 + i)}: ${exercise.options[i]}. ');
    }
    _voiceTutor.speak(buffer.toString());
  }

  void _selectOption(int index) {
    if (_hasAnswered) return;
    final exercise = widget.lesson.exercises[_currentExerciseIndex];
    final isCorrect = index == exercise.correctIndex;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;
      if (isCorrect) _correctCount++;
    });

    // Tutor de voz comenta a resposta em áudio!
    final feedbackBuffer = StringBuffer();
    if (isCorrect) {
      feedbackBuffer.write('Muito bem! Resposta correta! ');
    } else {
      final chosenLetter = String.fromCharCode(65 + index);
      final correctLetter = String.fromCharCode(65 + exercise.correctIndex);
      feedbackBuffer.write('Você escolheu a opção $chosenLetter, mas a resposta correta é a $correctLetter. ');
    }
    feedbackBuffer.write(exercise.explanation);

    _voiceTutor.speak(feedbackBuffer.toString());
  }

  void _nextExercise() {
    _voiceTutor.stop();
    if (_currentExerciseIndex < widget.lesson.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _selectedOptionIndex = null;
        _hasAnswered = false;
      });
      // Speak next question automatically
      _speakCurrentQuestion();
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.stars, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Aula Concluída!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parabéns! Você concluiu a micro-aula de ${widget.lesson.durationMinutes} minutos e respondeu aos exercícios de fixação.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Desempenho nos Exercícios:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(
                    '$_correctCount de ${widget.lesson.exercises.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Fechar'),
          ),
          if (widget.parentTask != null && !widget.parentTask!.isCompleted)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                widget.parentTask!.isCompleted = true;
                HiveStorage.updateTask(widget.parentTask!);
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tarefa marcada como concluída no seu planejador!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Marcar Concluída', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.lesson.title,
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${widget.lesson.category} • ${widget.lesson.durationMinutes} min de foco',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.headphones), text: 'Micro-Aula de Voz'),
            Tab(icon: Icon(Icons.quiz), text: 'Exercícios Comentados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAudioLessonTab(primaryColor),
          _buildExercisesTab(primaryColor),
        ],
      ),
    );
  }

  // ================= TAB 1: MICRO-AULA NARRADA =================
  Widget _buildAudioLessonTab(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Player Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isPlayingLesson ? Icons.graphic_eq : Icons.headphones,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.lesson.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isPlayingLesson ? 'Tutor narrando a aula...' : 'Pressione Play para ouvir seu tutor',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
                const SizedBox(height: 20),
                // Play / Pause Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.replay_10, color: Colors.white),
                      onPressed: () {
                        _voiceTutor.stop();
                        _togglePlayLesson();
                      },
                      tooltip: 'Reiniciar Aula',
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _togglePlayLesson,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlayingLesson ? Icons.pause : Icons.play_arrow,
                          color: primaryColor,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
                      onPressed: () {
                        _voiceTutor.stop();
                        setState(() => _isPlayingLesson = false);
                      },
                      tooltip: 'Parar Áudio',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Speed Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _speedPill('1.0x', 0.5),
                    const SizedBox(width: 8),
                    _speedPill('1.25x', 0.6),
                    const SizedBox(width: 8),
                    _speedPill('1.5x', 0.7),
                    const SizedBox(width: 8),
                    _speedPill('2.0x', 0.9),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Lesson Script Card
          Row(
            children: const [
              Icon(Icons.menu_book, size: 20, color: Colors.grey),
              SizedBox(width: 8),
              Text('Transcrição e Pontos-Chave da Aula', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: Text(
              widget.lesson.summaryLesson,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ),

          const SizedBox(height: 24),

          // Forward to Exercises button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            label: const Text('Praticar com Exercícios de Fixação', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              _tabController.animateTo(1);
              Future.delayed(const Duration(milliseconds: 300), _speakCurrentQuestion);
            },
          ),
        ],
      ),
    );
  }

  Widget _speedPill(String label, double speed) {
    final isSelected = (_currentSpeed - speed).abs() < 0.05;
    return GestureDetector(
      onTap: () => _changeSpeed(speed, speed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // ================= TAB 2: EXERCÍCIOS COMENTADOS POR VOZ =================
  Widget _buildExercisesTab(Color primaryColor) {
    if (widget.lesson.exercises.isEmpty) {
      return const Center(child: Text('Nenhum exercício gerado para esta aula.'));
    }

    final exercise = widget.lesson.exercises[_currentExerciseIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step Counter & Voice Read Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Questão ${_currentExerciseIndex + 1} de ${widget.lesson.exercises.length}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.volume_up, size: 16),
                label: const Text('Ouvir Questão', style: TextStyle(fontSize: 12)),
                onPressed: _speakCurrentQuestion,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Question Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(color: primaryColor.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Text(
              exercise.question,
              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),

          const SizedBox(height: 20),

          // Options A, B, C, D
          ...List.generate(exercise.options.length, (index) {
            final optionText = exercise.options[index];
            final letter = String.fromCharCode(65 + index);
            final isChosen = _selectedOptionIndex == index;
            final isCorrect = exercise.correctIndex == index;

            Color borderColor = Colors.grey.withValues(alpha: 0.2);
            Color bgColor = Theme.of(context).cardColor;
            Widget? trailingIcon;

            if (_hasAnswered) {
              if (isCorrect) {
                borderColor = Colors.green;
                bgColor = Colors.green.withValues(alpha: 0.1);
                trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
              } else if (isChosen) {
                borderColor = Colors.red;
                bgColor = Colors.red.withValues(alpha: 0.1);
                trailingIcon = const Icon(Icons.cancel, color: Colors.red);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _hasAnswered ? null : () => _selectOption(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: isChosen || (_hasAnswered && isCorrect) ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isChosen ? primaryColor : Colors.grey.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: isChosen ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (trailingIcon != null) trailingIcon,
                    ],
                  ),
                ),
              ),
            );
          }),

          // Feedback & Explanation Box
          if (_hasAnswered) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedOptionIndex == exercise.correctIndex
                    ? Colors.green.withValues(alpha: 0.08)
                    : Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedOptionIndex == exercise.correctIndex
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.amber.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedOptionIndex == exercise.correctIndex ? Icons.check_circle : Icons.lightbulb,
                        color: _selectedOptionIndex == exercise.correctIndex ? Colors.green : Colors.amber.shade800,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Comentário do Tutor de Voz:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: _selectedOptionIndex == exercise.correctIndex ? Colors.green : Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exercise.explanation,
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _nextExercise,
              child: Text(
                _currentExerciseIndex < widget.lesson.exercises.length - 1 ? 'Próxima Questão ➔' : 'Finalizar Aula 🏁',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
