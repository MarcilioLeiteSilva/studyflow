import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../../data/local/hive_storage.dart';
import '../../data/models/pomodoro_session_model.dart';
import 'package:uuid/uuid.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/services/ads_service.dart';
import 'focus_mode_screen.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> with TickerProviderStateMixin {
  static const int focusTime = 25 * 60;
  static const int breakTime = 5 * 60;

  int timeLeft = focusTime;
  int totalTime = focusTime;
  bool isRunning = false;
  bool isFocusMode = true;
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Animation controller for pulsing effect
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    if (_timer != null) _timer!.cancel();
    setState(() => isRunning = true);
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        _completeSession();
      }
    });
  }

  void _pauseTimer() {
    if (_timer != null) _timer!.cancel();
    _pulseController.stop();
    setState(() => isRunning = false);
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      timeLeft = isFocusMode ? focusTime : breakTime;
      totalTime = timeLeft;
    });
  }

  void _completeSession() async {
    _pauseTimer();
    _playSound();
    
    // Check if mounted before accessing context for l10n
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    
    // Show notification
    NotificationService.showInstantNotification(
      title: isFocusMode ? l10n.pomoFocusComplete : l10n.pomoBreakComplete,
      body: isFocusMode ? l10n.pomoFocusMsg : l10n.pomoBreakMsg,
    );

    if (isFocusMode) {
      // Save session
      final session = PomodoroSessionModel(
        id: const Uuid().v4(),
        durationMinutes: 25,
        completedDate: DateTime.now(),
      );
      await HiveStorage.saveSession(session);
      
      // Show Ad on completion
      AdsService().showInterstitialIfReady();
      
      _showCompletionDialog(
        title: l10n.pomoFocusComplete,
        message: l10n.pomoFocusMsg,
        btnText: l10n.pomoBtnStartBreak,
        onPressed: () {
          Navigator.pop(context);
          setState(() {
            isFocusMode = false;
            timeLeft = breakTime;
            totalTime = breakTime;
          });
          _startTimer();
        },
      );
    } else {
      _showCompletionDialog(
        title: l10n.pomoBreakComplete,
        message: l10n.pomoBreakMsg,
        btnText: l10n.pomoBtnStartFocus,
        onPressed: () {
          Navigator.pop(context);
          setState(() {
            isFocusMode = true;
            timeLeft = focusTime;
            totalTime = focusTime;
          });
          _startTimer();
        },
      );
    }
  }

  void _showCompletionDialog({
    required String title,
    required String message,
    required String btnText,
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text(btnText),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  void _playSound() async {
    // In a real app, use local assets.
    // await _audioPlayer.play(AssetSource('sounds/bell.mp3'));
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;
    final modeColor = isFocusMode ? primaryColor : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pomoTitle),
        actions: [
          IconButton(
            icon: Icon(isFocusMode ? Icons.coffee : Icons.work),
            tooltip: l10n.pomoTooltipSwitch,
            onPressed: () {
              _pauseTimer();
              setState(() {
                isFocusMode = !isFocusMode;
                timeLeft = isFocusMode ? focusTime : breakTime;
                totalTime = timeLeft;
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: modeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isFocusMode ? '🔥 Focus Mode' : '☕ Break Time',
                  style: TextStyle(
                    fontSize: 20,
                    color: modeColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: CircularPercentIndicator(
                  radius: 140.0,
                  lineWidth: 20.0,
                  percent: (totalTime - timeLeft) / totalTime,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(timeLeft),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: modeColor,
                        ),
                      ),
                      Text(
                        isRunning ? 'Running' : 'Paused',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  progressColor: modeColor,
                  backgroundColor: modeColor.withValues(alpha: 0.1),
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animateFromLastPercent: true,
                  animationDuration: 1000,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.large(
                    heroTag: 'play_pause',
                    onPressed: isRunning ? _pauseTimer : _startTimer,
                    backgroundColor: modeColor,
                    child: Icon(
                      isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 30),
                  FloatingActionButton(
                    heroTag: 'reset',
                    onPressed: _resetTimer,
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade700,
                    child: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (isFocusMode && !isRunning)
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FocusModeScreen(
                          initialTime: timeLeft,
                          onSessionComplete: _completeSession,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('Enter Deep Focus Mode'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              const SizedBox(height: 20),
              if (isFocusMode)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    '"Stay focused, ignore distractions, and you will achieve your goals."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
