import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'data/local/hive_storage.dart';

import 'l10n/app_localizations.dart';

class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: HiveStorage.settingsBox.listenable(keys: ['isDarkMode', 'language']),
      builder: (context, Box box, _) {
        final bool isDarkMode = box.get('isDarkMode', defaultValue: false);
        final String deviceLang = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        final String fallbackLang = ['pt', 'es', 'en'].contains(deviceLang) ? deviceLang : 'en';
        final String savedLang = box.get('language', defaultValue: fallbackLang);
        final String languageCode = ['pt', 'es', 'en'].contains(savedLang) ? savedLang : fallbackLang;
        
        return MaterialApp(
          title: 'StudyFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: Locale(languageCode),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
          builder: (context, child) {
            // Professional System UI Overlay Styling
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                // Status Bar (Top)
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
                
                // Navigation Bar (Bottom)
                systemNavigationBarColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
                systemNavigationBarDividerColor: Colors.transparent,
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
