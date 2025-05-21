// app.dart
import 'package:flutter/material.dart';
import 'Home.dart'; // HomePage
import 'about_us.dart'; // AboutPage
import 'therapist_page.dart'; // TherapistPage
import 'therapy_area.dart'; // TherapyPage
// import 'consultation_page.dart'; // ConsultationPage
import 'location.dart'; // LocationPage

class MindRestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mind Rest',
      theme: ThemeData(
        primaryColor: Color(0xFF7D9D81),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/about': (context) => AboutPage(),
        '/therapist': (context) => TherapistPage(),
        '/therapyarea': (context) => TherapyPage(),
        // '/consultation': (context) => ConsultationPage(),
        '/location': (context) => LocationPage(),
      },
    );
  }
}
