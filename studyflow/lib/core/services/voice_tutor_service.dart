import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TutorVoiceState { stopped, playing, paused }

class VoiceTutorService {
  static final VoiceTutorService _instance = VoiceTutorService._internal();
  factory VoiceTutorService() => _instance;
  VoiceTutorService._internal();

  final FlutterTts _tts = FlutterTts();
  TutorVoiceState _state = TutorVoiceState.stopped;
  double _speechRate = 0.5; // Standard natural pace
  String _currentLanguage = 'pt-BR';
  bool _isInitialized = false;

  VoidCallback? onSpeechStart;
  VoidCallback? onSpeechComplete;
  Function(String message)? onSpeechError;

  TutorVoiceState get state => _state;
  bool get isPlaying => _state == TutorVoiceState.playing;
  bool get isPaused => _state == TutorVoiceState.paused;
  double get speechRate => _speechRate;

  Future<void> initialize({String languageCode = 'pt'}) async {
    if (_isInitialized) return;

    try {
      _currentLanguage = _mapLanguageCode(languageCode);
      await _tts.setLanguage(_currentLanguage);
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);

      _tts.setStartHandler(() {
        _state = TutorVoiceState.playing;
        onSpeechStart?.call();
      });

      _tts.setCompletionHandler(() {
        _state = TutorVoiceState.stopped;
        onSpeechComplete?.call();
      });

      _tts.setCancelHandler(() {
        _state = TutorVoiceState.stopped;
      });

      _tts.setPauseHandler(() {
        _state = TutorVoiceState.paused;
      });

      _tts.setContinueHandler(() {
        _state = TutorVoiceState.playing;
      });

      _tts.setErrorHandler((msg) {
        _state = TutorVoiceState.stopped;
        onSpeechError?.call(msg.toString());
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('[VoiceTutor] Erro ao inicializar TTS: $e');
    }
  }

  String _mapLanguageCode(String code) {
    switch (code.toLowerCase()) {
      case 'es':
        return 'es-ES';
      case 'en':
        return 'en-US';
      case 'pt':
      default:
        return 'pt-BR';
    }
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = _mapLanguageCode(languageCode);
    try {
      await _tts.setLanguage(_currentLanguage);
    } catch (_) {}
  }

  Future<void> setSpeedRate(double rate) async {
    _speechRate = rate;
    try {
      await _tts.setSpeechRate(rate);
    } catch (_) {}
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }
    if (text.trim().isEmpty) return;

    try {
      await _tts.stop();
      _state = TutorVoiceState.playing;
      await _tts.speak(text);
    } catch (e) {
      _state = TutorVoiceState.stopped;
      debugPrint('[VoiceTutor] Erro ao falar: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _tts.pause();
      _state = TutorVoiceState.paused;
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      _state = TutorVoiceState.stopped;
    } catch (_) {}
  }
}

