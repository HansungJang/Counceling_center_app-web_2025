// main_page.dart (HomePage)

import 'package:flutter/material.dart';
import 'about_us.dart';
// import 'therapist_page.dart';
// import 'therapy_page.dart';
// import 'consultation_page.dart';
// import 'location_page.dart';

class HomePage extends StatelessWidget {
  final List<_NavItem> navItems = [
    _NavItem(title: 'About Us', icon: Icons.info, page: AboutPage()),
    _NavItem(
      title: 'Therapist',
      icon: Icons.person,
      page: PlaceholderPage(title: 'Therapist'),
    ),
    _NavItem(
      title: 'Therapy Areas',
      icon: Icons.local_florist,
      page: PlaceholderPage(title: 'Therapy Areas'),
    ),
    _NavItem(
      title: 'Consultation',
      icon: Icons.chat,
      page: PlaceholderPage(title: 'Consultation'),
    ),
    _NavItem(
      title: 'Location',
      icon: Icons.location_on,
      page: PlaceholderPage(title: 'Location'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마음 쉼 Counceling Center'),
        actions: [
          IconButton(
            icon: Icon(Icons.lock_outline),
            onPressed: () {
              // TODO: Add manager login route
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Manager login not yet implemented')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: navItems.length,
        itemBuilder: (context, index) {
          final item = navItems[index];
          return Card(
            child: ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => item.page),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final Widget page;

  _NavItem({required this.title, required this.icon, required this.page});
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Page (Under Construction)')),
    );
  }
}
