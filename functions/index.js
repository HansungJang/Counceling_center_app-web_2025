// [# mstp 방식 및 firestore extension, email 전달 logic]
// index.js

/**
 * Import function triggers from their respective submodules:
...
 */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {setGlobalOptions} = require("firebase-functions/v2");

const admin = require("firebase-admin");

const {google} = require("googleapis"); // googleapis 임포트

// 전역 옵션 설정 (모든 v2 함수에 적용)
setGlobalOptions({region: "asia-northeast3"});

admin.initializeApp();
const db = admin.firestore();

// --- Google Sheets 설정 ---
const SPREADSHEET_ID =
// eslint-disable-next-line max-len
"1QWXYlDpYCKO88nJEH8uap1eeFyyboc85aUZ05MubrCc"; // TODO: 1단계에서 복사한 Sheet ID를 여기에 붙여넣으세요.
const SHEET_NAME = "data_record"; // TODO: 데이터를 기록할 시트의 이름 (기본값: 시트1)
const SERVICE_ACCOUNT_KEY_FILE = "./service-account-key.json"; // 추가한 키 파일 이름

// part1: 새 상담 신청이 생성될 때 실행되는 함수 (v2 스타일)
exports.notifyManagerOnNewConsultation = onDocumentCreated(
    "consultations/{consultationId}",
    async (event) => {
 
      const snap = event.data;
      if (!snap) {
        console.log("No data associated with the event");
        return;
      }
      const cData = snap.data();
      const userEmail = cData.userEmail || "이메일 없음";
      // toDate()가 필요 없을 수 있습니다. 타임스탬프 객체를 직접 사용합니다.
      const submittedAtDate = snap.createTime.toDate();
      // 타임존을 명시하여 시간을 더 정확하게 변환합니다.
      const submittedAtKR =
      submittedAtDate.toLocaleString("ko-KR", {timeZone: "Asia/Seoul"});
      console.log(`새 상담 신청 접수: ${userEmail}`);
      const anser1 = cData.consultationData.answer_1 || "답변 없음";
      const anser2 = cData.consultationData.answer_2 || "답변 없음";
      const anser3 = cData.consultationData.answer_3 || "답변 없음";
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
          <li><strong>신청 시간:</strong> ${submittedAtKR}</li>
          <li><strong>1질문 답변(고민, 신청사유):</strong> ${anser1}</li>
          <li><strong>2질문 답변(현상, 현재상황):</strong> ${anser2}</li>
          <li><strong>3질문 답변(목적, 희망사항):</strong> ${anser3}</li>
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

      // part2: Google Sheets에 데이터 기록
      try {
        const auth = new google.auth.JWT({ // JWT 인증 방식 사용
          keyFile: SERVICE_ACCOUNT_KEY_FILE, // googke sheet 연동 인증 error 해결
          scopes: ["https://www.googleapis.com/auth/spreadsheets"],
        });
        const sheets = google.sheets({version: "v4", auth});

        // 시트에 기록할 행 데이터 구성
        const newRow = [
          submittedAtKR,
          userEmail,
          anser1 || "",
          anser2 || "",
          anser3 || "",
          // 질문이 더 있다면 여기에 추가...
        ];

        await sheets.spreadsheets.values.append({
          spreadsheetId: SPREADSHEET_ID,
          range: SHEET_NAME, // <-- 셀 범위 없이 시트 이름만 전달합니다.
          valueInputOption: "USER_ENTERED",
          resource: {
            values: [newRow],
          },
        });
        console.log("Google Sheets에 데이터 기록 성공.");
      } catch (error) {
        console.error("Google Sheets 기록 중 오류 발생:", error);
      }

      return null;
    });
