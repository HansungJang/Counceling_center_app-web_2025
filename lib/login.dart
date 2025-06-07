// login.dart (with email/password login added)

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './app_state.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showEmailFields = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/center_logo.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  '마음 쉼',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4B5F4A),
                  ),
                ),
                const SizedBox(height: 40.0),

                if (_showEmailFields) ...[
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: '이메일'),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _signInWithEmailPassword(context),
                    child: const Text('로그인'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showEmailFields = false;
                      });
                    },
                    child: const Text('돌아가기'),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showEmailFields = true;
                      });
                    },
                    child: const Text('매니저 로그인'),
                  ),
                  TextButton(
                    onPressed: () => signInAsGuest(context),
                    child: const Text('시작하기'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Kakao 로그인 (예정)'),
                  ),
                ],

                const SizedBox(height: 20),
                const Text(
                  '숲에서의 휴식처럼,\n조용히 나를 돌아보는 시간',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithEmailPassword(BuildContext context) async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final appState = Provider.of<ApplicationState>(context, listen: false);
      await appState.waitUntilUserSynced();

      Navigator.pushReplacementNamed(context, "/");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인 실패: $e')));
    }
  }
}

// Future<void> signInAsGuest(BuildContext context) async {
//   final prefs = await SharedPreferences.getInstance();
//   final savedUid = prefs.getString('anonymous_uid');

//   try {
//     if (savedUid != null) {
//       final response = await http.post(
//         Uri.parse(
//           'https://us-central1-counceling-project2025.cloudfunctions.net/getCustomToken',
//         ),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'uid': savedUid}),
//       );

//       if (response.statusCode == 200) {
//         final token = jsonDecode(response.body)['token'];
//         await FirebaseAuth.instance.signInWithCustomToken(token);
//       } else {
//         await prefs.remove('anonymous_uid');
//         final userCred = await FirebaseAuth.instance.signInAnonymously();
//         final newUid = userCred.user?.uid;
//         if (newUid != null) {
//           await prefs.setString('anonymous_uid', newUid);
//         }
//       }
//     } else {
//       final userCred = await FirebaseAuth.instance.signInAnonymously();
//       final newUid = userCred.user?.uid;
//       if (newUid != null) {
//         await prefs.setString('anonymous_uid', newUid);
//       }
//     }

//     final appState = Provider.of<ApplicationState>(context, listen: false);
//     await appState.waitUntilUserSynced();

//     Navigator.pushReplacementNamed(context, "/");
//   } catch (e) {
//     print('❌ 로그인 실패: $e');
//   }
// }

Future<void> signInAsGuest(BuildContext context) async {
  try {
    // Firebase 익명 로그인을 직접 호출하는 가장 간단한 방식입니다.
    await FirebaseAuth.instance.signInAnonymously();

    // ApplicationState가 authStateChanges 리스너를 통해
    // 후속 작업을 처리하고 홈 화면으로 리디렉션할 것입니다.
    // 여기서는 별도의 화면 이동 로직이 필요 없습니다.

  } catch (e) {
    // 로그인 실패 시 에러 메시지를 화면에 표시합니다.
    print('❌ 익명 로그인 실패: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('익명 로그인에 실패했습니다: $e')),
    );
  }
}