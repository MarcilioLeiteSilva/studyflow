import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_code/l10n/app_localizations.dart';

class FocusModeScreen extends StatefulWidget {
  final int initialTime;
  final VoidCallback onSessionComplete;

  const FocusModeScreen({
    super.key,
    required this.initialTime,
    required this.onSessionComplete,
  });

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  late int _timeLeft;
  Timer? _timer;
  
  // Multi-channel Audio Mixer
  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _volumes = {
    'Rain': 0.0,
    'Forest': 0.0,
    'Fire': 0.0,
    'Stream': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.initialTime;
    _startTimer();
    _initAudio();
  }

  void _initAudio() {
    for (var sound in _volumes.keys) {
      final player = AudioPlayer();
      player.setReleaseMode(ReleaseMode.loop);
      _players[sound] = player;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _timer?.cancel();
        _stopAllAudio();
        widget.onSessionComplete();
        Navigator.pop(context); // Exit focus mode on completion
      }
    });
  }

  Future<void> _updateVolume(String sound, double volume) async {
    setState(() {
      _volumes[sound] = volume;
    });

    final player = _players[sound];
    if (player != null) {
      if (volume > 0) {
        if (player.state != PlayerState.playing) {
          String assetPath = 'sounds/${sound.toLowerCase()}.mp3';
          await player.play(AssetSource(assetPath), volume: volume);
        } else {
          await player.setVolume(volume);
        }
      } else {
        await player.stop();
      }
    }
  }

  Future<void> _stopAllAudio() async {
    for (var player in _players.values) {
      await player.stop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var player in _players.values) {
      player.dispose();
    }
    super.dispose();
  }

  bool _isSoundMenuOpen = false;

  Color _getGlowColor() {
    // Dynamic glow based on loudest sound
    String dominant = _volumes.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    if (_volumes[dominant]! == 0) return Colors.blue;

    switch (dominant) {
      case 'Fire': return Colors.orange;
      case 'Forest': return Colors.green;
      case 'Rain': return Colors.blue;
      case 'Stream': return Colors.cyan;
      default: return Colors.blue;
    }
  }

  Widget _buildVolumeSlider(BuildContext context, String sound) {
    final l10n = AppLocalizations.of(context)!;
    String displayName;
    switch (sound) {
      case 'Rain': displayName = l10n.soundRain; break;
      case 'Forest': displayName = l10n.soundForest; break;
      case 'Fire': displayName = l10n.soundFire; break;
      case 'Stream': displayName = l10n.soundStream; break;
      default: displayName = sound;
    }

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(displayName, style: const TextStyle(color: Colors.white70)),
        ),
        Expanded(
          child: Slider(
            value: _volumes[sound]!,
            onChanged: (v) => _updateVolume(sound, v),
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.white10,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // AMOLED Black Theme
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background ambient glow (optional)
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1000),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getGlowColor().withValues(alpha: 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: _getGlowColor().withValues(alpha: 0.1),
                      blurRadius: 100,
                      spreadRadius: 50,
                    )
                  ],
                ),
              ),
            ),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     const SizedBox(width: 48), // Spacer
                     Text(
                      l10n.focusTitle,
                      style: GoogleFonts.spaceMono(
                        color: Colors.white54,
                        fontSize: 16,
                        letterSpacing: 4,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isSoundMenuOpen ? Icons.close : Icons.tune, 
                        color: Colors.white
                      ),
                      onPressed: () {
                        setState(() {
                          _isSoundMenuOpen = !_isSoundMenuOpen;
                        });
                      },
                    ),
                  ],
                ),
                
                // Sound Mixer Overlay
                if (_isSoundMenuOpen)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900]?.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _volumes.keys.map((sound) => _buildVolumeSlider(context, sound)).toList(),
                    ),
                  ),

                Expanded(
                  child: Center(
                    child: CircularPercentIndicator(
                      radius: 120.0,
                      lineWidth: 8.0,
                      percent: _timeLeft / widget.initialTime,
                      center: Text(
                        '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      progressColor: Colors.blueAccent,
                      backgroundColor: Colors.grey[900]!,
                      circularStrokeCap: CircularStrokeCap.round,
                      animation: true,
                      animateFromLastPercent: true,
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                Text(
                  '"Focus is the key to productivity"',
                  style: GoogleFonts.caveat(
                    color: Colors.white30,
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text('Give Up?', style: TextStyle(color: Colors.white)),
                        content: const Text(
                          'Leaving now will cancel your session streak.',
                          style: TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('Stay Focused'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(c);
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('I Quit'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('EXIT SESSION'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
