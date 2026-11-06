import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../subjects/subjects_screen.dart';
import '../ai_assistant/ai_routine_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final void Function(int index)? onTabSelected;

  const AppDrawer({super.key, this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).primaryColor;

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 24, left: 20, right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  'StudyFlow',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seu Fluxo de Aprendizado',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 1. Matérias para Estudos
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_stories, color: Colors.blue),
            ),
            title: Text(
              l10n.drawerSubjects,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text('Disciplinas e conteúdos de estudo', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SubjectsScreen()),
              );
            },
          ),

          const Divider(indent: 20, endIndent: 20, height: 1),

          // 2. Planos para Baixar
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.cloud_download, color: Colors.indigo),
            ),
            title: Text(
              l10n.drawerDownloadPlans,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text('Baixar planos prontos e gerar com IA', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AIRoutineScreen()),
              );
            },
          ),

          const Divider(indent: 20, endIndent: 20, height: 1),

          // 3. Estatísticas
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bar_chart, color: Colors.teal),
            ),
            title: Text(
              l10n.drawerStats,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text('Produtividade e horas de foco', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              if (onTabSelected != null) {
                onTabSelected!(3); // Aba de Estatísticas no Dashboard
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
                );
              }
            },
          ),

          const Divider(indent: 20, endIndent: 20, height: 1),

          // 3. Ajustes
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.settings, color: Colors.deepPurple),
            ),
            title: Text(
              l10n.drawerSettings,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: const Text('Idioma, modo escuro e chaves', style: TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            onTap: () {
              Navigator.pop(context);
              if (onTabSelected != null) {
                onTabSelected!(4); // Aba de Ajustes no Dashboard
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }
            },
          ),

          const Spacer(),

          // Footer version
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'StudyFlow v1.0.0',
              style: TextStyle(color: Colors.grey.withValues(alpha: 0.7), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
