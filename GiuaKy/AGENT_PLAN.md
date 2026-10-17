# MASTER PLAN & SPECIFICATION: HỆ THỐNG THI TOEIC READING (WEB ADMIN & FLUTTER MOBILE)

## 1. MỤC TIÊU ĐẦU RA & TIÊU CHÍ CHẤM ĐIỂM (10/10 ĐIỂM)
Coding Agent cần xây dựng hệ thống hoàn chỉnh để đạt trọn vẹn 8 tiêu chí đánh giá trong đề thi và có đủ 7 hạng mục chụp ảnh màn hình trong file `BaoCao-HovaTen-Masinhvien.docx`[cite: 4, 34]:
1. **File WORD TOEIC (1 điểm):** Tạo bộ file `.docx` từ `EnglishTest.pdf`, `Đề thi giữa kỳ v2.pdf` và `Reading v09.pdf` có định dạng chuẩn với đầy đủ bộ Tags[cite: 1, 2, 4, 5, 35].
2. **Phân tích & thiết kế CSDL (1 điểm):** Thiết kế MS SQL Server chuẩn hóa phân cấp (Level 1: Part 5; Level 2: Part 6 & Part 7) + Xuất file `database_erd.html` vẽ **Sơ đồ Database (ERD)** để chụp hình vào báo cáo[cite: 1, 2, 4, 34].
3. **Upload file, tạo đề thi từ Word, kích hoạt ca thi (1 điểm):** Giao diện Admin Import `.docx` (rollback 100% nếu có bất kỳ lỗi định dạng nào) + Nút Xuất bản đề thi (`IsPublished`)[cite: 2, 4, 34].
4. **Cập nhật, chỉnh sửa nội dung đề thi (1 điểm):** Giao diện Admin Xem trước (Preview) rà soát lỗi chính tả/hình ảnh và màn hình Chỉnh sửa (Edit) đoạn văn, câu hỏi, đáp án sau khi import[cite: 2, 4, 34].
5. **Hiển thị danh sách đề thi trên Mobile (1 điểm):** Mở ứng dụng Flutter vào thẳng danh sách đề thi (**không cần đăng ký/đăng nhập**), hiển thị tên đề, thời gian làm bài, số lượng câu hỏi thực tế của đề đó[cite: 2, 4, 34].
6. **Chức năng thi trên Mobile + Thiết kế Figma/Google Stitch (3 điểm):**
   * Đếm ngược thời gian thực (75 phút), cảnh báo khi sắp hết giờ, tự động thu bài và khóa chọn đáp án khi hết giờ[cite: 3].
   * Lưu tạm đáp án đang chọn, cho phép thay đổi hoặc bấm lại để hủy lựa chọn (clear selection) trước khi nộp[cite: 3].
   * **QUY TẮC NỘP BÀI SỚM:** Người dùng chỉ cần làm tối thiểu từ **1–2 câu** là có thể bấm "Nộp bài" để tính điểm ngay (hiển thị popup kiểm tra tổng số câu chưa hoàn thành và xác nhận trước khi gửi)[cite: 3].
7. **Hiển thị kết quả thi (1 điểm):** Chấm điểm tự động trên Server, hiển thị tổng số câu Đúng, câu Sai, câu Bỏ qua và xem lại lời giải (`Hint`)[cite: 2, 3, 4, 34].
8. **Giao diện đẹp, thân thiện + Thống kê (1 điểm):** UI/UX hiện đại + Trang thống kê số lượt làm bài, điểm trung bình, Top 10 câu hỏi sinh viên làm sai nhiều nhất[cite: 2, 4, 34].

---

## 2. CẤU TRÚC THƯ MỤC DỰ ÁN BẮT BUỘC
Tuân thủ tuyệt đối cấu trúc thư mục gốc `GiuaKy` gồm 2 thư mục chính `backend` và `frontend`[cite: 3]:

```text
GiuaKy/
├── docker-compose.yml                              # Chạy MS SQL Server 2022 trên Docker
├── docs/
│   ├── database_erd.html                           # Trang hiển thị Sơ đồ Database (ERD) để chụp ảnh báo cáo
│   ├── stitch_figma_prompts.md                     # Bộ prompt tạo thiết kế trên Google Stitch / Figma
│   ├── DeThi_EnglishTest_Part5_Part6.docx          # File Word đề 1 (30 câu Part 5 từ EnglishTest.pdf + 4 câu Part 6 mẫu)
│   ├── DeThi_ETS_Test09_Full100.docx               # File Word đề 2 (Đủ 100 câu Part 5, 6, 7 từ Reading v09.pdf)
│   └── DeThi_LoiDinhDang_DemoRollback.docx         # File Word cố tình thiếu Tag/sai thứ tự để demo Rollback
├── scripts/
│   └── generate_exam_files_and_report.py           # Script tự động tạo các file .docx đề thi và điền mô tả vào Báo cáo
├── backend/                                        # ASP.NET Boilerplate (ASP.NET Core MVC + jQuery - MPA)
└── frontend/                                       # Ứng dụng di động Flutter
```

---

## 3. CẤU HÌNH DOCKER CHO MICROSOFT SQL SERVER
Tạo file `GiuaKy/docker-compose.yml` để khởi chạy SQL Server qua Docker mà không cần cài đặt SQL Server lên máy[cite: 4]:

```yaml
version: '3.8'
services:
  sqlserver:
    image: [mcr.microsoft.com/mssql/server:2022-latest](https://mcr.microsoft.com/mssql/server:2022-latest)
    # Nếu máy dùng chip Apple Silicon (M1/M2/M3/M4), đổi image thành: [mcr.microsoft.com/azure-sql-edge:latest](https://mcr.microsoft.com/azure-sql-edge:latest)
    container_name: toeic_sqlserver
    environment:
      - ACCEPT_EULA=Y
      - MSSQL_SA_PASSWORD=ToeicApp@2026StrongPass!
      - MSSQL_PID=Developer
    ports:
      - "1433:1433"
    volumes:
      - sqlserver_data:/var/opt/mssql
    restart: unless-stopped

volumes:
  sqlserver_data:
```
* **Connection String (`appsettings.json` trong `backend`):**
  `Server=localhost,1433;Database=ToeicExamDb;User Id=sa;Password=ToeicApp@2026StrongPass!;TrustServerCertificate=True;MultipleActiveResultSets=true;`

---

## 4. THIẾT KẾ CƠ SỞ DỮ LIỆU & XUẤT SƠ ĐỒ ERD

### 4.1. Cấu trúc 6 bảng CSDL (Đáp ứng cấu trúc phân cấp Level 1 & Level 2)
Hệ thống tách thành 6 bảng quan hệ để xử lý câu hỏi độc lập (Part 5) và câu hỏi nhóm theo đoạn văn/hình ảnh (Part 6 & Part 7)[cite: 1, 2]:

1. **`Exams` (Đề thi):**
   * `Id` (int, PK, Identity)
   * `Title` (nvarchar(255), Required) - Tên đề thi[cite: 2].
   * `DurationMinutes` (int, Default: 75) - Thời gian làm bài (mặc định 75 phút)[cite: 2, 3, 6, 35].
   * `TotalQuestions` (int) - **Tính động (Dynamic)** theo tổng số câu hỏi thực tế trong file Word import vào (VD: 30 câu, 34 câu, hoặc 100 câu)[cite: 1, 2, 6, 35].
   * `IsPublished` (bit, Default: 0) - Trạng thái xuất bản (`1`: Cho phép sinh viên thi, `0`: Nháp/Đóng)[cite: 2].
   * `CreationTime` (datetime2)

2. **`QuestionGroups` (Nhóm câu hỏi / Đoạn văn bài đọc):**
   * `Id` (int, PK, Identity)
   * `ExamId` (int, FK -> `Exams.Id`, Cascade Delete)
   * `PartNumber` (int) - Giá trị `5`, `6`, hoặc `7`[cite: 1].
   * `DirectionText` (nvarchar(500), Nullable) - Câu dẫn (VD: *"Questions 131-134 refer to the following advertisement."*)[cite: 1].
   * `PassageContentHtml` (nvarchar(max), Nullable) - Nội dung đoạn văn/bảng biểu (Part 5 để `NULL`, Part 6 & 7 chứa nội dung bài đọc)[cite: 1].
   * `PassageImageUrls` (nvarchar(max), Nullable) - Danh sách đường dẫn ảnh trích xuất từ file `.docx` (nếu có)[cite: 1, 2].
   * `OrderIndex` (int) - Thứ tự hiển thị nhóm.

3. **`Questions` (Câu hỏi):**
   * `Id` (int, PK, Identity)
   * `ExamId` (int, FK -> `Exams.Id`)
   * `QuestionGroupId` (int, FK -> `QuestionGroups.Id`, Cascade Delete)
   * `QuestionNumber` (int) - Số thứ tự câu hỏi (VD: 101..130 hoặc 101..200)[cite: 1, 6, 33, 35, 37].
   * `QuestionText` (nvarchar(max)) - Nội dung câu hỏi (Part 6 có thể chỉ là số thứ tự `"131."`)[cite: 1, 9].
   * `Hint` (nvarchar(max), Nullable) - Gợi ý / giải thích câu trả lời[cite: 2].
   * `AllowShuffleQuestion` (bit, Default: 0) - Tag d: Cho phép hoán vị câu hỏi[cite: 2].
   * `AllowShuffleAnswers` (bit, Default: 0) - Tag e: Cho phép hoán vị câu trả lời[cite: 2].

4. **`QuestionOptions` (4 Lựa chọn A, B, C, D):**
   * `Id` (int, PK, Identity)
   * `QuestionId` (int, FK -> `Questions.Id`, Cascade Delete)
   * `OptionLabel` (varchar(5)) - `'A'`, `'B'`, `'C'`, `'D'`[cite: 1, 35].
   * `OptionText` (nvarchar(max)) - Nội dung đáp án[cite: 1, 2, 35].
   * `IsCorrect` (bit) - `1` là đáp án đúng, `0` là đáp án sai[cite: 1, 2].

5. **`ExamAttempts` (Lượt thi của người học - Không cần tài khoản):**
   * `Id` (int, PK, Identity)
   * `ExamId` (int, FK -> `Exams.Id`, Cascade Delete)
   * `StudentDevice` (nvarchar(100), Default: `'Mobile_Student'`)
   * `StartTime` (datetime2)
   * `SubmitTime` (datetime2)
   * `TimeSpentSeconds` (int)
   * `CorrectCount` (int) - Tổng số câu đúng[cite: 3].
   * `WrongCount` (int) - Tổng số câu sai[cite: 3].
   * `SkippedCount` (int) - Tổng số câu bỏ qua[cite: 3].
   * `Score` (float) - Điểm số quy đổi[cite: 2].

6. **`ExamAttemptAnswers` (Chi tiết từng câu trả lời để thống kê Top 10 câu sai):**
   * `Id` (int, PK, Identity)
   * `ExamAttemptId` (int, FK -> `ExamAttempts.Id`, Cascade Delete)
   * `QuestionId` (int, FK -> `Questions.Id`, NoAction)
   * `SelectedOptionId` (int, Nullable, FK -> `QuestionOptions.Id`, NoAction) - `NULL` nếu bỏ qua[cite: 3].
   * `IsCorrect` (bit) - `1` nếu đúng, `0` nếu sai hoặc bỏ qua[cite: 2, 3].

### 4.2. Xuất Sơ đồ Database (`GiuaKy/docs/database_erd.html`)
Tạo trang HTML độc lập dùng `mermaid.js` vẽ sơ đồ quan hệ thực thể (ERD) của 6 bảng trên để sinh viên mở trên trình duyệt và chụp màn hình đưa vào mục **"Sơ đồ database"** trong file `BaoCao-HovaTen-Masinhvien.docx`[cite: 34].

---

## 5. QUY CHUẨN BỘ TAGS TRONG FILE WORD (`.DOCX`) & DỮ LIỆU ĐỀ THI

### 5.1. Cú pháp bộ Tags bắt buộc (Đáp ứng đủ 5 tiêu chí a, b, c, d, e)
```text
[EXAM_TITLE: Tên đề thi]
[DURATION: 75]

[PART: 5]
[Q: 101] Ms. Durkin asked for volunteers to help ------- with the employee fitness program.
[SHUFFLE_Q: TRUE]
[SHUFFLE_A: TRUE]
[A] she
[B] her
[C] hers
[D] herself
[KEY: B]
[HINT: Sau động từ "help" cần một đại từ tân ngữ chỉ người (Ms. Durkin). Đáp án đúng là (B) her.]
[END_Q]

[PART: 6]
[PASSAGE_START]
Questions 131-134 refer to the following advertisement.
With Global Strength Gym's 30-day trial period, you get the opportunity to try out our classes, equipment, and facilities. It's completely risk-free! ---[131]---. To sign up, we require your contact information and payment details, but you will only be charged if you are a member for ---[132]--- 30 days. If you decide within this time that you no longer want to be a member of Global Strength, visit our Web site at [www.gsgym.com](https://www.gsgym.com). On the Membership page, ---[133]--- elect to ---[134]--- your membership and enter the necessary information. It's that easy!
[PASSAGE_END]
[Q: 131] Chọn câu phù hợp điền vào vị trí [131]
[SHUFFLE_Q: FALSE]
[SHUFFLE_A: TRUE]
[A] Throughout the trial, you pay nothing and sign no contract.
[B] Weight-lifting classes are not currently available.
[C] A cash deposit is required when you sign up for membership.
[D] All questions should be e-mailed to customerservice@gsgym.com.
[KEY: A]
[HINT: Câu trước nói "It's completely risk-free!" (Hoàn toàn không có rủi ro), nên câu giải thích hợp lý nhất là trong suốt thời gian dùng thử bạn không phải trả tiền hay ký hợp đồng.]
[END_Q]
```

### 5.2. Bảng Đáp án (`[KEY]`) & Gợi ý (`[HINT]`) chuẩn cho 30 câu trong `EnglishTest.pdf` (Câu 101–130) và Part 6 mẫu (Câu 131–134)
Script `generate_exam_files_and_report.py` phải nhúng chính xác nội dung câu hỏi từ `EnglishTest.pdf`[cite: 35, 36, 37] và `Đề thi giữa kỳ v2.pdf`[cite: 1] cùng bộ đáp án dưới đây:
* **101:** `[KEY: B]` (her - tân ngữ sau động từ help)[cite: 1, 35]
* **102:** `[KEY: C]` (knowledge - danh từ sau tính từ extensive và trước giới từ of)[cite: 35]
* **103:** `[KEY: A]` (Once - cụm chỉ tần suất "Once a year": mỗi năm một lần)[cite: 35]
* **104:** `[KEY: D]` (because - liên từ chỉ nguyên nhân nối 2 mệnh đề)[cite: 35]
* **105:** `[KEY: B]` (about - thông tin về tác phẩm nghệ thuật: Information about)[cite: 35]
* **106:** `[KEY: C]` (easily - trạng từ bổ nghĩa cho động từ thường see)[cite: 35]
* **107:** `[KEY: A]` (affordable - cấu trúc keep + O + Adj: giữ chi phí ở mức phải chăng)[cite: 35]
* **108:** `[KEY: D]` (occupied - động từ chia thì quá khứ đơn trước mệnh đề before)[cite: 35]
* **109:** `[KEY: C]` (revisions - nộp tất cả các bản chỉnh sửa cho cuốn sách)[cite: 36]
* **110:** `[KEY: A]` (Only - trạng từ nhấn mạnh ở đầu câu: Chỉ những chuyên gia trong ngành...)[cite: 36]
* **111:** `[KEY: A]` (accepted - ông Jones đã nhận chiếc cúp tại bữa tiệc)[cite: 36]
* **112:** `[KEY: C]` (predictable - tính từ đứng sau linking verb become)[cite: 36]
* **113:** `[KEY: D]` (between - cấu trúc between A and B: giữa nhân viên bán hàng và khách hàng)[cite: 36]
* **114:** `[KEY: A]` (may call - động từ khuyết thiếu chỉ khả năng ở hiện tại/tương lai)[cite: 36]
* **115:** `[KEY: B]` (When - liên từ chỉ thời gian: Khi Jemburger mở chi nhánh mới nhất...)[cite: 36]
* **116:** `[KEY: B]` (correspondence - danh từ: thư từ/liên lạc với bộ phận CSKH)[cite: 36]
* **117:** `[KEY: A]` (of - cụm danh từ awareness of something: nhận thức về ô nhiễm đại dương)[cite: 36]
* **118:** `[KEY: B]` (personalized - tính từ phân từ bổ nghĩa cho cụm danh từ promotional items)[cite: 36]
* **119:** `[KEY: A]` (As long as - miễn là mức tăng tiền thuê dưới 2%)[cite: 36]
* **120:** `[KEY: D]` (are being performed - câu bị động ở thì hiện tại tiếp diễn phù hợp với động từ meets ở hiện tại)[cite: 36]
* **121:** `[KEY: B]` (appropriate - người giám sát bộ phận thích hợp/tương ứng)[cite: 37]
* **122:** `[KEY: D]` (preservation - danh từ song song với shipping để tạo cụm danh từ "preservation and shipping methods")[cite: 37]
* **123:** `[KEY: A]` (requirements - xem xét các yêu cầu ngân sách hàng năm)[cite: 37]
* **124:** `[KEY: C]` (partly - trạng từ: một phần là kết quả của thời điểm may mắn)[cite: 37]
* **125:** `[KEY: D]` (everything - ghi chép lại mọi thứ mà nhóm thảo luận đã bàn)[cite: 37]
* **126:** `[KEY: B]` (overall - xếp thứ ba toàn diện/tổng thể về doanh thu khu vực)[cite: 37]
* **127:** `[KEY: D]` (As a result of + cụm danh từ: Do sự phổ biến của loa không dây BPT39)[cite: 37]
* **128:** `[KEY: C]` (whose - đại từ quan hệ sở hữu bổ nghĩa cho danh từ offices)[cite: 37]
* **129:** `[KEY: D]` (Unforeseen - những sự kiện không lường trước được)[cite: 37]
* **130:** `[KEY: D]` (allow for - tính đến / cho phép có sự đóng góp ý kiến từ ủy ban môi trường)[cite: 37]
* **131–134 (Part 6 mẫu trong đề giữa kỳ):** `131: A`, `132: C (over)`, `133: D (simply)`, `134: C (cancel)`[cite: 1].

---

## 6. YÊU CẦU CHI TIẾT PHÂN HỆ BACKEND (`GiuaKy/backend`)
Sử dụng template **ASP.NET Core MVC + jQuery** từ `https://aspnetboilerplate.com/Templates`[cite: 3].

### 6.1. Quy tắc Validate & Import File Word (`WordExamParserService`)
* Hỗ trợ linh hoạt mọi số lượng câu hỏi trong file Word (VD: đề 30 câu chỉ có Part 5, đề 34 câu có Part 5 & 6, hoặc đề 100 câu đủ Part 5, 6, 7)[cite: 1, 2, 6, 35].
* **Kiểm tra nghiêm ngặt & Rollback 100%:**
  * Phải có ít nhất 1 câu hỏi trong đề.
  * Mỗi câu hỏi phải có đủ tag `[Q: số]`, đủ 4 đáp án `[A]`, `[B]`, `[C]`, `[D]`, đúng 1 tag `[KEY: A/B/C/D]` và kết thúc bằng `[END_Q]`[cite: 2].
  * Số thứ tự câu hỏi phải liên tục tăng dần (không được trùng số câu hoặc nhảy cóc, ví dụ từ 101 nhảy lên 103 là báo lỗi ngay)[cite: 2].
  * Nếu thuộc `[PART: 6]` hoặc `[PART: 7]`, bắt buộc phải nằm sau một khối `[PASSAGE_START]...[PASSAGE_END]`[cite: 1, 2].
  * Nếu phát hiện bất kỳ lỗi nào, **hủy bỏ toàn bộ không lưu vào CSDL** và trả về danh sách lỗi chi tiết lên màn hình để Giảng viên sửa file[cite: 2]. Chỉ lưu vào CSDL khi file chuẩn 100%[cite: 2].

### 6.2. Các màn hình Web dành cho Giảng viên (Phục vụ Báo cáo & Chấm điểm)
1. **Giao diện Admin: Import đề thi (`Exam/Import`):** Upload file `.docx`, hiển thị kết quả kiểm tra định dạng (Thành công hoặc Danh sách lỗi chi tiết)[cite: 2, 34].
2. **Giao diện Admin: Xem trước & Chỉnh sửa nội dung đề thi sau khi import (`Exam/Preview/{id}`):**
   * Rà soát lỗi chính tả, kiểm tra hiển thị đoạn văn và hình ảnh[cite: 2].
   * Nút **"Chỉnh sửa"** trên từng đoạn văn và từng câu hỏi: mở Modal cho phép sửa nội dung đoạn văn, câu hỏi, 4 đáp án, đáp án đúng, gợi ý (`Hint`) và lưu vào CSDL[cite: 2, 3, 4, 34].
   * Nút **"Xuất bản đề thi / Kích hoạt ca thi"**: đổi trạng thái `IsPublished = true` để sinh viên bắt đầu thấy đề thi trên Mobile[cite: 2, 4].
3. **Giao diện Admin: Thống kê và Phân tích (`Exam/Statistics/{id}`):**
   * Thống kê tổng số lượt làm bài của từng đề, điểm trung bình, và bảng **Top 10 câu hỏi nhiều sinh viên làm sai nhất**[cite: 2].

---

## 7. YÊU CẦU CHI TIẾT PHÂN HỆ FRONTEND (`GiuaKy/frontend` - FLUTTER MOBILE)

### 7.1. Hai quy tắc nghiệp vụ cốt lõi trên Mobile
1. **VÀO THI LUÔN KHÔNG CẦN ĐĂNG KÝ / ĐĂNG NHẬP:** Mở app là vào thẳng màn hình danh sách các đề thi đã xuất bản (`ExamListScreen`)[cite: 2, 34]. Toàn bộ API gọi về Backend sử dụng `[AbpAllowAnonymous]`.
2. **LÀM TỐI THIỂU 1–2 CÂU LÀ ĐƯỢC NỘP BÀI TÍNH ĐIỂM:**
   * Ngay khi người dùng chọn đáp án cho **từ 1 câu trở lên** (`answeredCount >= 1`), nút **"Nộp bài"** được kích hoạt cho phép bấm nộp.
   * Khi bấm **"Nộp bài"**, hiển thị hộp thoại xác nhận kiểm tra tổng số câu chưa hoàn thành (tính theo `exam.totalQuestions` thực tế của đề đó, ví dụ 30 câu hoặc 100 câu)[cite: 3]:
     > *"Bạn đã hoàn thành **X / {TotalQuestions}** câu (còn **Y** câu chưa làm). Bạn có chắc chắn muốn nộp bài để chấm điểm ngay không?"*[cite: 3]
   * Khi xác nhận, gửi dữ liệu lên Server chấm điểm tự động và mở màn hình Kết quả[cite: 3].

### 7.2. Ba màn hình người dùng trên Flutter (Khớp 100% với Báo cáo)
1. **Giao diện Users: Chọn lựa đề thi (`ExamListScreen`):** Hiển thị danh sách các đề thi đã xuất bản (tên đề, thời gian làm bài 75 phút, tổng số câu hỏi thực tế của đề) và nút **"Bắt đầu thi"**[cite: 2, 34].
2. **Giao diện Users: Làm bài thi (`ExamTakingScreen`):**
   * Đếm ngược thời gian thực (75:00), cảnh báo khi còn dưới 5 phút, tự động thu bài và khóa chọn đáp án khi hết giờ[cite: 3].
   * Hiển thị câu hỏi độc lập cho Part 5 và hiển thị đoạn văn kèm nhóm câu hỏi phụ thuộc cho Part 6 & Part 7[cite: 1].
   * Lưu tạm các đáp án đang chọn; cho phép đổi đáp án khác hoặc **bấm lại vào đáp án đã chọn để hủy lựa chọn** trước khi nộp[cite: 3].
   * Bảng lưới câu hỏi (Question Palette) giúp chuyển câu nhanh và theo dõi những câu đã làm / chưa làm[cite: 3].
3. **Giao diện Users: Hiển thị kết quả bài thi (`ExamResultScreen`):**
   * Hiển thị điểm số và thống kê rõ ràng: **Tổng số câu Đúng**, **Tổng số câu Sai**, **Tổng số câu Bỏ qua**[cite: 3, 34].
   * Xem lại chi tiết từng câu hỏi kèm đáp án đúng và phần gợi ý giải thích (`Hint`)[cite: 2, 3].