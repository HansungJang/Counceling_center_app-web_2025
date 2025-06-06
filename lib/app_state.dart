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
  final String _therapistProfileDocId = 'main_therapist'; // Therapist profile document ID
  String get therapistProfileDocId => _therapistProfileDocId; // getter 추가, therapist_page.dart에서 edit button에 활용
  
  User? _user;
  User? get user => _user;

  ApplicationState() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
    ensureTherapistProfileExists();
    ensureSampleTherapyAreasExist();
  }

// #1. [login methods]

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


  // #2. [about_us methods]

  // About Us 카드 가져오기 (Stream)
  Stream<QuerySnapshot<Map<String, dynamic>>> getAboutCards() {
    return _firestore
        .collection('about_us')
        .orderBy('order', descending: false) // 'order' 필드로 정렬
        .snapshots();
  }

  // About Us 카드 추가
  Future<void> addAboutCard(String title, String content, int order) async {
    if (_user == null) return; // 로그인한 사용자만 추가 가능하도록 (필요시)
    try {
      await _firestore.collection('about_us').add({
        'title': title,
        'content': content,
        'order': order,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // 'createdBy': _user!.uid, // 필요시 작성자 정보 추가
      });
      print("About Us 카드 추가 성공");
    } catch (e) {
      print("About Us 카드 추가 실패: $e");
      throw e; // 오류를 다시 던져 UI에서 처리할 수 있도록 함
    }
  }

  // About Us 카드 수정
  Future<void> updateAboutCard(String cardId, String title, String content, int order) async {
    if (_user == null) return; // 로그인한 사용자만 수정 가능하도록 (필요시)
    try {
      await _firestore.collection('about_us').doc(cardId).update({
        'title': title,
        'content': content,
        'order': order,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print("About Us 카드 수정 성공");
    } catch (e) {
      print("About Us 카드 수정 실패: $e");
      throw e;
    }
  }

  // About Us 카드 삭제
  Future<void> deleteAboutCard(String cardId) async {
    if (_user == null) return; // 로그인한 사용자만 삭제 가능하도록 (필요시)
    try {
      await _firestore.collection('about_us').doc(cardId).delete();
      print("About Us 카드 삭제 성공");
    } catch (e) {
      print("About Us 카드 삭제 실패: $e");
      throw e;
    }
  }
  
  // #3. [therapist profile methods]
  // Therapist 프로필 가져오기 (단일 문서 Stream)
  Stream<DocumentSnapshot<Map<String, dynamic>>> getTherapistProfile() {
    return _firestore
        .collection('therapist_profile')
        .doc(_therapistProfileDocId)
        .snapshots();
  }

  // Therapist 프로필 생성 또는 업데이트
  Future<void> updateTherapistProfile({
    required String name,
    required String titleCredentials,
    required String affiliation,
    required String specialties, // 기존 specialties 필드명 유지
    required String message,
    String? imageUrl, // 선택 사항
  }) async {
    if (_user == null) return; // 로그인한 사용자만 (필요시 관리자만)
    try {
      await _firestore
          .collection('therapist_profile')
          .doc(_therapistProfileDocId)
          .set( // set 메서드를 사용하여 문서가 없으면 생성, 있으면 덮어쓰기 (또는 update)
        {
          'name': name,
          'titleCredentials': titleCredentials,
          'affiliation': affiliation,
          'specialties': specialties, // Firestore 필드명 일치
          'message': message,
          if (imageUrl != null) 'imageUrl': imageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // merge:true 로 기존 필드 유지하며 업데이트
      );
      print("Therapist 프로필 업데이트 성공");
    } catch (e) {
      print("Therapist 프로필 업데이트 실패: $e");
      throw e;
    }
  }

  // 초기 Therapist 프로필 데이터 생성 (앱 초기 설정 시 또는 필요에 따라 호출)
  Future<void> ensureTherapistProfileExists() async {
    final docRef = _firestore.collection('therapist_profile').doc(_therapistProfileDocId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      await updateTherapistProfile(
        name: '김OO (상담심리 석사)',
        titleCredentials: 'MA Counseling Psychology',
        affiliation: '힐링트리 센터 소속\n한국상담심리학회 인증 상담심리사 2급',
        specialties: '불안, 트라우마, 여성 건강 전문',
        message: '치유를 향한 작은 발걸음도 용기있는 시작입니다. 당신의 속도에 맞춰 함께 길을 찾아가겠습니다.',
        // imageUrl: '기본 이미지 URL 또는 null'
      );
      print('초기 Therapist 프로필이 생성되었습니다.');
    }
  }

  // #4. [therapy_area methods]
  // Therapy Areas 가져오기 (Stream)
  Stream<QuerySnapshot<Map<String, dynamic>>> getTherapyAreas() {
    return _firestore
        .collection('therapy_areas')
        .orderBy('order', descending: false) // 'order' 필드로 정렬
        .snapshots();
  }

  // 관리자를 위한 Therapy Area 추가/수정/삭제 메소드 (about_us.dart 와 유사하게 구현 가능)
  // 예시: addTherapyArea, updateTherapyArea, deleteTherapyArea
  // 이 부분은 현재 요청의 핵심이 아니므로, 필요시 about_us.dart를 참고하여 추가해주세요.

  // 임시 상담 분야 데이터
  final List<Map<String, dynamic>> _sampleTherapyAreasData = [
    {
      'title': "아동 상담 (샘플)",
      'description': "정서적 지원, 발달 문제 등 (샘플 데이터)",
      'iconName': "child_care",
      'order': 1,
    },
    {
      'title': "청소년 상담 (샘플)",
      'description': "학업 스트레스, 진로 고민 등 (샘플 데이터)",
      'iconName': "school",
      'order': 2,
    },
    {
      'title': "성인 상담 (샘플)",
      'description': "직장 스트레스, 대인 관계 등 (샘플 데이터)",
      'iconName': "people",
      'order': 3,
    },
  ];

  // therapy_areas 컬렉션에 샘플 데이터가 없으면 추가하는 로직
  Future<void> ensureSampleTherapyAreasExist() async {
    final collectionRef = _firestore.collection('therapy_areas');
    final snapshot = await collectionRef.limit(1).get(); // 데이터가 있는지 확인하기 위해 1개만 가져옴

    if (snapshot.docs.isEmpty) {
      // 데이터가 없으면 샘플 데이터 추가
      print('therapy_areas 컬렉션에 데이터가 없어 샘플 데이터를 추가합니다.');
      for (final areaData in _sampleTherapyAreasData) {
        try {
          // title을 기준으로 이미 존재하는지 한 번 더 체크 (선택 사항, 중복 방지 강화)
          final existingDoc = await collectionRef.where('title', isEqualTo: areaData['title']).limit(1).get();
          if (existingDoc.docs.isEmpty) {
            await collectionRef.add({
              ...areaData, // 샘플 데이터 복사
              'createdAt': FieldValue.serverTimestamp(), // 생성 시간 추가 (선택 사항)
            });
          }
        } catch (e) {
          print('샘플 상담 분야 추가 중 오류 발생: $e');
        }
      }
      print('샘플 상담 분야 데이터 추가 완료.');
    }
  }

  // #5. [consultation_page methods] 상담신청 내용 제출 
  Future<void> submitConsultation({
    required List<String> questions,
    required List<String> answers,
  }) async {
    // 로그인한 사용자만 제출 가능하도록 확인
    if (_user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    // 질문과 답변을 Map 형태로 조합
    final Map<String, String> qaPair = {};
    for (int i = 0; i < questions.length; i++) {
      qaPair['question_${i + 1}'] = questions[i];
      qaPair['answer_${i + 1}'] = answers[i].isNotEmpty ? answers[i] : '답변 없음';
    }

    try {
      await _firestore.collection('consultations').add({
        'userId': _user!.uid, // 신청한 사용자 ID
        'userEmail': _user!.email ?? '이메일 정보 없음', // 사용자 이메일 (연락용)
        'consultationData': qaPair, // 질문-답변 쌍
        'submittedAt': FieldValue.serverTimestamp(), // 제출 시간
        'status': 'new', // 초기 상태: 'new', 'contacted', 'completed' 등
      });
      print('상담 신청 내용이 성공적으로 Firestore에 저장되었습니다.');
    } catch (e) {
      print('Firestore에 상담 신청 내용 저장 중 오류 발생: $e');
      throw e; // 오류를 UI에 전달
    }
  }


}