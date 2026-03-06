import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'theme_controller.dart';
import 'language_controller.dart';
import 'strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;

  String _language = 'en';
  String _themeMode = 'system'; // 'system', 'light', 'dark'
  bool _dailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final lang = languageController.currentLanguage;
    final dailyEnabled = prefs.getBool('dailyReminderEnabled') ?? false;
    final theme = prefs.getString('themeMode') ?? 'system';

    final hour = prefs.getInt('dailyReminderHour') ?? 20;
    final minute = prefs.getInt('dailyReminderMinute') ?? 0;

    setState(() {
      _language = lang;
      _dailyReminderEnabled = dailyEnabled;
      _themeMode = theme;
      _dailyReminderTime = TimeOfDay(hour: hour, minute: minute);
      _loading = false;
    });
  }

  Future<void> _onThemeChanged(String modeName) async {
    setState(() {
      _themeMode = modeName;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', modeName);

    await themeController.setThemeMode(modeName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.of('settings_snackbar_theme_updated'))),
    );
  }

  Widget _buildThemeRow(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          RadioListTile<String>(
            title: Text(S.of('settings_theme_system')),
            value: 'system',
            groupValue: _themeMode,
            onChanged: (value) {
              if (value != null) _onThemeChanged(value);
            },
          ),
          const Divider(height: 0),
          RadioListTile<String>(
            title: Text(S.of('settings_theme_light')),
            value: 'light',
            groupValue: _themeMode,
            onChanged: (value) {
              if (value != null) _onThemeChanged(value);
            },
          ),
          const Divider(height: 0),
          RadioListTile<String>(
            title: Text(S.of('settings_theme_dark')),
            value: 'dark',
            groupValue: _themeMode,
            onChanged: (value) {
              if (value != null) _onThemeChanged(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            S.of('settings_section_notifications'),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.textTheme.labelLarge?.color?.withOpacity(0.7),
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: Text(S.of('settings_daily_reminder')),
                value: _dailyReminderEnabled,
                onChanged: (value) async {
                  setState(() {
                    _dailyReminderEnabled = value;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('dailyReminderEnabled', value);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? (languageController.currentLanguage == 'hi'
                                ? 'रिमाइंडर चालू कर दिया गया'
                                : 'Daily reminder enabled')
                            : (languageController.currentLanguage == 'hi'
                                ? 'रिमाइंडर बंद कर दिया गया'
                                : 'Daily reminder disabled'),
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 0),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(S.of('settings_reminder_time')),
                subtitle: Text(
                  _dailyReminderTime.format(context),
                  style: theme.textTheme.bodySmall,
                ),
                enabled: _dailyReminderEnabled,
                onTap: !_dailyReminderEnabled
                    ? null
                    : () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _dailyReminderTime,
                        );
                        if (picked == null) return;

                        setState(() {
                          _dailyReminderTime = picked;
                        });

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('dailyReminderHour', picked.hour);
                        await prefs.setInt('dailyReminderMinute', picked.minute);

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              languageController.currentLanguage == 'hi'
                                  ? 'रिमाइंडर समय अपडेट हो गया'
                                  : 'Reminder time updated',
                            ),
                          ),
                        );
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(S.of('settings_title')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                S.of('settings_section_general'),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      theme.textTheme.labelLarge?.color?.withOpacity(0.7),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(S.of('settings_app_language')),
                    subtitle: Text(S.of('settings_app_language_hint')),
                    trailing: DropdownButton<String>(
                      value: _language,
                      items: const [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: 'hi',
                          child: Text('Hindi'),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == null) return;
                        setState(() {
                          _language = value;
                        });
                        await languageController.setLanguage(value);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              S.of('settings_snackbar_language_updated'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: Text(S.of('settings_theme')),
                    onTap: () {},
                  ),
                  _buildThemeRow(context),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notifications Section
            _buildNotificationsSection(context),

            const SizedBox(height: 16),

            // Data & Privacy
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                S.of('settings_section_data_privacy'),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      theme.textTheme.labelLarge?.color?.withOpacity(0.7),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: Text(S.of('settings_clear_data')),
                    subtitle: Text(S.of('settings_clear_data_sub')),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            languageController.currentLanguage == 'hi'
                                ? 'लोकल डाटा साफ़ कर दिया गया'
                                : 'Local data cleared',
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: Text(S.of('settings_delete_account')),
                    onTap: () {
                      // TODO: implement account deletion flow
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                S.of('settings_section_about'),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      theme.textTheme.labelLarge?.color?.withOpacity(0.7),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(S.of('settings_about_app')),
                subtitle: Text(
                  'MindConnect is a companion app to reflect on your mood, wellness, and daily habits.',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
