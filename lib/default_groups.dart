import 'package:cloud_firestore/cloud_firestore.dart';

class DefaultGroups {
  static final List<Map<String, dynamic>> groups = [
    {
      'name': 'Anxiety Support',
      'description': 'A safe place to talk about anxiety and coping tips.',
      'createdBy': 'system',
      'createdByName': 'MindConnect',
      'iconEmoji': '💭',
    },
    {
      'name': 'Depression Support',
      'description': 'Share your feelings, seek support, and connect.',
      'createdBy': 'system',
      'createdByName': 'MindConnect',
      'iconEmoji': '💙',
    },
    {
      'name': 'Motivation & Positivity',
      'description': 'Daily motivation, affirmations, and positivity.',
      'createdBy': 'system',
      'createdByName': 'MindConnect',
      'iconEmoji': '✨',
    },
    {
      'name': 'Mental Health Tips',
      'description': 'Tips, advice, and educational content.',
      'createdBy': 'system',
      'createdByName': 'MindConnect',
      'iconEmoji': '🧠',
    },
    {
      'name': 'Youth Wellness Chat',
      'description': 'A friendly environment for teens & young adults.',
      'createdBy': 'system',
      'createdByName': 'MindConnect',
      'iconEmoji': '🌈',
    },
  ];

  /// Call this once. Adds groups only if the collection is empty.
  static Future<void> initializeDefaultGroups() async {
    final groupsRef = FirebaseFirestore.instance.collection('groups');

    final existing = await groupsRef.limit(1).get();
    if (existing.docs.isNotEmpty) return; // groups already exist

    for (var group in groups) {
      await groupsRef.add({
        ...group,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
