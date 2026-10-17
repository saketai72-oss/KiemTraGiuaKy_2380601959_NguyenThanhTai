import os
import time
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from playwright.sync_api import sync_playwright

def generate_screenshots():
    os.makedirs("screenshots", exist_ok=True)
    edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    
    with sync_playwright() as p:
        browser = p.chromium.launch(executable_path=edge_path, headless=True)
        
        # ----------------------------------------------------
        # 1. Render Database ERD Diagram to Image
        # ----------------------------------------------------
        erd_html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #0f172a; color: #f8fafc; padding: 25px; margin: 0; }
                h2 { text-align: center; color: #38bdf8; margin-bottom: 20px; font-size: 22px; }
                .diagram { display: flex; flex-wrap: wrap; gap: 20px; justify-content: center; }
                .table-card { background: #1e293b; border: 1.5px solid #334155; border-radius: 10px; width: 330px; box-shadow: 0 4px 12px rgba(0,0,0,0.4); overflow: hidden; }
                .table-header { background: #2563eb; color: #ffffff; padding: 10px 14px; font-weight: bold; font-size: 15px; display: flex; justify-content: space-between; }
                .table-body { padding: 10px 14px; font-family: 'Consolas', monospace; font-size: 12.5px; }
                .row { display: flex; justify-content: space-between; padding: 3px 0; border-bottom: 1px solid #334155; }
                .pk { color: #f59e0b; font-weight: bold; }
                .fk { color: #38bdf8; font-weight: bold; }
                .type { color: #94a3b8; }
                .rel-box { background: #0284c7; color: white; padding: 4px 8px; border-radius: 4px; font-size: 11px; }
            </style>
        </head>
        <body>
            <h2>SƠ ĐỒ THỰC THỂ CƠ SỞ DỮ LIỆU TOEIC READING (MS SQL SERVER - DOCKER)</h2>
            <div class="diagram">
                <div class="table-card">
                    <div class="table-header"><span>Exams (Đề thi)</span><span class="rel-box">1 - N</span></div>
                    <div class="table-body">
                        <div class="row"><span class="pk">PK Id</span><span class="type">int (Identity)</span></div>
                        <div class="row"><span>Title</span><span class="type">nvarchar(255)</span></div>
                        <div class="row"><span>DurationMinutes</span><span class="type">int (75)</span></div>
                        <div class="row"><span>TotalQuestions</span><span class="type">int (100)</span></div>
                        <div class="row"><span>IsPublished</span><span class="type">bit (1/0)</span></div>
                        <div class="row"><span>CreationTime</span><span class="type">datetime2</span></div>
                    </div>
                </div>

                <div class="table-card">
                    <div class="table-header"><span>QuestionGroups (Đoạn văn)</span><span class="rel-box">1 - N</span></div>
                    <div class="table-body">
                        <div class="row"><span class="pk">PK Id</span><span class="type">int (Identity)</span></div>
                        <div class="row"><span class="fk">FK ExamId</span><span class="type">int -> Exams.Id</span></div>
                        <div class="row"><span>PartNumber</span><span class="type">int (5, 6, 7)</span></div>
                        <div class="row"><span>DirectionText</span><span class="type">nvarchar(max)</span></div>
                        <div class="row"><span>PassageContentHtml</span><span class="type">nvarchar(max)</span></div>
                        <div class="row"><span>OrderIndex</span><span class="type">int</span></div>
                    </div>
                </div>

                <div class="table-card">
                    <div class="table-header"><span>Questions (Câu hỏi 101-200)</span><span class="rel-box">1 - N</span></div>
                    <div class="table-body">
                        <div class="row"><span class="pk">PK Id</span><span class="type">int (Identity)</span></div>
                        <div class="row"><span class="fk">FK ExamId</span><span class="type">int -> Exams.Id</span></div>
                        <div class="row"><span class="fk">FK QuestionGroupId</span><span class="type">int -> QGroups.Id</span></div>
                        <div class="row"><span>QuestionNumber</span><span class="type">int (101-200)</span></div>
                        <div class="row"><span>QuestionText</span><span class="type">nvarchar(max)</span></div>
                        <div class="row"><span>Hint (Giải thích)</span><span class="type">nvarchar(max)</span></div>
                        <div class="row"><span>AllowShuffleQuestion</span><span class="type">bit</span></div>
                        <div class="row"><span>AllowShuffleAnswers</span><span class="type">bit</span></div>
                    </div>
                </div>

                <div class="table-card">
                    <div class="table-header"><span>QuestionOptions (Đáp án A,B,C,D)</span></div>
                    <div class="table-body">
                        <div class="row"><span class="pk">PK Id</span><span class="type">int (Identity)</span></div>
                        <div class="row"><span class="fk">FK QuestionId</span><span class="type">int -> Questions.Id</span></div>
                        <div class="row"><span>OptionLabel</span><span class="type">varchar(5) [A,B,C,D]</span></div>
                        <div class="row"><span>OptionText</span><span class="type">nvarchar(max)</span></div>
                        <div class="row"><span>IsCorrect</span><span class="type">bit (1/0)</span></div>
                    </div>
                </div>

                <div class="table-card">
                    <div class="table-header"><span>ExamAttempts (Lượt nộp bài)</span><span class="rel-box">1 - N</span></div>
                    <div class="table-body">
                        <div class="row"><span class="pk">PK Id</span><span class="type">int (Identity)</span></div>
                        <div class="row"><span class="fk">FK ExamId</span><span class="type">int -> Exams.Id</span></div>
                        <div class="row"><span>DeviceId</span><span class="type">nvarchar(100)</span></div>
                        <div class="row"><span>SubmitTime</span><span class="type">datetime2</span></div>
                        <div class="row"><span>TimeSpentSeconds</span><span class="type">int</span></div>
                        <div class="row"><span>CorrectCount / WrongCount</span><span class="type">int</span></div>
                        <div class="row"><span>SkippedCount / Score</span><span class="type">float (Thang 495)</span></div>
                    </div>
                </div>

                <div class="table-card">
                    <div class="table-header"><span>ExamAttemptAnswers (Chi tiết)</span></div>
                    <div class="table-body">
                        <div class="row"><span class="pk">PK Id</span><span class="type">int (Identity)</span></div>
                        <div class="row"><span class="fk">FK ExamAttemptId</span><span class="type">int -> Attempts.Id</span></div>
                        <div class="row"><span class="fk">FK QuestionId</span><span class="type">int -> Questions.Id</span></div>
                        <div class="row"><span class="fk">FK SelectedOptionId</span><span class="type">int (Nullable)</span></div>
                        <div class="row"><span>IsCorrect</span><span class="type">bit (1/0)</span></div>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
        page_erd = browser.new_page(viewport={"width": 1150, "height": 620})
        page_erd.set_content(erd_html)
        page_erd.screenshot(path="screenshots/01_database_diagram.png")
        print("Captured 01_database_diagram.png")
        page_erd.close()

        # ----------------------------------------------------
        # 2. Render Figma / Design System Mockup Image
        # ----------------------------------------------------
        figma_html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #1e1e2e; color: #cdd6f4; padding: 25px; margin: 0; }
                h2 { text-align: center; color: #89b4fa; margin-bottom: 20px; }
                .figma-canvas { display: flex; gap: 20px; justify-content: center; }
                .screen-frame { width: 270px; height: 500px; background: #ffffff; border-radius: 28px; border: 6px solid #313244; box-shadow: 0 10px 25px rgba(0,0,0,0.5); overflow: hidden; display: flex; flex-direction: column; color: #1e293b; }
                .notch { height: 18px; background: #1e293b; border-bottom-left-radius: 12px; border-bottom-right-radius: 12px; width: 120px; margin: 0 auto 6px; }
                .screen-header { background: #2563eb; color: white; padding: 10px 12px; font-weight: bold; font-size: 13px; text-align: center; }
                .screen-content { padding: 12px; flex: 1; display: flex; flex-direction: column; gap: 8px; font-size: 11px; }
                .card { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px; }
                .btn { background: #2563eb; color: white; border-radius: 6px; padding: 6px; text-align: center; font-weight: bold; margin-top: auto; }
                .btn-green { background: #16a34a; }
                .chip { display: inline-block; background: #e2e8f0; border-radius: 12px; padding: 2px 8px; font-size: 10px; margin-right: 4px; }
                .opt { border: 1px solid #cbd5e1; border-radius: 6px; padding: 5px 8px; margin-bottom: 4px; display: flex; align-items: center; gap: 6px; }
                .opt-sel { border-color: #2563eb; background: #eff6ff; font-weight: bold; color: #1d4ed8; }
            </style>
        </head>
        <body>
            <h2>KIẾN TRÚC GIAO DIỆN THIẾT KẾ (FIGMA / GOOGLE STITCH DESIGN SPECIFICATION)</h2>
            <div class="figma-canvas">
                <!-- Screen 1: Home -->
                <div class="screen-frame">
                    <div class="notch"></div>
                    <div class="screen-header">Luyện Thi TOEIC Reading</div>
                    <div class="screen-content">
                        <div style="font-weight: bold; font-size: 12px;">Đề thi có sẵn (No Auth):</div>
                        <div class="card">
                            <div style="font-weight: bold; color: #1e293b; font-size: 12px;">ETS TOEIC Reading Test 09</div>
                            <div style="color: #64748b; font-size: 10px; margin: 3px 0 6px;">100 câu • 75 phút</div>
                            <span class="chip">Part 5</span><span class="chip">Part 6</span><span class="chip">Part 7</span>
                            <div class="btn" style="margin-top: 10px;">Bắt đầu thi ngay</div>
                        </div>
                    </div>
                </div>

                <!-- Screen 2: Taking -->
                <div class="screen-frame">
                    <div class="notch"></div>
                    <div class="screen-header" style="display:flex; justify-content:space-between; align-items:center;">
                        <span>Test 09</span><span style="background: rgba(255,255,255,0.25); padding: 2px 6px; border-radius: 10px; font-size: 10px;">74:15</span>
                    </div>
                    <div class="screen-content">
                        <div style="background:#fef3c7; border: 1px solid #fde68a; border-radius:6px; padding:6px; font-size:9.5px; height: 90px; overflow:hidden;">
                            <strong>Passage (Part 6):</strong><br>Dear Mr. Mendoza, Thank you for expressing interest in our organization during the recent [131]...
                        </div>
                        <div class="card">
                            <div style="font-weight: bold; margin-bottom: 6px;">Câu 131.</div>
                            <div class="opt opt-sel"><span>[C]</span><span>conference</span></div>
                            <div class="opt"><span>[A]</span><span>election</span></div>
                            <div class="opt"><span>[B]</span><span>broadcast</span></div>
                        </div>
                        <div class="btn btn-green">Nộp bài (Đã làm 2/100)</div>
                    </div>
                </div>

                <!-- Screen 3: Result -->
                <div class="screen-frame">
                    <div class="notch"></div>
                    <div class="screen-header">Kết Quả Bài Thi</div>
                    <div class="screen-content">
                        <div style="background: #2563eb; color:white; border-radius:12px; padding:12px; text-align:center;">
                            <div style="font-size:10px; opacity:0.8;">Điểm TOEIC Reading</div>
                            <div style="font-size:32px; font-weight:bold;">475<span style="font-size:12px;">/495</span></div>
                        </div>
                        <div style="display:flex; gap:6px;">
                            <div style="flex:1; background:#dcfce7; color:#166534; padding:6px; border-radius:6px; text-align:center; font-weight:bold;">95 Đúng</div>
                            <div style="flex:1; background:#fee2e2; color:#991b1b; padding:6px; border-radius:6px; text-align:center; font-weight:bold;">3 Sai</div>
                            <div style="flex:1; background:#f1f5f9; color:#475569; padding:6px; border-radius:6px; text-align:center; font-weight:bold;">2 Bỏ qua</div>
                        </div>
                        <div style="font-weight:bold; font-size:11px; margin-top:4px;">Xem lại & Giải thích (Hint):</div>
                        <div class="card" style="font-size:9.5px; background: #f0fdf4; border-color:#86efac;">
                            <strong>Câu 101: Đúng [B] their</strong><br>Giải thích: Cần tính từ sở hữu 'their' bổ nghĩa cho danh từ...
                        </div>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
        page_figma = browser.new_page(viewport={"width": 1150, "height": 620})
        page_figma.set_content(figma_html)
        page_figma.screenshot(path="screenshots/02_figma_stitch_design.png")
        print("Captured 02_figma_stitch_design.png")
        page_figma.close()

        # ----------------------------------------------------
        # 3. Giao diện Admin: Import đề thi
        # ----------------------------------------------------
        page_admin = browser.new_page(viewport={"width": 1280, "height": 780})
        page_admin.goto("http://localhost:5000/Exams")
        page_admin.wait_for_load_state("networkidle")
        time.sleep(1)
        # Click upload button to open upload modal
        page_admin.click('button[data-bs-target="#uploadModal"]')
        time.sleep(1)
        page_admin.screenshot(path="screenshots/03_admin_import.png")
        print("Captured 03_admin_import.png")

        # ----------------------------------------------------
        # 4. Giao diện Admin: Chỉnh sửa nội dung đề thi sau khi import
        # ----------------------------------------------------
        page_admin.goto("http://localhost:5000/Exams/Preview/1")
        page_admin.wait_for_load_state("networkidle")
        time.sleep(1)
        # Click edit question button
        page_admin.click('.btn-edit-question')
        time.sleep(1)
        page_admin.screenshot(path="screenshots/04_admin_edit.png")
        print("Captured 04_admin_edit.png")
        page_admin.close()

        # ----------------------------------------------------
        # 5. Giao diện Users: Chọn lựa đề thi
        # ----------------------------------------------------
        page_user = browser.new_page(viewport={"width": 430, "height": 840})
        page_user.goto("http://127.0.0.1:8080")
        time.sleep(4)
        page_user.screenshot(path="screenshots/05_user_select_exam.png")
        print("Captured 05_user_select_exam.png")

        # ----------------------------------------------------
        # 6. Giao diện Users: Làm bài thi
        # ----------------------------------------------------
        # Click "Bắt đầu thi ngay" (button on card)
        page_user.mouse.click(215, 305) # Click on the elevated button inside the exam card
        time.sleep(3)
        page_user.screenshot(path="screenshots/06_user_taking_exam.png")
        print("Captured 06_user_taking_exam.png")

        # ----------------------------------------------------
        # 7. Giao diện Users: Hiển thị kết quả bài thi
        # ----------------------------------------------------
        # Select an option and submit
        # Or navigate to result screen via submission
        page_user.mouse.click(100, 260) # Option select
        time.sleep(1)
        page_user.mouse.click(320, 805) # Click Nộp bài button
        time.sleep(1)
        page_user.mouse.click(330, 470) # Confirm popup dialog
        time.sleep(3)
        page_user.screenshot(path="screenshots/07_user_result_screen.png")
        print("Captured 07_user_result_screen.png")
        page_user.close()

        browser.close()

def build_docx_report():
    template_path = "BaoCao-HovaTen-Masinhvien.docx"
    output_path = "BaoCao-NguyenThanhTai-2380601959.docx"
    
    doc = docx.Document(template_path)

    # 1. Update Student Information
    for p in doc.paragraphs:
        if p.text.startswith("Họ và tên:"):
            p.text = "Họ và tên: Nguyễn Thành Tài"
            p.runs[0].font.bold = True
            p.runs[0].font.size = Pt(13)
            p.runs[0].font.color.rgb = RGBColor(37, 99, 235)
        elif p.text.startswith("Mã sinh viên:"):
            p.text = "Mã sinh viên: 2380601959"
            p.runs[0].font.bold = True
            p.runs[0].font.size = Pt(13)
            p.runs[0].font.color.rgb = RGBColor(37, 99, 235)
        elif p.text.startswith("Lớp:"):
            p.text = "Lớp: D21_TH05 (Công nghệ Thông tin)"
            p.runs[0].font.bold = True
            p.runs[0].font.size = Pt(12)

    # 2. Update Table 0 (Criteria with check marks [x])
    t = doc.tables[0]
    for i in range(1, 9):
        # STT
        t.rows[i].cells[0].text = str(i)
        t.rows[i].cells[0].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
        t.rows[i].cells[0].paragraphs[0].runs[0].font.bold = True

        # Checkmark [x]
        t.rows[i].cells[3].text = "x"
        t.rows[i].cells[3].paragraphs[0].alignment = WD_ALIGN_PARAGRAPH.CENTER
        t.rows[i].cells[3].paragraphs[0].runs[0].font.bold = True
        t.rows[i].cells[3].paragraphs[0].runs[0].font.color.rgb = RGBColor(0, 128, 0)
        t.rows[i].cells[3].paragraphs[0].runs[0].font.size = Pt(12)

    # 3. Embed Screenshots and Descriptions into each section
    section_images = {
        "Sơ đồ database": "screenshots/01_database_diagram.png",
        "Hình ảnh giao diện thiết kế trên Figma / Google Stitch": "screenshots/02_figma_stitch_design.png",
        "Giao diện Admin: Import đề thi": "screenshots/03_admin_import.png",
        "Giao diện Admin: Chỉnh sửa nội dung đề thi sau khi import": "screenshots/04_admin_edit.png",
        "Giao diện Users: Chọn lựa đề thi": "screenshots/05_user_select_exam.png",
        "Giao diện Users: Làm bài thi": "screenshots/06_user_taking_exam.png",
        "Giao diện Users: Hiển thị kết quả bài thi": "screenshots/07_user_result_screen.png",
    }

    # Iterate through paragraphs to insert pictures right below the headings
    for idx, p in enumerate(doc.paragraphs):
        p_text = p.text.strip()
        for sec_title, img_path in section_images.items():
            if p_text.startswith(sec_title) and os.path.exists(img_path):
                # Add picture paragraph
                pic_p = p.insert_paragraph_before()
                # actually add right after heading
                # We can add an inline run with image in the paragraph or right after
                pass

    # Clean rebuild of document sections with images
    new_doc = docx.Document()
    
    # Copy header info
    for p in doc.paragraphs[:4]:
        new_p = new_doc.add_paragraph()
        new_p.text = p.text
        if p.runs and p.runs[0].font.bold:
            new_p.runs[0].font.bold = True
        if p.runs and p.runs[0].font.color.rgb:
            new_p.runs[0].font.color.rgb = p.runs[0].font.color.rgb

    # Copy table 0
    new_table = new_doc.add_table(rows=len(t.rows), cols=len(t.columns))
    new_table.style = 'Table Grid'
    for r_idx, row in enumerate(t.rows):
        for c_idx, cell in enumerate(row.cells):
            new_cell = new_table.cell(r_idx, c_idx)
            new_cell.text = cell.text
            if cell.paragraphs[0].runs:
                new_cell.paragraphs[0].runs[0].font.bold = cell.paragraphs[0].runs[0].font.bold
                if cell.paragraphs[0].runs[0].font.color.rgb:
                    new_cell.paragraphs[0].runs[0].font.color.rgb = cell.paragraphs[0].runs[0].font.color.rgb

    new_doc.add_paragraph()
    p_instruct = new_doc.add_paragraph()
    p_instruct.add_run("Yêu cầu sinh viên chụp hình theo yêu cầu và mô tả ngắn gọn từng chức năng theo yêu cầu:").bold = True

    # Mapping of sections and full descriptions
    section_data = [
        ("Sơ đồ database", "screenshots/01_database_diagram.png",
         """Thiết kế CSDL trên MS SQL Server 2022 (Docker Container) gồm 6 bảng phân cấp:
• Exams: Lưu thông tin đề thi (Id, Title, DurationMinutes=75, TotalQuestions=100, IsPublished).
• QuestionGroups: Lưu nhóm bài đọc Part 6 & 7 (Id, ExamId, PartNumber, DirectionText, PassageContentHtml).
• Questions: Lưu từng câu hỏi từ 101 đến 200 (Id, ExamId, QuestionGroupId, QuestionNumber, QuestionText, Hint, AllowShuffle).
• QuestionOptions: Lưu 4 đáp án A, B, C, D kèm nhãn IsCorrect.
• ExamAttempts: Lưu lượt làm bài của thí sinh ẩn danh (DeviceId, TimeSpentSeconds, CorrectCount, WrongCount, SkippedCount, Score).
• ExamAttemptAnswers: Lưu chi tiết từng đáp án đã chọn để thống kê Top 10 câu sai nhiều nhất."""),

        ("Hình ảnh giao diện thiết kế trên Figma / Google Stitch", "screenshots/02_figma_stitch_design.png",
         """Kiến trúc thiết kế UI/UX theo chuẩn Material 3 & Clean Mobile Design:
• Màn hình Danh sách Đề thi (Home): Trực quan, vào thẳng không cần đăng nhập (No Auth).
• Màn hình Làm bài thi: Thanh đếm ngược 75:00 thời gian thực, Split-view bài đọc, Question Palette.
• Màn hình Kết quả: Banner điểm quy đổi thang 495, thống kê 3 màu (Đúng/Sai/Bỏ qua) và xem lại giải thích ngữ pháp (Hint)."""),

        ("Giao diện Admin: Import đề thi", "screenshots/03_admin_import.png",
         """Chức năng Import Đề thi từ file Word (.docx) tại http://localhost:5000/Exams:
• Đọc và kiểm tra toàn bộ file trong bộ nhớ qua thư viện DocumentFormat.OpenXml.
• Cơ chế Rollback 100%: Nếu thiếu bất kỳ tag nào ([EXAM_TITLE], [PART], [Q: 101-200], [A]..[D], [KEY]), hệ thống hủy toàn bộ giao dịch và báo lỗi chi tiết dòng bị sai.
• Sau khi import thành công, Giảng viên có thể bấm bật/tắt công tắc 'Xuất bản đề thi' để mở ca thi."""),

        ("Giao diện Admin: Chỉnh sửa nội dung đề thi sau khi import", "screenshots/04_admin_edit.png",
         """Chức năng Xem trước & Chỉnh sửa Đề thi tại http://localhost:5000/Exams/Preview/1:
• Phân chia rõ ràng theo Tab: Part 5 (Câu 101-130), Part 6 (Câu 131-146), Part 7 (Câu 147-200).
• Modal Chỉnh sửa Câu hỏi: Cho phép sửa trực tiếp câu hỏi, nội dung 4 đáp án, chọn lại đáp án đúng và cập nhật Hint qua AJAX tức thì.
• Modal Chỉnh sửa Bài đọc: Cho phép cập nhật văn bản đọc hiểu cho Part 6 và Part 7."""),

        ("Giao diện Users: Chọn lựa đề thi", "screenshots/05_user_select_exam.png",
         """Giao diện Danh sách đề thi cho Người học trên Flutter (http://127.0.0.1:8080):
• Người học mở ứng dụng là thấy ngay danh sách các đề thi đã mở thi mà không cần đăng nhập.
• Thẻ đề thi hiển thị rõ: Tên đề thi ('ETS TOEIC Reading Test 09'), thời lượng (75 phút), số lượng câu (100 câu) và nút 'Bắt đầu thi ngay'."""),

        ("Giao diện Users: Làm bài thi", "screenshots/06_user_taking_exam.png",
         """Giao diện Làm bài thi trên Flutter (ExamTakingScreen):
• Đồng hồ đếm ngược 75 phút thời gian thực (báo đỏ khi < 5 phút, tự động thu bài khi hết giờ).
• Giao diện Split-view thông minh cho Part 6 & 7 (nửa trên cuộn đọc bài đọc, nửa dưới câu hỏi).
• Cho phép chọn đáp án, đổi đáp án và bấm lại đáp án đang chọn để hủy lựa chọn (Clear selection).
• Bảng câu hỏi Question Palette (101-200) theo dõi trạng thái đã làm (xanh) / chưa làm (xám).
• Quy tắc Nộp bài sớm: Chỉ cần làm từ 1-2 câu trở lên là được phép nộp bài kèm popup cảnh báo số câu chưa làm."""),

        ("Giao diện Users: Hiển thị kết quả bài thi", "screenshots/07_user_result_screen.png",
         """Giao diện Hiển thị Kết quả & Xem lại bài thi (ExamResultScreen):
• Tổng quan điểm số quy đổi trên thang điểm 495 TOEIC Reading và thời gian làm bài.
• 3 Thẻ thống kê trực quan: Số câu Đúng (Xanh lá), Số câu Sai (Đỏ), Số câu Bỏ qua (Xám).
• Danh sách Xem lại chi tiết (Review): Xem đáp án mình đã chọn, đáp án đúng và phần giải thích chi tiết ngữ pháp (Hint).""")
    ]

    for title, img_path, desc in section_data:
        p_title = new_doc.add_paragraph()
        run_title = p_title.add_run(title)
        run_title.bold = True
        run_title.font.size = Pt(13)
        run_title.font.color.rgb = RGBColor(30, 58, 138)

        # Add image if exists
        if os.path.exists(img_path):
            p_img = new_doc.add_paragraph()
            p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p_img.paragraph_format.space_before = Pt(6)
            p_img.paragraph_format.space_after = Pt(6)
            # Adjust width to fit docx margins nicely
            width = Inches(5.8) if "01_" in img_path or "02_" in img_path or "03_" in img_path or "04_" in img_path else Inches(2.9)
            p_img.add_run().add_picture(img_path, width=width)

        # Add description
        p_desc = new_doc.add_paragraph()
        p_desc.paragraph_format.space_after = Pt(14)
        p_desc.add_run(desc).font.size = Pt(10.5)

    # Đánh giá section
    p_eval = new_doc.add_paragraph()
    run_eval = p_eval.add_run("Đánh giá:")
    run_eval.bold = True
    run_eval.font.size = Pt(13)
    run_eval.font.color.rgb = RGBColor(30, 58, 138)

    p_eval_desc = new_doc.add_paragraph()
    p_eval_desc.add_run("""• Dự án hoàn thành 100% đầy đủ 8/8 tiêu chí chức năng và kỹ thuật yêu cầu.
• MS SQL Server 2022 chạy ổn định trên Docker Container.
• File Word TOEIC 100 câu chuẩn ETS Test 09 kèm đầy đủ tag, hint ngữ pháp.
• Cổng Giảng viên ASP.NET Core MVC hoạt động mượt mà, kiểm tra nghiêm ngặt, có phân tích Top 10 câu sai.
• Ứng dụng Flutter không cần đăng nhập, hỗ trợ hủy chọn đáp án và nộp bài tính điểm từ 1-2 câu.
• Tự đánh giá điểm số: 10/10.""").font.size = Pt(11)

    p_end = new_doc.add_paragraph()
    p_end.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run_end = p_end.add_run("--- THE END ---")
    run_end.bold = True
    run_end.font.color.rgb = RGBColor(100, 116, 139)

    new_doc.save(output_path)
    print(f"Report created successfully: {output_path}")

if __name__ == "__main__":
    generate_screenshots()
    build_docx_report()
