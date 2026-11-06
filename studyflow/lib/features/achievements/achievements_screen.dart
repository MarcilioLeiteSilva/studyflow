import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/local/hive_storage.dart';
import '../../data/models/achievement_model.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: ValueListenableBuilder(
        valueListenable: HiveStorage.achievementsBox.listenable(),
        builder: (context, Box<AchievementModel> box, _) {
          final achievements = box.values.toList();
          
          // Seed some default achievements for display if empty
          // In a real app, you'd check conditions and add them dynamically
          if (achievements.isEmpty) {
             // Just for UI demo purposes, let's show what it would look like
             // We won't actually add them to DB to keep it clean
          }

          final List<Map<String, dynamic>> allBadges = [
            {'name': 'First Step', 'desc': 'Complete your first task', 'icon': '🏁', 'color': Colors.blue},
            {'name': 'Focus Master', 'desc': 'Complete 10 Pomodoro sessions', 'icon': '🧘', 'color': Colors.purple},
            {'name': 'Planner Pro', 'desc': 'Create 50 tasks', 'icon': '📅', 'color': Colors.orange},
            {'name': 'Early Bird', 'desc': 'Complete a task before 8 AM', 'icon': '🌅', 'color': Colors.yellow},
            {'name': 'Night Owl', 'desc': 'Complete a session after 10 PM', 'icon': '🦉', 'color': Colors.indigo},
            {'name': 'Streak King', 'desc': '7-day study streak', 'icon': '🔥', 'color': Colors.red},
          ];

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: allBadges.length,
              itemBuilder: (context, index) {
                final badge = allBadges[index];
                final isUnlocked = index < 2; // Simulate some unlocked

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? Theme.of(context).cardColor
                              : Theme.of(context).disabledColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isUnlocked
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                          border: isUnlocked
                              ? Border.all(color: (badge['color'] as Color).withValues(alpha: 0.3), width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? (badge['color'] as Color).withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  badge['icon'],
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: isUnlocked ? null : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    badge['name'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isUnlocked
                                          ? Theme.of(context).textTheme.bodyLarge?.color
                                          : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    badge['desc'],
                                    style: TextStyle(
                                      color: isUnlocked
                                          ? Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isUnlocked)
                              Icon(Icons.check_circle, color: badge['color'])
                            else
                              const Icon(Icons.lock, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
