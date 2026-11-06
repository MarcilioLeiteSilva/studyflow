import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_code/l10n/app_localizations.dart';
import '../../data/local/hive_storage.dart';
import '../achievements/achievements_screen.dart';
import '../achievements/quotes_screen.dart';
import '../sounds/sound_player_screen.dart';
import '../reports/reports_screen.dart';
import '../../app.dart'; // Import MyApp for restarting/rebuilding if needed

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ValueListenableBuilder(
        valueListenable: HiveStorage.settingsBox.listenable(),
        builder: (context, Box box, _) {
          bool isDarkMode = box.get('isDarkMode', defaultValue: false);
          bool notificationsEnabled = box.get('notificationsEnabled', defaultValue: true);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cloud Sync Card (Removed)

              const SizedBox(height: 20),

              _SectionHeader(title: l10n.settingsPremium),
              _SettingsTile(
                icon: CupertinoIcons.music_note_2,
                title: l10n.prefAmbientSounds,
                subtitle: l10n.prefAmbientSoundsSubtitle,
                color: Colors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoundPlayerScreen())),
              ),
              _SettingsTile(
                icon: CupertinoIcons.star_circle,
                title: l10n.prefAchievements,
                subtitle: l10n.prefAchievementsSubtitle,
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
              ),
              _SettingsTile(
                icon: CupertinoIcons.quote_bubble,
                title: l10n.prefDailyMotivation,
                subtitle: l10n.prefDailyMotivationSubtitle,
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuotesScreen())),
              ),
              _SettingsTile(
                icon: CupertinoIcons.doc_text,
                title: l10n.prefExportReports,
                subtitle: l10n.prefExportReportsSubtitle,
                color: Colors.red,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
              ),

              const SizedBox(height: 20),
              _SectionHeader(title: l10n.sectionAppSettings),
              
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.dark_mode, color: Colors.indigo),
                      ),
                      title: Text(l10n.prefDarkMode),
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (val) {
                          HiveStorage.saveSetting('isDarkMode', val);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.notifications, color: Colors.teal),
                      ),
                      title: Text(l10n.prefNotifications),
                      trailing: Switch(
                        value: notificationsEnabled,
                        onChanged: (val) {
                          HiveStorage.saveSetting('notificationsEnabled', val);
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    _LanguageTile(),
                    const Divider(height: 1),
                    _ApiKeyTile(),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _SectionHeader(title: l10n.sectionData),
              Card(
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.delete_forever, color: Colors.red),
                  ),
                  title: Text(l10n.prefResetData, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () => _confirmReset(context),
                ),
              ),
              
              const SizedBox(height: 20),
              const Center(child: Text('Study Planner Pro v1.0.0', style: TextStyle(color: Colors.grey))),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dialogResetTitle),
        content: Text(l10n.dialogResetContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.settingsCancel),
          ),
          TextButton(
            onPressed: () async {
              await HiveStorage.tasksBox.clear();
              await HiveStorage.sessionsBox.clear();
              await HiveStorage.achievementsBox.clear();
              if (context.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.snackDataReset)),
                );
              }
            },
            child: Text(l10n.btnReset, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String currentLang = HiveStorage.getSetting('language', defaultValue: 'en');
    final l10n = AppLocalizations.of(context)!;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.language, color: Colors.orange),
      ),
      title: Text(l10n.prefLanguage),
      subtitle: Text(_getLanguageName(currentLang, l10n)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => _showLanguageDialog(context, currentLang),
    );
  }

  String _getLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'pt': return l10n.langPortuguese;
      case 'es': return l10n.langSpanish;
      default: return l10n.langEnglish;
    }
  }

  void _showLanguageDialog(BuildContext context, String currentLang) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.dialogLanguageTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildLangOption(context, l10n.langEnglish, 'en', currentLang),
                _buildLangOption(context, l10n.langSpanish, 'es', currentLang),
                _buildLangOption(context, l10n.langPortuguese, 'pt', currentLang),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLangOption(BuildContext context, String name, String code, String current) {
    final isSelected = code == current;
    return ListTile(
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
      onTap: () {
        HiveStorage.saveSetting('language', code);
        Navigator.pop(context);
        // Hint: In a real app with localization, you'd trigger a rebuild here.
        // For now, saving the setting is the first step.
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).disabledColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _ApiKeyTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String currentKey = HiveStorage.getSetting('customApiKey', defaultValue: '') as String;
    final bool hasKey = currentKey.trim().isNotEmpty;
    final String displaySubtitle = hasKey
        ? '••••••••${currentKey.length > 4 ? currentKey.substring(currentKey.length - 4) : ""}'
        : l10n.prefApiKeySubtitle;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.purple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.vpn_key, color: Colors.purple),
      ),
      title: Text(l10n.prefApiKey),
      subtitle: Text(displaySubtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => _showApiKeyDialog(context, currentKey),
    );
  }

  void _showApiKeyDialog(BuildContext context, String currentKey) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dialogApiKeyTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dialogApiKeyDesc, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.dialogApiKeyHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.key),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          if (currentKey.isNotEmpty)
            TextButton(
              onPressed: () {
                HiveStorage.saveSetting('customApiKey', '');
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.snackApiKeyCleared)),
                );
              },
              child: Text(l10n.btnDelete, style: const TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.settingsCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newKey = controller.text.trim();
              HiveStorage.saveSetting('customApiKey', newKey);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.snackApiKeySaved)),
              );
            },
            child: Text(l10n.btnSave),
          ),
        ],
      ),
    );
  }
}
