// therapist_page.dart

import 'package:flutter/material.dart';

class TherapistPage extends StatelessWidget {
  const TherapistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Therapist Introduction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kim Soojin, MA Counseling Psychology',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Affiliated with Healing Tree Center Certified Mental Health Counselor (KCPA) Specialized in anxiety, trauma, and women\'s wellness.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'I believe that even the smallest step toward healing is courageous. Together, we\'ll find a way forward at your own pace.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
