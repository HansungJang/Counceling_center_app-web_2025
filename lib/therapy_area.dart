// therapy_page.dart

import 'package:flutter/material.dart';

class TherapyPage extends StatelessWidget {
  const TherapyPage({super.key});

  final List<Map<String, String>> therapyAreas = const [
    {
      'title': 'Children',
      'description':
          'Emotional support, developmental concerns, behavioral challenges.',
    },
    {
      'title': 'Teens',
      'description':
          'Identity issues, school stress, peer relationships, and anxiety.',
    },
    {
      'title': 'Adults',
      'description':
          'Work-life balance, depression, grief, self-esteem support.',
    },
    {
      'title': 'Couples',
      'description':
          'Communication issues, emotional disconnection, premarital counseling.',
    },
    {
      'title': 'Grief & Loss',
      'description':
          'Navigating loss, emotional processing, rebuilding meaning.',
    },
    {
      'title': 'Burnout & Trauma',
      'description':
          'Stress recovery, emotional regulation, trauma-informed care.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: therapyAreas.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Therapy Areas'),
          bottom: TabBar(
            isScrollable: true,
            tabs: therapyAreas.map((area) => Tab(text: area['title'])).toList(),
          ),
        ),
        body: TabBarView(
          children:
              therapyAreas.map((area) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area['title']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        area['description']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
