import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/services/ads_service.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import 'app_drawer.dart';
import '../planner/planner_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../flashcards/flashcards_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const PlannerScreen(),
    const PomodoroScreen(),
    const FlashcardsScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    AdsService().loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      drawer: AppDrawer(
        onTabSelected: (index) => setState(() => _currentIndex = index),
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
          AdsService().getBannerAd(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        elevation: 10,
        backgroundColor: Theme.of(context).cardColor,
        destinations: [
          NavigationDestination(
            icon: const Icon(CupertinoIcons.calendar),
            selectedIcon: const Icon(CupertinoIcons.calendar_today),
            label: l10n.navPlanner,
          ),
          NavigationDestination(
            icon: const Icon(CupertinoIcons.timer),
            selectedIcon: const Icon(CupertinoIcons.timer_fill),
            label: l10n.navFocus,
          ),
          NavigationDestination(
            icon: const Icon(CupertinoIcons.square_stack_3d_up),
            selectedIcon: const Icon(CupertinoIcons.square_stack_3d_up_fill),
            label: l10n.navCards,
          ),
          NavigationDestination(
            icon: const Icon(CupertinoIcons.graph_square),
            selectedIcon: const Icon(CupertinoIcons.graph_square_fill),
            label: l10n.navStats,
          ),
          NavigationDestination(
            icon: const Icon(CupertinoIcons.settings),
            selectedIcon: const Icon(CupertinoIcons.settings_solid),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
