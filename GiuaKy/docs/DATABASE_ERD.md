# Sơ đồ Thực thể Cơ sở dữ liệu (Database ERD)

Hệ thống thi TOEIC Reading (Level 1: Part 5 & Level 2: Part 6, Part 7)  
Cơ sở dữ liệu: **Microsoft SQL Server 2022**

---

## 1. Sơ đồ Quan hệ Thực thể (Mermaid ERD)

```mermaid
erDiagram
    EXAMS ||--o{ QUESTION_GROUPS : "1 Exam có N Groups"
    EXAMS ||--o{ QUESTIONS : "1 Exam chứa N Questions"
    EXAMS ||--o{ EXAM_ATTEMPTS : "1 Exam có N Lượt thi"
    QUESTION_GROUPS ||--o{ QUESTIONS : "1 Group gồm N Questions"
    QUESTIONS ||--o{ QUESTION_OPTIONS : "1 Question có 4 Options"
    QUESTIONS ||--o{ EXAM_ATTEMPT_ANSWERS : "1 Question có trong N câu trả lời"
    EXAM_ATTEMPTS ||--o{ EXAM_ATTEMPT_ANSWERS : "1 Lượt thi gồm N Chi tiết đáp án"
    QUESTION_OPTIONS ||--o{ EXAM_ATTEMPT_ANSWERS : "Tùy chọn được chọn"

    EXAMS {
        int Id PK "Khóa chính"
        string Title "Tên đề thi"
        int DurationMinutes "Thời gian thi (75 phút)"
        int TotalQuestions "Tổng số câu hỏi (30 - 100 câu)"
        boolean IsPublished "Trạng thái mở đề thi (0: Đóng, 1: Mở)"
        datetime CreationTime "Thời gian tạo đề"
    }

    QUESTION_GROUPS {
        int Id PK "Khóa chính"
        int ExamId FK "Khóa ngoại Exams"
        int PartNumber "Phần thi (Part 5, 6, 7)"
        string DirectionText "Câu dẫn hướng dẫn"
        string PassageContentHtml "Nội dung bài đọc HTML"
        string PassageImagesJson "JSON danh sách URL ảnh"
        int OrderIndex "Thứ tự sắp xếp nhóm"
    }

    QUESTIONS {
        int Id PK "Khóa chính"
        int ExamId FK "Khóa ngoại Exams"
        int QuestionGroupId FK "Khóa ngoại QuestionGroups"
        int QuestionNumber "Số thứ tự câu (101 - 200)"
        string QuestionText "Nội dung câu hỏi"
        string Hint "Gợi ý / Lời giải chi tiết"
        boolean AllowShuffleQuestion "Cho phép đảo câu hỏi"
        boolean AllowShuffleAnswers "Cho phép đảo 4 đáp án"
    }

    QUESTION_OPTIONS {
        int Id PK "Khóa chính"
        int QuestionId FK "Khóa ngoại Questions"
        string OptionLabel "Nhãn A, B, C, D"
        string OptionText "Nội dung lựa chọn đáp án"
        boolean IsCorrect "Đáp án đúng (1: Đúng, 0: Sai)"
    }

    EXAM_ATTEMPTS {
        int Id PK "Khóa chính"
        int ExamId FK "Khóa ngoại Exams"
        string DeviceId "Mã định danh thiết bị Mobile"
        datetime StartTime "Thời gian bắt đầu làm bài"
        datetime SubmitTime "Thời gian nộp bài thi"
        int TimeSpentSeconds "Tổng thời gian làm bài (giây)"
        int AnsweredCount "Số câu đã làm"
        int CorrectCount "Số câu đúng"
        int WrongCount "Số câu sai"
        int SkippedCount "Số câu bỏ qua"
        float Score "Điểm thi quy đổi (Thang 495)"
    }

    EXAM_ATTEMPT_ANSWERS {
        int Id PK "Khóa chính"
        int ExamAttemptId FK "Khóa ngoại ExamAttempts"
        int QuestionId FK "Khóa ngoại Questions"
        int SelectedOptionId FK "Khóa ngoại QuestionOptions (Nullable)"
        boolean IsCorrect "Kết quả câu trả lời (1: Đúng, 0: Sai)"
    }
```

---

## 2. Chi tiết 6 Bảng CSDL

| Bảng | Khóa chính (PK) | Khóa ngoại (FK) | Mục đích |
| :--- | :--- | :--- | :--- |
| **`Exams`** | `Id` (int) | - | Lưu trữ thông tin đề thi, thời gian, số lượng câu hỏi và trạng thái xuất bản (`IsPublished`). |
| **`QuestionGroups`** | `Id` (int) | `ExamId` $\rightarrow$ `Exams(Id)` | Phục vụ Level 2: Nhóm đoạn văn bài đọc, câu dẫn và hình ảnh cho Part 6 và Part 7. Part 5 chứa các nhóm đơn lẻ. |
| **`Questions`** | `Id` (int) | `ExamId` $\rightarrow$ `Exams(Id)`<br>`QuestionGroupId` $\rightarrow$ `QuestionGroups(Id)` | Lưu nội dung câu hỏi (101–200), gợi ý giải thích (`Hint`), cờ cho phép xáo trộn câu/đáp án. |
| **`QuestionOptions`** | `Id` (int) | `QuestionId` $\rightarrow$ `Questions(Id)` | 4 lựa chọn (A, B, C, D) cho từng câu hỏi cùng cờ `IsCorrect` xác định đáp án đúng. |
| **`ExamAttempts`** | `Id` (int) | `ExamId` $\rightarrow$ `Exams(Id)` | Lưu lượt làm bài của thí sinh qua mobile app (không cần đăng nhập, ghi nhận `DeviceId`, thời gian, tổng số câu đúng/sai/bỏ qua, điểm). |
| **`ExamAttemptAnswers`**| `Id` (int) | `ExamAttemptId` $\rightarrow$ `ExamAttempts(Id)`<br>`QuestionId` $\rightarrow$ `Questions(Id)`<br>`SelectedOptionId` $\rightarrow$ `QuestionOptions(Id)` | Ghi nhận chi tiết từng lựa chọn của thí sinh nhằm phục vụ thống kê Top 10 câu hỏi sai nhiều nhất. |

---

## 3. Mối quan hệ và Ràng buộc toàn vẹn (Integrity Constraints)

* **Level 1 (Part 5 - Câu hỏi độc lập):** Mỗi `Question` liên kết với một `QuestionGroup` không có đoạn văn bài đọc (`PassageContentHtml` = NULL).
* **Level 2 (Part 6 & 7 - Câu hỏi chùm theo bài đọc):** Một `QuestionGroup` chứa đoạn văn/hình ảnh gắn với 3–5 `Questions` thuộc chùm bài đọc đó.
* **Cascade Delete:**
  * Xóa `Exam` $\rightarrow$ Xóa toàn bộ `QuestionGroups`, `Questions`, `ExamAttempts`.
  * Xóa `QuestionGroup` $\rightarrow$ Xóa toàn bộ `Questions` bên trong nhóm.
  * Xóa `Question` $\rightarrow$ Xóa 4 `QuestionOptions`.
  * Xóa `ExamAttempt` $\rightarrow$ Xóa chi tiết các `ExamAttemptAnswers`.
