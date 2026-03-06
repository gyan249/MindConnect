import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'config.dart';

class YogaRoutine {
  final String id;
  final String title;
  final String duration;
  final int durationMinutes;
  final String focus;
  final String description;
  final List<String> steps;
  final String? videoUrl;

  const YogaRoutine({
    required this.id,
    required this.title,
    required this.duration,
    required this.durationMinutes,
    required this.focus,
    required this.description,
    required this.steps,
    this.videoUrl,
  });
}

/// ===============================================================
/// STATIC ROUTINES LIST
/// ===============================================================
const List<YogaRoutine> _routines = [
  YogaRoutine(
    id: 'morning_stretch',
    title: 'Morning Stretch',
    duration: '5 min',
    durationMinutes: 5,
    focus: 'Gentle wake-up',
    description:
        'A short sequence to gently wake up your body and mind at the start of the day.',
    steps: [
      'Sit comfortably, close your eyes, and take 3 slow deep breaths.',
      'Inhale and raise both arms overhead, stretching your spine tall.',
      'Lean to the right on exhale. Hold for 3 breaths. Switch sides.',
      'Interlace fingers behind your back and gently lift your chest.',
      'Roll shoulders and neck softly. Relax.',
    ],
    videoUrl: 'https://youtu.be/4pKly2JojMw?si=cFrjPhV4Mvq6jxYE',
  ),
  YogaRoutine(
    id: 'desk_break',
    title: 'Desk Break Yoga',
    duration: '3–5 min',
    durationMinutes: 4,
    focus: 'Neck & shoulders',
    description:
        'Perfect for a quick break while studying or working. Easily done on a chair.',
    steps: [
      'Sit tall on your chair, feet flat on the floor.',
      'Roll shoulders back and down 5 times.',
      'Drop right ear to shoulder. Hold. Switch sides.',
      'Interlace fingers forward, round your back gently.',
      'Place hands on lower back, open chest gently.',
    ],
    videoUrl: 'https://youtu.be/M-8FvC3GD8c?si=TKu8ujIMc0mqbIyq',
  ),
  YogaRoutine(
    id: 'sleep_relax',
    title: 'Sleep Relaxation',
    duration: '8–10 min',
    durationMinutes: 9,
    focus: 'Calming the mind',
    description:
        'A calming routine to release tension and prepare your body for restful sleep.',
    steps: [
      'Lie on your back comfortably.',
      'Take long deep breaths.',
      'Hug knees to chest, rock side to side.',
      'Feet on floor, let knees fall together.',
      'Relax your whole body from head to toe.',
    ],
    videoUrl: 'https://youtu.be/E9LVKL2pGmo?si=TlOtp43meTWi2nIf',
  ),
];

/// ===============================================================
/// MAIN SCREEN
/// ===============================================================
class YogaScreen extends StatelessWidget {
  const YogaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yoga'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: isDark ? Colors.black : AppColors.backgroundLight,
      body: Column(
        children: [
          const _YogaProgressSummary(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _routines.length,
              itemBuilder: (context, i) =>
                  _YogaRoutineCard(routine: _routines[i]),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================================================
/// WEEKLY PROGRESS CARD
/// ===============================================================
class _YogaProgressSummary extends StatelessWidget {
  const _YogaProgressSummary();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    if (user == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('yogaSessions')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        int mins = 0;
        final days = <String>{};

       if (snapshot.hasData) {
         for (var doc in snapshot.data!.docs) {
           final d = doc.data() as Map<String, dynamic>?;

           if (d == null) continue;

           final dynamic minsValue = d['durationMinutes'];
           if (minsValue is int) mins += minsValue;

           final ts = d['timestamp'];
           if (ts is Timestamp) {
             final date = ts.toDate();
             days.add("${date.year}-${date.month}-${date.day}");
           }
         }
       }


        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Card(
            color: theme.colorScheme.surface,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child:
                        const Icon(Icons.self_improvement, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("This week's practice",
                          style: theme.textTheme.titleMedium),
                      Text(
                        "$mins min • ${days.length} day(s)",
                        style: theme.textTheme.bodySmall!
                            .copyWith(color: theme.colorScheme.onSurfaceVariant),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ===============================================================
/// ROUTINE LIST CARD
/// ===============================================================
class _YogaRoutineCard extends StatelessWidget {
  final YogaRoutine routine;
  const _YogaRoutineCard({required this.routine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => YogaRoutineDetailScreen(routine: routine),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.self_improvement,
                    size: 28, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routine.title,
                        style: theme.textTheme.titleMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      routine.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),

                    /// FIX: CHIP OVERFLOW → NOW USING WRAP
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                            icon: Icons.timer_outlined,
                            label: routine.duration),
                        _InfoChip(
                            icon: Icons.favorite_border,
                            label: routine.focus),
                      ],
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
}

/// ===============================================================
/// SMALL INFO CHIP
/// ===============================================================
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.primary))
      ]),
    );
  }
}

/// ===============================================================
/// DETAIL SCREEN
/// ===============================================================
class YogaRoutineDetailScreen extends StatelessWidget {
  final YogaRoutine routine;
  const YogaRoutineDetailScreen({super.key, required this.routine});

  /// OPEN VIDEO WITH SNACKBAR ERROR FEEDBACK
  Future<void> _openVideo(BuildContext context) async {
    if (routine.videoUrl == null) return;

    final uri = Uri.parse(routine.videoUrl!);

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// SAVE SESSION
  Future<void> _markCompleted(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('yogaSessions')
          .add({
        'routineId': routine.id,
        'timestamp': FieldValue.serverTimestamp(),
        'durationMinutes': routine.durationMinutes,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session saved ✓')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          /// TOP CARD
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(routine.title,
                        style: theme.textTheme.titleLarge!
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    /// FIX: REPLACED ROW → WRAP
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _InfoChip(
                            icon: Icons.timer_outlined,
                            label: routine.duration),
                        _InfoChip(
                            icon: Icons.favorite_border,
                            label: routine.focus),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Text(routine.description),
                    const SizedBox(height: 12),

                    if (routine.videoUrl != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.play_circle_outline),
                          label: const Text('Watch guided video'),
                          onPressed: () => _openVideo(context),
                        ),
                      ),
                  ]),
            ),
          ),

          const SizedBox(height: 20),
          Text("Steps",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          /// STEPS CARD
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                for (int i = 0; i < routine.steps.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${i + 1}. ",
                          style: theme.textTheme.bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(routine.steps[i])),
                    ],
                  ),
                  if (i != routine.steps.length - 1)
                    const Divider(height: 18),
                ],
              ]),
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Mark as completed"),
              onPressed: () => _markCompleted(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
