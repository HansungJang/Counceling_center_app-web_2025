// consultation_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs; // Ensure this is imported
import 'package:url_launcher/url_launcher.dart'; // Ensure this is imported
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Import the indicator

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});

  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  // Define your questions here
  final List<Map<String, String>> _questions = [
    {
      'id': 'q1', // For potential use with Google Form field IDs
      'text': '요즘 내 마음속 가장 큰 파도는 무엇인가요? 🌊\n(가장 신경 쓰이거나 힘든 점 한두 가지)',
      'hint': '천천히 떠오르는 생각을 적어보세요...',
    },
    {
      'id': 'q2',
      'text': '그 파도가 나의 일상이라는 바다에 어떤 물결을 일으키나요? 🏞️\n(구체적인 영향이나 변화)',
      'hint': '어떤 점들이 달라졌는지 떠올려보세요...',
    },
    {
      'id': 'q3',
      'text': '이 상담이라는 등대를 통해 어떤 잔잔한 항구를 찾고 싶나요? ⚓\n(상담을 통해 기대하는 작은 변화)',
      'hint': '어떤 변화를 기대하시는지 알려주세요...',
    },
  ];

  // Controllers for PageView and TextFields
  late PageController _pageController;
  late List<TextEditingController> _textControllers;
  int _currentPage = 0;

  // Google Form URL and fallback contact (can be null)
  // IMPORTANT: Replace 'YOUR_GOOGLE_FORM_URL' with your actual Google Form URL
  // And replace 'YOUR_FIELD_ID_FOR_Q1', 'YOUR_FIELD_ID_FOR_Q2', etc.
  // with the actual prefilled entry IDs from your Google Form.
  // Example: "https://docs.google.com/forms/d/e/YOUR_FORM_ID/viewform?usp=pp_url&entry.123456789=" (for one field)
  // For multiple fields: "https://docs.google.com/forms/d/e/YOUR_FORM_ID/viewform?usp=pp_url&entry.ID1={answer1}&entry.ID2={answer2}"

  // Let's assume you have a base URL and will append parameters later
  final String? googleFormBaseUrl = "https://docs.google.com/forms/d/e/YOUR_FORM_ID/viewform?usp=pp_url"; // Replace with your form's base URL
  final Map<String, String> googleFormFieldIds = {
    'q1': 'entry.YOUR_FIELD_ID_FOR_Q1', // Replace with actual field ID for question 1
    'q2': 'entry.YOUR_FIELD_ID_FOR_Q2', // Replace with actual field ID for question 2
    'q3': 'entry.YOUR_FIELD_ID_FOR_Q3', // Replace with actual field ID for question 3
  };

  final String fallbackContact = '+82 10-1234-5678'; // Your fallback contact

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _textControllers = List.generate(
      _questions.length,
      (index) => TextEditingController(),
    );

    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _launchForm(BuildContext context, String url) async {
    final theme = Theme.of(context);
    try {
      await custom_tabs.launchUrl(
        Uri.parse(url),
        // preferencesDeepLink is not a direct parameter for launchUrl,
        // it's usually handled by the platform specific options if available
        // or by how the URL scheme is registered.
        // For web URLs, it typically opens in the default browser or Custom Tab.
        customTabsOptions: custom_tabs.CustomTabsOptions( // For Android Custom Tabs
          colorSchemes: custom_tabs.CustomTabsColorSchemes.defaults(
            toolbarColor: theme.primaryColor, // Use your app's theme color
          ),
          // Other CustomTabsOptions...
        ),
        // For iOS, SFSafariViewControllerOptions can be used if needed,
        // but url_launcher handles it well by default.
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the form: $e')),
      );
    }
  }

  void _submitAnswers() {
    if (googleFormBaseUrl == null || googleFormBaseUrl!.contains("YOUR_FORM_ID")) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상담 신청 양식 URL이 설정되지 않았습니다. 관리자에게 문의하세요.')),
      );
      return;
    }

    StringBuffer urlParams = StringBuffer();
    bool firstParam = true;

    for (int i = 0; i < _questions.length; i++) {
      String questionIdKey = _questions[i]['id']!;
      String? fieldId = googleFormFieldIds[questionIdKey];
      String answer = _textControllers[i].text;

      if (fieldId != null && fieldId.isNotEmpty && !fieldId.contains("YOUR_FIELD_ID")) {
        if (!firstParam) {
          urlParams.write('&');
        }
        urlParams.write('$fieldId=${Uri.encodeComponent(answer)}');
        firstParam = false;
      } else {
        print("Warning: Google Form Field ID for question '${_questions[i]['text']}' is not configured or is a placeholder.");
      }
    }

    if (urlParams.isNotEmpty) {
      final String finalUrl = '$googleFormBaseUrl&$urlParams';
      print('Launching Google Form URL: $finalUrl'); // For debugging
      _launchForm(context, finalUrl);
    } else if (googleFormBaseUrl != null && !googleFormBaseUrl!.contains("YOUR_FORM_ID")) {
      // If no parameters were added but a base URL exists (maybe a general contact form)
      print('Launching Google Form URL without specific answers (field IDs might be missing): $googleFormBaseUrl');
      _launchForm(context, googleFormBaseUrl!);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('답변을 전달할 수 없습니다. Google Form 필드 ID 설정을 확인해주세요.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    // Fallback UI if googleFormBaseUrl is not set up properly
    // if (googleFormBaseUrl != null || googleFormBaseUrl!.contains("YOUR_FORM_ID")) {
    //   return Scaffold(
    //     appBar: AppBar(title: const Text('마음 이야기 카드')),
    //     body: Padding(
    //       padding: const EdgeInsets.all(16.0),
    //       child: Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             const Icon(Icons.error_outline, color: Colors.red, size: 50),
    //             const SizedBox(height: 20),
    //             const Text(
    //               '상담 신청 양식을 불러올 수 없습니다.',
    //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //               textAlign: TextAlign.center,
    //             ),
    //             const SizedBox(height: 12),
    //             Text(
    //               '서비스 관리자에게 문의하거나, 다음 연락처로 직접 문의해주세요:\n$fallbackContact',
    //               textAlign: TextAlign.center,
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('마음 이야기 카드'),
        backgroundColor: const Color(0xFFE6EAE4), // Soft green/beige
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7F7F1), // Light beige background
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _questions.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildQuestionCard(
                  _questions[index]['text']!,
                  _questions[index]['hint']!,
                  _textControllers[index],
                );
              },
            ),
          ),
          _buildNavigationControls(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String question, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        color: Colors.white, // Card background
        child: Padding(
          padding: const EdgeInsets.all(20.0),

          child: SingleChildScrollView(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min, // <--- Column이 최소한의 공간만 차지하도록 추가

            children: [
              Text(
                question,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: controller,
                maxLines: 5,
                style: TextStyle(color: Colors.grey[700]),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
            ],
          ),
        ),

        ),
      ),
    );
  }

  Widget _buildNavigationControls() {
    bool isLastPage = _currentPage == _questions.length - 1;
    bool isFirstPage = _currentPage == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _questions.length,
              effect: WormEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: Theme.of(context).primaryColor, // Use theme color
                dotColor: Colors.grey.shade300,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Previous" Button
              Opacity(
                opacity: isFirstPage ? 0.5 : 1.0, // Dim if it's the first page
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  label: const Text('이전'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200], // Lighter color for secondary button
                    foregroundColor: Colors.grey[700],
                  ),
                  onPressed: isFirstPage
                      ? null // Disable if it's the first page
                      : () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        },
                ),
              ),

              // "Next" or "Submit" Button
              ElevatedButton.icon(
                icon: Icon(isLastPage ? Icons.check_circle_outline : Icons.arrow_forward_ios),
                label: Text(isLastPage ? '작성 완료하고 전달하기' : '다음'),
                 style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor, // Theme color
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16)
                ),
                onPressed: () {
                  if (isLastPage) {
                    _submitAnswers();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}