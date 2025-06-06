// [# mstp 방식 및 firestore extension, email 전달 logic]
// index.js

/**
 * Import function triggers from their respective submodules:
...
 */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions/v2");

const admin = require("firebase-admin");

// 전역 옵션 설정 (모든 v2 함수에 적용)
setGlobalOptions({region: "asia-northeast3"});

admin.initializeApp();
const db = admin.firestore();

// 새 상담 신청이 생성될 때 실행되는 함수 (v2 스타일)
exports.notifyManagerOnNewConsultation = onDocumentCreated(
    "consultations/{consultationId}",
    async (event) => {
      // v2에서는 snap, context 대신 event 객체를 사용합니다.
      const snap = event.data;
      if (!snap) {
        console.log("No data associated with the event");
        return;
      }
      const cData = snap.data();

      const userEmail = cData.userEmail || "이메일 없음";
      // toDate()가 필요 없을 수 있습니다. 타임스탬프 객체를 직접 사용합니다.
      const submittedAt = snap.createTime.toDate().toLocaleString("ko-KR");
      console.log(`새 상담 신청 접수: ${userEmail}`);

      // 관리자에게 보낼 이메일 내용 구성
      const emailContent = {
        to: ["hansung.j1106@gmail.com"], // TODO: 관리자 이메일 주소 입력
        message: {
          subject: "[마음 쉼] 새로운 상담 신청이 도착했습니다.",
          html: `
        <h1>새로운 상담 신청</h1>
        <p>새로운 상담 신청이 접수되었습니다. Firebase Console에서 자세한 내용을 확인해주세요.</p>
        <ul>
          <li><strong>신청자 이메일:</strong> ${userEmail}</li>
          <li><strong>신청 시간:</strong> ${submittedAt}</li>
          <li><strong>문서 ID:</strong> ${event.params.consultationId}</li>
        </ul>
        <p>감사합니다.</p>
      `,
        },
      };

      // 'mail' 컬렉션에 이메일 문서를 추가하여 Trigger Email 확장 프로그램 실행
      try {
        const writeResult = await db.collection("mail").add(emailContent);
        console.log(`관리자 이메일 요청 완료: ${writeResult.id}`);
      } catch (error) {
        console.error("이메일 알림 요청 중 오류 발생:", error);
      }
    });
