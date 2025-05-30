// app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'app_state.dart'; // Import ApplicationState
import 'Home.dart'; // HomePage
import 'about_us.dart'; // AboutPage
import 'therapist_page.dart'; // TherapistPage
import 'therapy_area.dart'; // TherapyPage
import 'consultation_page.dart'; // ConsultationPage
import 'location.dart'; // LocationPage
import 'login.dart'; // Import LoginPage

class MindRestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context);

    return MaterialApp(
      title: 'Mind Rest',
      theme: ThemeData(
        primaryColor: Color(0xFF7D9D81),
        scaffoldBackgroundColor: Color(0xFFF5F5F5),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),

      home: appState.user == null ? LoginPage() : HomePage(),
      // home: HomePage(),
       routes: {
        // '/': (context) => HomePage(),
        '/about': (context) => AboutPage(),
        '/therapist': (context) => TherapistPage(),
        '/therapyarea': (context) => TherapyPage(),
        '/consultation': (context) => ConsultationPage(),
        '/location': (context) => LocationPage(),
      },
    );
  }
}
