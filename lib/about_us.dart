// about_us.dart

import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildCard(
              title: 'Welcome to Mind Rest',
              content:
                  'Our center provides a safe, peaceful space to reflect and heal. We are committed to mental well-being and nature-inspired therapy.',
            ),
            _buildCard(
              title: 'Philosophy',
              content:
                  'We believe in personalized care, respecting the uniqueness of every journey. Our sessions focus on listening deeply and growing gently.',
            ),
            _buildCard(
              title: 'Specializations',
              content:
                  'We work with adults, teens, and caregivers struggling with stress, anxiety, trauma, or personal transitions. Forest themes support calm and presence.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String content}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
