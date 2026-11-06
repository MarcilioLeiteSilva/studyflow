import 'package:flutter/material.dart';
import 'app.dart';
import 'data/local/hive_storage.dart';
import 'core/notifications/notification_service.dart';
import 'core/services/ads_service.dart';
import 'core/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveStorage.init();
  
  // Initialize Notifications
  await NotificationService.init();

  // Initialize Ads
  await AdsService.init();

  runApp(const StudyFlowApp());
}
