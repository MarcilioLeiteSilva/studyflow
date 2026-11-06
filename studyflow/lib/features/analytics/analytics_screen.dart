import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/ads_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../../data/local/hive_storage.dart';
import '../../data/models/pomodoro_session_model.dart';
import '../reports/reports_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analyticsTitle),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.doc_text),
            tooltip: l10n.analyticsGenerateReport,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveStorage.sessionsBox.listenable(),
        builder: (context, Box<PomodoroSessionModel> box, _) {
          final sessions = box.values.toList();
          final totalMinutes = sessions.fold<int>(
              0, (sum, session) => sum + session.durationMinutes);
          final totalHours = (totalMinutes / 60).toStringAsFixed(1);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(context, totalHours, sessions.length),
                const SizedBox(height: 10),
                AdsService().getBannerAd(),
                const SizedBox(height: 10),
                Text(
                  l10n.analyticsWeeklyFocus,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildChart(sessions),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String hours, int sessions) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  l10n.analyticsTotalHours,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 5),
                Text(
                  hours,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(width: 1, height: 40, color: Colors.white24),
            Column(
              children: [
                Text(
                  l10n.analyticsSessions,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 5),
                Text(
                  '$sessions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(List<PomodoroSessionModel> sessions) {
    // Group by day of week (0 = Mon, 6 = Sun)
    final Map<int, int> dayStats = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    
    for (var session in sessions) {
      // Check if session is from this week (simplified logic)
      final diff = DateTime.now().difference(session.completedDate).inDays;
      if (diff < 7) {
        final weekday = session.completedDate.weekday - 1; // 0-based
        dayStats[weekday] = (dayStats[weekday] ?? 0) + session.durationMinutes;
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 120, // 2 hours max for scale
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                if (value.toInt() < days.length) {
                  return Text(days[value.toInt()]);
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: dayStats.entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                color: Colors.blueAccent,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
