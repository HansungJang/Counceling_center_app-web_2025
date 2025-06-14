# 마음 쉼 (Mind Rest) - 상담 센터 소개 및 신청 앱

[](https://flutter.dev)
[](https://firebase.google.com)

\*\*'마음 쉼'\*\*은 1인 상담 센터를 운영하는 관리자와 상담을 필요로 하는 사용자 모두를 위한 Flutter 기반 모바일 애플리케이션입니다.

## 📄 프로젝트 소개

[cite\_start]이 프로젝트는 '배워서 남주자'는 정신을 실천하고자, 지인이 운영하는 1인 상담 센터를 위해 기획되었습니다[cite: 2]. Flutter와 Firebase의 서버리스 기능을 학습하고, 이를 활용하여 실제 사용 가치가 있는 서비스를 만드는 것을 목표로 했습니다.

  - \*\*사용자 (내담자)\*\*에게는 센터의 철학, 상담 분야, 위치 등 필요한 정보를 명확하고 편리하게 제공합니다.
  - [cite\_start]\*\*관리자 (상담사)\*\*에게는 앱 콘텐츠(소개글, 상담 분야 등)를 직접 수정하고, 새로운 상담 신청을 이메일로 자동 알림 받는 등 운영의 편의성을 제공합니다[cite: 1, 2, 9, 11].

## ✨ 주요 기능

  - [cite\_start]**동적 콘텐츠 관리**: 관리자는 앱 재배포 없이 센터 소개, 상담사 프로필, 상담 분야 등의 정보를 직접 추가/수정/삭제할 수 있습니다[cite: 14, 15].
  - [cite\_start]**단계별 상담 신청**: 여러 질문을 카드 형식으로 넘기며 답변을 작성하는 직관적인 상담 신청 UI를 제공합니다[cite: 49].
  - [cite\_start]**이메일 알림 자동화**: 사용자가 상담 신청을 완료하면, 관리자에게 해당 내용이 포함된 이메일이 **자동으로 발송**됩니다[cite: 50, 53].
  - [cite\_start]**지도 및 연락처 연동**: Google Maps를 통해 센터 위치를 시각적으로 안내하고, 전화/이메일/카카오톡으로 즉시 연결되는 바로가기 기능을 제공합니다[cite: 56, 58].

## 🛠️ 기술 스택 및 아키텍처

### Frontend

  - **Framework**: `Flutter`
  - **State Management**: `provider`
      - [cite\_start]`ChangeNotifier`를 상속받는 `ApplicationState` 클래스에서 앱의 상태와 비즈니스 로직을 중앙 집중적으로 관리합니다[cite: 9].

### Backend

  - **Platform**: `Firebase (Serverless)`
  - **Database**: `Firestore`
      - [cite\_start]NoSQL 데이터베이스를 사용하여 센터 정보, 사용자 프로필, 상담 신청 내역 등을 저장하고 관리합니다[cite: 18].
  - **Authentication**: `Firebase Auth`
      - [cite\_start]일반 사용자를 위한 익명 로그인과 관리자를 위한 이메일/비밀번호 로그인을 지원합니다[cite: 11].
  - **Automation**:
      - [cite\_start]`Cloud Functions`: Firestore의 특정 이벤트(문서 생성)를 감지하여 백엔드 로직을 자동으로 실행합니다[cite: 21].
      - [cite\_start]`Trigger Email from Firestore` (Extension): Firestore의 특정 컬렉션에 데이터가 추가되면, 설정된 SMTP 서버를 통해 이메일을 발송하는 확장 프로그램입니다[cite: 22].

### 🚀 이메일 알림 자동화 워크플로우

본 프로젝트의 핵심 아키텍처는 **사용자 행동에 따라 백엔드 서비스들이 연쇄적으로 반응하는 완전 자동화된 프로세스**입니다.

1.  [cite\_start]**데이터 접수**: 사용자가 앱에서 상담 신청서를 제출하면, 해당 내용은 `consultations` 컬렉션에 새로운 문서로 저장됩니다[cite: 16, 21].
2.  [cite\_start]**이벤트 감지**: `Cloud Functions`는 `consultations` 컬렉션에 문서가 생성되는 이벤트를 실시간으로 감지하여 `notifyManagerOnNewConsultation` 함수를 트리거합니다[cite: 29, 31].
3.  [cite\_start]**이메일 요청 생성**: 트리거된 함수는 상담 내용을 바탕으로, 이메일 발송에 필요한 정보(수신자, 제목, 본문 등)를 담아 `mail` 컬렉션에 새로운 문서를 생성합니다[cite: 23]. 이 `mail` 컬렉션은 SMTP 서버에 보낼 '요청서' 큐(Queue) 역할을 합니다.
4.  [cite\_start]**자동 발송**: `Trigger Email from Firestore` 확장 프로그램이 `mail` 컬렉션의 새 문서를 감지하고, 해당 내용을 관리자에게 이메일로 자동 발송하며 프로세스가 완료됩니다[cite: 23, 33].

이러한 서버리스 아키텍처 덕분에 별도의 서버 관리 없이도 안정적이고 확장 가능한 자동화 기능을 구현할 수 있었습니다.

## 📱 스크린샷
[![프로젝트 시연 영상](https://img.youtube.com/vi/lKNavrIi3U4/0.jpg)](https://youtu.be/lKNavrIi3U4)


## 🗺️ 향후 개발 계획 (Roadmap)

### Version 1.5

  - [cite\_start]**문서화 기능 강화**: 상담 신청 내용을 Google Docs나 Notion 페이지로 자동 전환하여 관리하는 기능을 추가합니다[cite: 63].
  - [cite\_start]**로그인 옵션 확장**: '카카오 소셜 로그인' 기능을 추가하여 사용자 접근성을 높입니다[cite: 64].

### Version 2.0

  - [cite\_start]**커뮤니티 및 소통 기능**: 공지사항 게시판 및 1:1 채팅 기능을 구현합니다[cite: 65].
  - [cite\_start]**웹 플랫폼 확장**: Flutter의 크로스플랫폼 장점을 활용하여 웹 버전을 배포합니다[cite: 66].

## ✍️ 개발자 및 정보

  - [cite\_start]**개발자**: 장한성 (22000638) [cite: 1]
  - [cite\_start]**개발 과정**: 본 프로젝트의 기획, 설계, 디버깅 및 코드 구현 아이디어 수립 과정에서 Gemini, ChatGPT와 같은 AI 어시스턴트의 도움을 받았습니다[cite: 70].
  - **이미지 출처**:
      - [cite\_start]상담센터 로고: '마음 쉼, 인지행동심리센터' [cite: 70]
      - [cite\_start]앱 배경 이미지: Flaticon ([https://www.flaticon.com/free-stickers/enviroment](https://www.flaticon.com/free-stickers/enviroment)) [cite: 70]

-----