import 'package:flutter/material.dart';
import 'config.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About MindConnect'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MindConnect',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'MindConnect is a mental wellness companion app that helps you track your mood, '
              'take wellness assessments, chat with an AI assistant, and connect with supportive communities.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Developer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Your Name Here'), // change to your name 🙂

            const SizedBox(height: 24),
            const Text(
              'Disclaimer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'This app does not replace professional medical or psychological help. '
              'If you are in crisis or need urgent assistance, please contact a trusted person, '
              'local helpline, or mental health professional.',
            ),
          ],
        ),
      ),
    );
  }
}
