# QUY CHUẨN BỘ TAGS FILE WORD (.DOCX) CHO ĐỀ THI TOEIC READING

## 1. Thông tin chung của đề thi
- `[EXAM_TITLE: <Tên đề thi>]`: Tên đề thi hiển thị trên hệ thống. Ví dụ: `[EXAM_TITLE: ETS TOEIC Reading Test 09]`
- `[DURATION: <Số phút>]`: Thời gian làm bài (mặc định 75 phút). Ví dụ: `[DURATION: 75]`

---

## 2. Khai báo Phần thi & Đoạn văn (Part 5, Part 6, Part 7)
- `[PART: 5]` | `[PART: 6]` | `[PART: 7]`: Bắt đầu một phần thi TOEIC.
  - **Part 5:** Các câu hỏi độc lập (Incomplete Sentences, Câu 101 - 130). Không có đoạn văn (`[PASSAGE_START]`).
  - **Part 6:** Điền vào đoạn văn (Text Completion, Câu 131 - 146). Gồm đoạn văn chứa các chỗ trống đánh số và nhóm 4 câu hỏi tương ứng.
  - **Part 7:** Đọc hiểu văn bản (Reading Comprehension, Câu 147 - 200). Gồm đoạn đơn (Single Passage) hoặc đoạn ghép (Multiple Passages như email, biên lai, memo, chat...) và danh sách câu hỏi.
- `[PASSAGE_START]` ... `<Nội dung đoạn văn / bảng biểu / hình ảnh>` ... `[PASSAGE_END]`:
  - Khối nội dung bài đọc cho nhóm câu hỏi thuộc Part 6 hoặc Part 7.
- `[GROUP_SHUFFLE_Q: TRUE/FALSE]`: Cho phép xáo trộn thứ tự các câu hỏi trong nhóm đoạn văn (Mặc định `FALSE`).

---

## 3. Khai báo Từng Câu hỏi (Đáp ứng đầy đủ 5 tiêu chí chuẩn)
Mỗi câu hỏi được khai báo theo cấu trúc chuẩn:
- `[Q: <Số thứ tự>] <Nội dung câu hỏi>`: Bắt đầu một câu hỏi với số câu (VD: `[Q: 101] Every batch of sauce at Generita's Bistro is...`).
- `[SHUFFLE_Q: TRUE/FALSE]`: Cho phép hoán vị vị trí câu hỏi khi sinh viên làm bài.
- `[SHUFFLE_A: TRUE/FALSE]`: Cho phép xáo trộn ngẫu nhiên 4 đáp án A, B, C, D khi phát đề.
- `[A] <Nội dung đáp án A>`
- `[B] <Nội dung đáp án B>`
- `[C] <Nội dung đáp án C>`
- `[D] <Nội dung đáp án D>`
- `[KEY: <A|B|C|D>]`: Đáp án chính xác của câu hỏi.
- `[HINT: <Giải thích đáp án, phân tích ngữ pháp/từ vựng>]`: Gợi ý và giải thích chi tiết khi xem lại bài thi sau khi nộp.
- `[END_Q]`: Đánh dấu kết thúc câu hỏi.

---

## 4. Quy tắc Validation 100% nghiêm ngặt khi Import
Hệ thống backend kiểm tra toàn bộ file Word trước khi lưu CSDL:
1. File phải có đúng thẻ `[EXAM_TITLE]` và `[DURATION]`.
2. Phải có đầy đủ 100 câu hỏi liên tục từ câu 101 đến câu 200 (không nhảy cóc, không trùng lặp số câu).
3. Mỗi câu hỏi bắt buộc có đủ 4 lựa chọn `[A]`, `[B]`, `[C]`, `[D]`.
4. Mỗi câu hỏi bắt buộc có đúng 1 đáp án `[KEY: ...]`.
5. Nếu vi phạm bất kỳ tiêu chí nào, hệ thống lập tức hủy giao dịch (Rollback 100%) và trả về danh sách chi tiết lỗi để người dùng sửa file.
