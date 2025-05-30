import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

// import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ApplicationState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  User? get user => _user;

  ApplicationState() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }


  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      print("Google 로그인 취소됨");
      return; // 사용자가 로그인 취소
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    try {
      await _auth.signInWithCredential(credential);
      print("Google 로그인 성공");
    } catch (e) {
      print("Google 로그인 실패: $e");
    }
  }
  Future<void> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      _user = userCredential.user;
      print("익명 로그인 성공: ${_user?.uid}");
      await _createOrUpdateUserProfile(_user!);
    } catch (e) {
      print("익명 로그인 실패: $e");
    }
  }
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      print("이메일 로그인 성공: ${_user?.uid}");
      await _createOrUpdateUserProfile(_user!);
    } catch (e) {
      print("이메일 로그인 실패: $e");
    }
  }
  Future<void> registerWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      print("회원가입 성공: ${_user?.uid}");
      await _createOrUpdateUserProfile(_user!);
    } catch (e) {
      print("회원가입 실패: $e");
    }
  }

  Future<void> waitUntilUserSynced() async {
    while (_user == null) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    // document 생성 확인까지 기다릴 수도 있음 (선택)
    await Future.delayed(Duration(milliseconds: 300));
  }


  /// Firebase Auth 상태 변경 감지

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    //print("? authStateChanges 감지됨: ${firebaseUser?.uid}"); // for debug
    print("? 로그인된 UID: ${firebaseUser?.uid}"); // for debug

    _user = firebaseUser;
    if (_user != null) {
      await _createOrUpdateUserProfile(_user!);
    }
    notifyListeners();
  }

  /// Firestore에 사용자 프로필 생성 또는 업데이트

  Future<void> _createOrUpdateUserProfile(User user) async {
    final userDoc = _firestore.collection('user_list').doc(user.uid);
    try {
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        print("Firestore 저장 시도: ${user.uid}");
        await userDoc.set({
          'uid': user.uid,
          'email': user.email ?? 'Anonymous',
          'displayName': user.displayName ?? 'Anonymous',
          'photoURL':
              user.photoURL ??
              'http://handong.edu/site/handong/res/img/logo.png',
          'createdAt': FieldValue.serverTimestamp(),
          'status_message': 'I promise to take the test honestly before GOD.',
        });
        print("Firestore 저장 성공!");
      }
    } catch (e) {
      print("Firestore 저장 중 오류 발생: $e");
    }
  }

  /// 사용자 프로필 가져오기
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final userDoc = _firestore.collection('user_list').doc(uid);
    try {
      final docSnapshot = await userDoc.get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      } else {
        print("사용자 프로필이 존재하지 않습니다: $uid");
        return null;
      }
    } catch (e) {
      print("사용자 프로필 가져오기 중 오류 발생: $e");
      return null;
    }
  }

  /// 사용자 로그아웃
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Google 세션 해제
    await FirebaseAuth.instance.signOut(); // Firebase 세션 해제
    print("? 로그아웃 완료");
    _user = null;
    notifyListeners();
  }
  

  /// 사용자 삭제
  /// 사용자 삭제는 Firebase Auth에서만 가능하며, Firestore의 사용자 데이터는 별도로 삭제해야 함
  Future<void> deleteUser() async {
    if (_user == null) return;
    try {
      await _user!.delete();
      print("사용자 삭제 성공: ${_user!.uid}");
      // Firestore에서 사용자 데이터 삭제
      await _firestore.collection('user_list').doc(_user!.uid).delete();
      _user = null;
      notifyListeners();
    } catch (e) {
      print("사용자 삭제 실패: $e");
    }
  }
}