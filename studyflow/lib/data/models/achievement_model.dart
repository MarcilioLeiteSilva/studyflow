import 'package:hive/hive.dart';

part 'achievement_model.g.dart';

@HiveType(typeId: 2)
class AchievementModel {
  @HiveField(0)
  final String badgeName;

  @HiveField(1)
  final String iconPath;

  @HiveField(2)
  final DateTime achievedDate;

  @HiveField(3)
  final String description;

  AchievementModel({
    required this.badgeName,
    required this.iconPath,
    required this.achievedDate,
    required this.description,
  });
}
