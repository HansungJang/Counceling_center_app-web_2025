// location_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  final String address = '123 Forest Road, Seoul, South Korea'; // 편집할 수 있게 수정
  final String phone = '+82 10-1234-5678';
  final String email = 'mindrest@counsel.kr';
  final String mapUrl =
      'https://www.google.com/maps/?entry=ttu&g_ep=EgoyMDI1MDUxNS4wIKXMDSoASAFQAw%3D%3D';

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(address),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _launchUrl(mapUrl),
              icon: const Icon(Icons.map),
              label: const Text('View on Google Maps'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact Us',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(phone),
              onTap: () => _launchUrl('tel:$phone'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(email),
              onTap: () => _launchUrl('mailto:$email'),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat via KakaoTalk'),
              onTap: () => _launchUrl('https://pf.kakao.com/_kakaochatlink'),
            ),
          ],
        ),
      ),
    );
  }
}
