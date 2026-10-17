# KiemTraGiuaKy_2380601959_NguyenThanhTai

## HỆ THỐNG THI TOEIC READING - KIỂM TRA GIỮA KỲ

- **Sinh viên thực hiện:** Nguyễn Thanh Tài
- **Mã số sinh viên (MSSV):** 2380601959
- **Đề tài:** Xây dựng hệ thống thi TOEIC Reading (Web Admin & Mobile App)

---

## 1. Cấu Trúc Dự Án

```text
GiuaKy/
├── docker-compose.yml              # Khởi chạy MS SQL Server 2022 trên Docker
├── docs/                           # Tài liệu ERD, Tag specification, file Word mẫu & Báo cáo
│   ├── database_erd.html           # Sơ đồ CSDL tương tác HTML
│   ├── DATABASE_ERD.md             # Tài liệu thiết kế ERD
│   ├── database_erd.png            # Ảnh sơ đồ quan hệ CSDL
│   ├── ETS_Test_09_Tagged.docx     # Đề thi 100 câu chuẩn Tag
│   ├── sample_test_09.docx         # Đề mẫu kiểm thử
│   ├── figma_prototype.html        # Bản mẫu prototype giao diện Figma
│   └── BaoCao-NguyenThanhTai-2380601959.docx # File báo cáo giữa kỳ hoàn chỉnh
├── figma/                          # Thiết kế Figma & Google Stitch
│   ├── index.html                  # Bản thiết kế UI Figma tương tác
│   ├── toeic_admin_screen.svg      # Thiết kế màn hình Web Admin
│   ├── toeic_mobile_screens.svg    # Thiết kế màn hình Mobile App
│   └── *.png                       # Ảnh chụp thiết kế giao diện
├── backend/                        # ASP.NET Boilerplate (ASP.NET Core MVC + EF Core)
│   ├── src/
│   │   ├── Toeic2380601959.Web.Mvc # Web Admin & REST API cho Mobile
│   │   ├── Toeic2380601959.Application
│   │   ├── Toeic2380601959.Core
│   │   └── Toeic2380601959.EntityFrameworkCore
│   └── Toeic2380601959.sln
└── frontend/                       # Ứng dụng di động Flutter
    ├── lib/
    │   ├── main.dart
    │   ├── models/exam_models.dart
    │   ├── screens/
    │   │   ├── exam_list_screen.dart
    │   │   ├── exam_taking_screen.dart
    │   │   └── exam_result_screen.dart
    │   └── services/exam_service.dart
    └── pubspec.yaml
```

---

## 2. Hướng Dẫn Chạy Hệ Thống

### 2.1. Khởi động Cơ sở dữ liệu (Docker MS SQL Server)
```bash
cd GiuaKy
docker compose up -d
```
- Port: `1433`
- Database: `ToeicExamDb`
- User: `sa`
- Password: `ToeicApp@2026StrongPass!`

### 2.2. Khởi động Backend (ASP.NET Core Web MVC & API)
```bash
cd GiuaKy/backend/src/Toeic2380601959.Web.Mvc
dotnet run
```
- Web Admin URL: `http://localhost:5000` (hoặc `https://localhost:44311`)
- Các chức năng: Quản lý đề thi, Import Word `.docx` tự động bóc tách Tags, Xem trước (Preview), Chỉnh sửa đề thi, Xuất bản đề (`IsPublished`), Xem thống kê.

### 2.3. Khởi động Frontend (Flutter Mobile)
```bash
cd GiuaKy/frontend
flutter pub get
flutter run
```
- Ứng dụng di động truy cập trực tiếp danh sách đề thi (không cần đăng nhập).
- Đếm ngược thời gian thực (75 phút), tự động thu bài khi hết giờ.
- Hỗ trợ chọn, đổi và hủy chọn đáp án. Cho phép nộp bài sớm (chỉ cần làm >= 1 câu).
- Chấm điểm tự động và xem lại lời giải chi tiết.

---

## 3. Danh Mục Tiêu Chí Đánh Giá Hoàn Thành (8/8)
1. **File Word TOEIC chuẩn Tags (1.0đ):** Đầy đủ các thẻ `<Exam>`, `<Part>`, `<Group>`, `<Question>`, `<Option>`, `<Hint>`, `<Shuffle>` và demo Rollback khi gặp lỗi định dạng.
2. **Phân tích & thiết kế CSDL (1.0đ):** Mô hình quan hệ phân cấp 6 bảng (Level 1: Part 5; Level 2: Part 6 & Part 7).
3. **Upload file, tạo đề thi từ Word, kích hoạt ca thi (1.0đ):** Bóc tách tự động, kiểm tra tính hợp lệ và chức năng Publish đề thi.
4. **Cập nhật, chỉnh sửa nội dung đề thi (1.0đ):** Giao diện Preview và Edit câu hỏi/đáp án/đoạn văn trên Web Admin.
5. **Hiển thị danh sách đề thi trên Mobile (1.0đ):** Không cần đăng nhập, hiển thị động số lượng câu hỏi và thời gian làm bài.
6. **Chức năng thi trên Mobile + Thiết kế Figma (3.0đ):** Bộ prototype Figma chuẩn Material 3, đếm ngược thời gian, nộp bài sớm.
7. **Hiển thị kết quả thi (1.0đ):** Thống kê số câu đúng, sai, bỏ qua và xem giải thích chi tiết.
8. **Giao diện & Báo cáo thống kê (1.0đ):** Biểu đồ lượt thi, điểm trung bình và Top 10 câu hỏi sai nhiều nhất.
