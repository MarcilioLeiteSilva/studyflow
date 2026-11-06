import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundPlayerScreen extends StatefulWidget {
  const SoundPlayerScreen({super.key});

  @override
  State<SoundPlayerScreen> createState() => _SoundPlayerScreenState();
}

class _SoundPlayerScreenState extends State<SoundPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentSound;
  bool _isPlaying = false;

  final List<Map<String, String>> _sounds = [
    {'name': 'Rain', 'icon': '🌧️', 'file': 'sounds/rain.mp3'},
    {'name': 'Forest', 'icon': '🌲', 'file': 'sounds/forest.mp3'},
    {'name': 'Cafe', 'icon': '☕', 'file': 'sounds/cafe.mp3'},
    {'name': 'White Noise', 'icon': '🌊', 'file': 'sounds/white_noise.mp3'},
    {'name': 'Library', 'icon': '📚', 'file': 'sounds/library.mp3'},
    {'name': 'Night', 'icon': '🌙', 'file': 'sounds/night.mp3'},
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleSound(String file) async {
    if (_currentSound == file && _isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      // For demo purposes, we'll simulate playing since actual assets might not exist
      // In production, uncomment the next line and ensure assets exist
      // await _audioPlayer.play(AssetSource(file));
      // await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      
      setState(() {
        _currentSound = file;
        _isPlaying = true;
      });
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playing ${_sounds.firstWhere((s) => s['file'] == file)['name']}... (Simulated)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambient Focus Sounds')),
      body: AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: _sounds.length,
          itemBuilder: (context, index) {
            final sound = _sounds[index];
            final isSelected = _currentSound == sound['file'];
            final isActive = isSelected && _isPlaying;

            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () => _toggleSound(sound['file']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isActive
                                ? Theme.of(context).primaryColor.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.05),
                            blurRadius: isActive ? 12 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sound['icon']!,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            sound['name']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(height: 8),
                            const Icon(Icons.equalizer, color: Colors.white, size: 20),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
