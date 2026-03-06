import 'package:flutter/material.dart';
import 'config.dart';
import 'language_controller.dart';
import 'strings.dart';

class HomeScreen extends StatelessWidget {
  final String lang;
  final VoidCallback onStartMood;
  final VoidCallback onStartWellness;
  final VoidCallback onMenuTap;

  const HomeScreen({
    super.key,
    required this.lang,
    required this.onStartMood,
    required this.onStartWellness,
    required this.onMenuTap,
  });

  String _greeting() {
    final hour = DateTime.now().hour;
    // If you want fixed English greeting, replace with plain strings.
    if (hour < 12) {
      return S.of('home_greeting_morning');
    } else if (hour < 17) {
      return S.of('home_greeting_afternoon');
    } else {
      return S.of('home_greeting_evening');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? Colors.black : AppColors.backgroundLight, // like before
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar: menu + title centered-ish
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: onMenuTap,
                  ),
                  Text(
                    'MindConnect', // keep your original title text
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                _greeting(), // "Good Evening," etc
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                S.of('home_how_can_we_help'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  children: [
                    _buildMainCard(
                      context,
                      icon: Icons.mood_outlined,
                      title: S.of('home_daily_mood_title'),
                      subtitle: S.of('home_daily_mood_subtitle'),
                      onTap: onStartMood,
                    ),
                    const SizedBox(height: 12),
                    _buildMainCard(
                      context,
                      icon: Icons.self_improvement_outlined,
                      title: S.of('home_wellness_title'),
                      subtitle: S.of('home_wellness_subtitle'),
                      onTap: onStartWellness,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      S.of('home_tip_title'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTipCard(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? theme.colorScheme.surface : Colors.white,
      elevation: isDark ? 0 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? theme.colorScheme.surface : Colors.white,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          S.of('home_tip_text'),
          style: theme.textTheme.bodyMedium,
        ),
      ),
    );
  }
}
