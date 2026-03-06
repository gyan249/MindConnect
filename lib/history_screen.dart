import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'config.dart';

class HistoryScreen extends StatelessWidget {
  final String userId;

  const HistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('History'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.mood), text: 'Mood'),
              Tab(icon: Icon(Icons.self_improvement), text: 'Wellness'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MoodHistoryList(userId: userId),
            WellnessHistoryList(userId: userId),
          ],
        ),
      ),
    );
  }
}

/// ------------------ Mood History ------------------

class MoodHistoryList extends StatelessWidget {
  final String userId;

  const MoodHistoryList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('moodEntries')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No mood check-ins yet.\nTry logging how you feel today!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final result = (data['result'] ?? '') as String;
            final score = (data['score'] ?? 0) as int;
            final timestamp = data['timestamp'] as Timestamp?;
            final dateText = timestamp != null
                ? DateFormat('MMM d, yyyy – HH:mm').format(timestamp.toDate())
                : 'No time';

            final chipInfo = _moodChipFor(result, theme);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: theme.brightness == Brightness.dark ? 0 : 1.5,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mood: ${result.isEmpty ? 'Unknown' : result}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Chip(
                      label: Text(
                        chipInfo.label,
                        style: TextStyle(
                          color: chipInfo.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: chipInfo.backgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Score: $score',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ------------------ Wellness History ------------------

class WellnessHistoryList extends StatelessWidget {
  final String userId;

  const WellnessHistoryList({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('wellnessEntries')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No wellness assessments yet.\nTry a full check-in!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final data = docs[index].data();
            final result = (data['result'] ?? '') as String;
            final score = (data['score'] ?? 0) as int;
            final timestamp = data['timestamp'] as Timestamp?;
            final dateText = timestamp != null
                ? DateFormat('MMM d, yyyy – HH:mm').format(timestamp.toDate())
                : 'No time';

            final chipInfo = _wellnessChipFor(result, theme);

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: theme.brightness == Brightness.dark ? 0 : 1.5,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        result.isEmpty ? 'Wellness' : result,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        chipInfo.label,
                        style: TextStyle(
                          color: chipInfo.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: chipInfo.backgroundColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateText,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Score: $score',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ------------------ Chip helper model ------------------

class _ChipInfo {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  _ChipInfo({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

/// ------------------ Mood chip colors ------------------

_ChipInfo _moodChipFor(String result, ThemeData theme) {
  final lower = result.toLowerCase();

  if (lower.contains('positive') || lower.contains('happy')) {
    return _ChipInfo(
      label: 'Positive',
      backgroundColor: Colors.green.withOpacity(0.15),
      textColor: Colors.green.shade700,
    );
  } else if (lower.contains('neutral') || lower.contains('okay')) {
    return _ChipInfo(
      label: 'Neutral',
      backgroundColor: Colors.orange.withOpacity(0.15),
      textColor: Colors.orange.shade700,
    );
  } else if (lower.contains('low') || lower.contains('sad')) {
    return _ChipInfo(
      label: 'Low',
      backgroundColor: Colors.red.withOpacity(0.15),
      textColor: Colors.red.shade700,
    );
  }

  return _ChipInfo(
    label: 'Mood',
    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
    textColor: theme.colorScheme.primary,
  );
}

/// ------------------ Wellness chip colors ------------------

_ChipInfo _wellnessChipFor(String result, ThemeData theme) {
  final lower = result.toLowerCase();

  // English variants
  if (lower.contains('looks good') || lower.contains('good')) {
    return _ChipInfo(
      label: 'Good',
      backgroundColor: Colors.green.withOpacity(0.15),
      textColor: Colors.green.shade700,
    );
  } else if (lower.contains('okay') || lower.contains('ok')) {
    return _ChipInfo(
      label: 'Okay',
      backgroundColor: Colors.orange.withOpacity(0.15),
      textColor: Colors.orange.shade700,
    );
  } else if (lower.contains('needs attention') || lower.contains('low')) {
    return _ChipInfo(
      label: 'Low',
      backgroundColor: Colors.red.withOpacity(0.15),
      textColor: Colors.red.shade700,
    );
  }

  // Rough Hindi keywords
  if (result.contains('अच्छी')) {
    return _ChipInfo(
      label: 'अच्छी',
      backgroundColor: Colors.green.withOpacity(0.15),
      textColor: Colors.green.shade700,
    );
  } else if (result.contains('ठीक-ठाक') || result.contains('ठीक')) {
    return _ChipInfo(
      label: 'ठीक',
      backgroundColor: Colors.orange.withOpacity(0.15),
      textColor: Colors.orange.shade700,
    );
  } else if (result.contains('ज़रूरत')) {
    return _ChipInfo(
      label: 'कम',
      backgroundColor: Colors.red.withOpacity(0.15),
      textColor: Colors.red.shade700,
    );
  }

  return _ChipInfo(
    label: 'Wellness',
    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
    textColor: theme.colorScheme.primary,
  );
}
