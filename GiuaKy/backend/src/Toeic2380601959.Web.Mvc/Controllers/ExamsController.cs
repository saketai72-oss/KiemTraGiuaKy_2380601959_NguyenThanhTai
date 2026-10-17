using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Toeic2380601959.Controllers;
using Toeic2380601959.EntityFrameworkCore;
using Toeic2380601959.Toeic;

namespace Toeic2380601959.Web.Controllers
{
    public class EditQuestionInput
    {
        public int QuestionId { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public string? Hint { get; set; }
        public string Key { get; set; } = string.Empty; // A, B, C, D
        public string OptionA { get; set; } = string.Empty;
        public string OptionB { get; set; } = string.Empty;
        public string OptionC { get; set; } = string.Empty;
        public string OptionD { get; set; } = string.Empty;
    }

    public class EditPassageInput
    {
        public int GroupId { get; set; }
        public string? DirectionText { get; set; }
        public string? PassageContentHtml { get; set; }
    }

    [AllowAnonymous]
    public class ExamsController : Toeic2380601959ControllerBase
    {
        private readonly Toeic2380601959DbContext _dbContext;
        private readonly WordExamParserService _parserService;

        public ExamsController(Toeic2380601959DbContext dbContext, WordExamParserService parserService)
        {
            _dbContext = dbContext;
            _parserService = parserService;
        }

        // 1. Quản lý Đề thi
        public async Task<IActionResult> Index()
        {
            var exams = await _dbContext.Exams
                .OrderByDescending(e => e.CreationTime)
                .Include(e => e.ExamAttempts)
                .ToListAsync();

            return View(exams);
        }

        [HttpPost]
        public async Task<IActionResult> UploadDocx(IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return Json(new { success = false, errors = new[] { "Vui lòng chọn file Word (.docx) hợp lệ." } });
            }

            if (!file.FileName.EndsWith(".docx", StringComparison.OrdinalIgnoreCase))
            {
                return Json(new { success = false, errors = new[] { "Chỉ chấp nhận file định dạng .docx." } });
            }

            using var stream = file.OpenReadStream();
            var parseResult = await _parserService.ParseAndImportAsync(stream, file.FileName);

            if (!parseResult.IsSuccess)
            {
                return Json(new { success = false, errors = parseResult.Errors });
            }

            return Json(new { success = true, examId = parseResult.Exam?.Id, message = $"Import thành công đề thi: {parseResult.Exam?.Title}" });
        }

        [HttpPost]
        public async Task<IActionResult> TogglePublish(int id)
        {
            var exam = await _dbContext.Exams.FindAsync(id);
            if (exam == null)
            {
                return Json(new { success = false, message = "Không tìm thấy đề thi." });
            }

            exam.IsPublished = !exam.IsPublished;
            await _dbContext.SaveChangesAsync();

            return Json(new { success = true, isPublished = exam.IsPublished });
        }

        [HttpPost]
        public async Task<IActionResult> Delete(int id)
        {
            var exam = await _dbContext.Exams.FindAsync(id);
            if (exam == null)
            {
                return Json(new { success = false, message = "Không tìm thấy đề thi." });
            }

            _dbContext.Exams.Remove(exam);
            await _dbContext.SaveChangesAsync();

            return Json(new { success = true });
        }

        // 2. Xem trước & Chỉnh sửa Đề thi
        public async Task<IActionResult> Preview(int id)
        {
            var exam = await _dbContext.Exams
                .Include(e => e.QuestionGroups)
                    .ThenInclude(g => g.Questions)
                        .ThenInclude(q => q.Options)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (exam == null)
            {
                return NotFound("Không tìm thấy đề thi.");
            }

            return View(exam);
        }

        [HttpPost]
        public async Task<IActionResult> UpdateQuestion([FromBody] EditQuestionInput input)
        {
            var question = await _dbContext.Questions
                .Include(q => q.Options)
                .FirstOrDefaultAsync(q => q.Id == input.QuestionId);

            if (question == null)
            {
                return Json(new { success = false, message = "Không tìm thấy câu hỏi." });
            }

            question.QuestionText = input.QuestionText;
            question.Hint = input.Hint;

            var optA = question.Options.FirstOrDefault(o => o.OptionLabel == "A");
            if (optA != null) { optA.OptionText = input.OptionA; optA.IsCorrect = (input.Key == "A"); }

            var optB = question.Options.FirstOrDefault(o => o.OptionLabel == "B");
            if (optB != null) { optB.OptionText = input.OptionB; optB.IsCorrect = (input.Key == "B"); }

            var optC = question.Options.FirstOrDefault(o => o.OptionLabel == "C");
            if (optC != null) { optC.OptionText = input.OptionC; optC.IsCorrect = (input.Key == "C"); }

            var optD = question.Options.FirstOrDefault(o => o.OptionLabel == "D");
            if (optD != null) { optD.OptionText = input.OptionD; optD.IsCorrect = (input.Key == "D"); }

            await _dbContext.SaveChangesAsync();

            return Json(new { success = true });
        }

        [HttpPost]
        public async Task<IActionResult> UpdatePassage([FromBody] EditPassageInput input)
        {
            var group = await _dbContext.QuestionGroups.FindAsync(input.GroupId);
            if (group == null)
            {
                return Json(new { success = false, message = "Không tìm thấy đoạn văn." });
            }

            group.DirectionText = input.DirectionText;
            group.PassageContentHtml = input.PassageContentHtml;
            await _dbContext.SaveChangesAsync();

            return Json(new { success = true });
        }

        // 3. Thống kê & Phân tích Đề thi
        public async Task<IActionResult> Analytics(int id)
        {
            var exam = await _dbContext.Exams
                .Include(e => e.ExamAttempts)
                .FirstOrDefaultAsync(e => e.Id == id);

            if (exam == null)
            {
                return NotFound("Không tìm thấy đề thi.");
            }

            int totalAttempts = exam.ExamAttempts.Count;
            double avgScore = totalAttempts > 0 ? Math.Round(exam.ExamAttempts.Average(a => a.Score), 1) : 0;
            double avgCorrect = totalAttempts > 0 ? Math.Round(exam.ExamAttempts.Average(a => a.CorrectCount), 1) : 0;

            // Top 10 câu sai nhiều nhất
            var wrongAnswersQuery = await _dbContext.ExamAttemptAnswers
                .Where(a => a.ExamAttempt != null && a.ExamAttempt.ExamId == id && !a.IsCorrect)
                .GroupBy(a => a.QuestionId)
                .Select(g => new
                {
                    QuestionId = g.Key,
                    WrongCount = g.Count()
                })
                .OrderByDescending(x => x.WrongCount)
                .Take(10)
                .ToListAsync();

            var questionIds = wrongAnswersQuery.Select(x => x.QuestionId).ToList();
            var questionsMap = await _dbContext.Questions
                .Where(q => questionIds.Contains(q.Id))
                .ToDictionaryAsync(q => q.Id);

            var top10Wrong = wrongAnswersQuery.Select(w =>
            {
                var q = questionsMap.GetValueOrDefault(w.QuestionId);
                double failureRate = totalAttempts > 0 ? Math.Round((double)w.WrongCount / totalAttempts * 100, 1) : 0;
                return new
                {
                    w.QuestionId,
                    QuestionNumber = q?.QuestionNumber ?? 0,
                    QuestionText = q?.QuestionText ?? string.Empty,
                    w.WrongCount,
                    FailureRate = failureRate
                };
            }).ToList();

            ViewBag.TotalAttempts = totalAttempts;
            ViewBag.AvgScore = avgScore;
            ViewBag.AvgCorrect = avgCorrect;
            ViewBag.Top10Wrong = top10Wrong;

            return View(exam);
        }
    }
}
