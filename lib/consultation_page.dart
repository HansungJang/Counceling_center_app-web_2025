// consultation_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

class ConsultationPage extends StatelessWidget {
  const ConsultationPage({super.key});

  final String? googleFormUrl = null; // or a valid URL
  final String fallbackContact = '+82 10-1234-5678';

  void _launchForm(BuildContext context, String url) async {
    final theme = Theme.of(context);

    try {
      await launchUrl(
        Uri.parse(url),
        prefersDeepLink: true,

        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: theme.colorScheme.surface,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open form: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultation Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            googleFormUrl == null
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '아직 등록된 검사지가 없습니다.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('문의는 $fallbackContact 로 연락해주세요.'),
                  ],
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '설문에 응답해 주세요:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Google Form 열기'),
                      onPressed: () => _launchForm(context, googleFormUrl!),
                    ),
                  ],
                ),
      ),
    );
  }
}
