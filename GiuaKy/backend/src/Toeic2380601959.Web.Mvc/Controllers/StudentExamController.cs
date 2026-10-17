using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Toeic2380601959.Controllers;
using Toeic2380601959.EntityFrameworkCore;
using Toeic2380601959.Toeic;

namespace Toeic2380601959.Web.Controllers
{
    public class StudentAnswerDto
    {
        public int QuestionId { get; set; }
        public int? SelectedOptionId { get; set; }
    }

    public class SubmitExamInputDto
    {
        public int ExamId { get; set; }
        public int TimeSpentSeconds { get; set; }
        public string? DeviceId { get; set; }
        public List<StudentAnswerDto> Answers { get; set; } = new List<StudentAnswerDto>();
    }

    public class QuestionDetailDto
    {
        public int Id { get; set; }
        public int QuestionNumber { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public List<OptionDetailDto> Options { get; set; } = new List<OptionDetailDto>();
    }

    public class OptionDetailDto
    {
        public int Id { get; set; }
        public string OptionLabel { get; set; } = string.Empty;
        public string OptionText { get; set; } = string.Empty;
    }

    public class QuestionGroupDetailDto
    {
        public int Id { get; set; }
        public int PartNumber { get; set; }
        public string? DirectionText { get; set; }
        public string? PassageContentHtml { get; set; }
        public int OrderIndex { get; set; }
        public List<QuestionDetailDto> Questions { get; set; } = new List<QuestionDetailDto>();
    }

    public class ExamForTakeDto
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public int DurationMinutes { get; set; }
        public int TotalQuestions { get; set; }
        public List<QuestionGroupDetailDto> Groups { get; set; } = new List<QuestionGroupDetailDto>();
    }

    public class QuestionResultReviewDto
    {
        public int QuestionId { get; set; }
        public int QuestionNumber { get; set; }
        public string QuestionText { get; set; } = string.Empty;
        public int? SelectedOptionId { get; set; }
        public int CorrectOptionId { get; set; }
        public string CorrectOptionLabel { get; set; } = string.Empty;
        public bool IsCorrect { get; set; }
        public string? Hint { get; set; }
        public List<OptionDetailDto> Options { get; set; } = new List<OptionDetailDto>();
    }

    public class SubmitExamResultDto
    {
        public int AttemptId { get; set; }
        public int ExamId { get; set; }
        public string ExamTitle { get; set; } = string.Empty;
        public int TimeSpentSeconds { get; set; }
        public int TotalQuestions { get; set; }
        public int AnsweredCount { get; set; }
        public int CorrectCount { get; set; }
        public int WrongCount { get; set; }
        public int SkippedCount { get; set; }
        public double Score { get; set; }
        public List<QuestionResultReviewDto> QuestionsReview { get; set; } = new List<QuestionResultReviewDto>();
    }

    [ApiController]
    [AllowAnonymous]
    public class StudentExamController : Toeic2380601959ControllerBase
    {
        private readonly Toeic2380601959DbContext _dbContext;

        public StudentExamController(Toeic2380601959DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        [HttpGet("api/services/app/StudentExam/GetPublishedExams")]
        [HttpGet("api/student/exams")]
        public async Task<IActionResult> GetPublishedExams()
        {
            var exams = await _dbContext.Exams
                .Where(e => e.IsPublished)
                .OrderByDescending(e => e.CreationTime)
                .Select(e => new
                {
                    e.Id,
                    e.Title,
                    e.DurationMinutes,
                    e.TotalQuestions,
                    e.CreationTime
                })
                .ToListAsync();

            return Ok(exams);
        }

        [HttpGet("api/services/app/StudentExam/GetExamForTake")]
        [HttpGet("api/student/exams/{id}")]
        public async Task<IActionResult> GetExamForTake([FromQuery] int? examId, int? id)
        {
            int targetExamId = examId ?? id ?? 0;

            var exam = await _dbContext.Exams
                .Include(e => e.QuestionGroups)
                    .ThenInclude(g => g.Questions)
                        .ThenInclude(q => q.Options)
                .FirstOrDefaultAsync(e => e.Id == targetExamId);

            if (exam == null)
            {
                return NotFound(new { error = "Không tìm thấy đề thi." });
            }

            if (!exam.IsPublished)
            {
                return BadRequest(new { error = "Đề thi này chưa được xuất bản hoặc đã đóng ca thi." });
            }

            var rng = new Random();

            var examDto = new ExamForTakeDto
            {
                Id = exam.Id,
                Title = exam.Title,
                DurationMinutes = exam.DurationMinutes,
                TotalQuestions = exam.TotalQuestions,
                Groups = exam.QuestionGroups
                    .OrderBy(g => g.OrderIndex)
                    .Select(g =>
                    {
                        var groupDto = new QuestionGroupDetailDto
                        {
                            Id = g.Id,
                            PartNumber = g.PartNumber,
                            DirectionText = g.DirectionText,
                            PassageContentHtml = g.PassageContentHtml,
                            OrderIndex = g.OrderIndex
                        };

                        var questionsList = g.Questions.ToList();

                        if (questionsList.Any(q => q.AllowShuffleQuestion))
                        {
                            questionsList = questionsList.OrderBy(_ => rng.Next()).ToList();
                        }
                        else
                        {
                            questionsList = questionsList.OrderBy(q => q.QuestionNumber).ToList();
                        }

                        groupDto.Questions = questionsList.Select(q =>
                        {
                            var optionsList = q.Options.ToList();

                            if (q.AllowShuffleAnswers)
                            {
                                optionsList = optionsList.OrderBy(_ => rng.Next()).ToList();
                            }
                            else
                            {
                                optionsList = optionsList.OrderBy(o => o.OptionLabel).ToList();
                            }

                            return new QuestionDetailDto
                            {
                                Id = q.Id,
                                QuestionNumber = q.QuestionNumber,
                                QuestionText = q.QuestionText,
                                Options = optionsList.Select(o => new OptionDetailDto
                                {
                                    Id = o.Id,
                                    OptionLabel = o.OptionLabel,
                                    OptionText = o.OptionText
                                }).ToList()
                            };
                        }).ToList();

                        return groupDto;
                    }).ToList()
            };

            return Ok(examDto);
        }

        [HttpPost("api/services/app/StudentExam/SubmitExam")]
        [HttpPost("api/student/exams/submit")]
        public async Task<IActionResult> SubmitExam([FromBody] SubmitExamInputDto input)
        {
            if (input == null)
            {
                return BadRequest(new { error = "Dữ liệu nộp bài không hợp lệ." });
            }

            var exam = await _dbContext.Exams
                .Include(e => e.Questions)
                    .ThenInclude(q => q.Options)
                .FirstOrDefaultAsync(e => e.Id == input.ExamId);

            if (exam == null)
            {
                return NotFound(new { error = "Không tìm thấy đề thi." });
            }

            var studentAnswersMap = input.Answers
                .Where(a => a.SelectedOptionId.HasValue && a.SelectedOptionId.Value > 0)
                .ToDictionary(a => a.QuestionId, a => a.SelectedOptionId!.Value);

            int totalQuestions = exam.Questions.Count;
            int answeredCount = studentAnswersMap.Count;

            // SPECIAL RULE: Must have answered at least 1-2 questions unless automatic timeout
            if (answeredCount == 0 && input.TimeSpentSeconds < (exam.DurationMinutes * 60 - 5))
            {
                return BadRequest(new { error = "Bạn vui lòng làm tối thiểu 1-2 câu trước khi nộp bài." });
            }

            int correctCount = 0;
            int wrongCount = 0;

            var questionsReview = new List<QuestionResultReviewDto>();
            var attemptAnswersToSave = new List<ExamAttemptAnswer>();

            foreach (var q in exam.Questions.OrderBy(q => q.QuestionNumber))
            {
                var correctOption = q.Options.FirstOrDefault(o => o.IsCorrect);
                int correctOptId = correctOption?.Id ?? 0;
                string correctOptLabel = correctOption?.OptionLabel ?? "A";

                int? selectedOptId = null;
                bool isCorrect = false;

                if (studentAnswersMap.TryGetValue(q.Id, out int chosenId))
                {
                    selectedOptId = chosenId;
                    if (chosenId == correctOptId)
                    {
                        correctCount++;
                        isCorrect = true;
                    }
                    else
                    {
                        wrongCount++;
                        isCorrect = false;
                    }
                }

                attemptAnswersToSave.Add(new ExamAttemptAnswer
                {
                    QuestionId = q.Id,
                    SelectedOptionId = selectedOptId,
                    IsCorrect = isCorrect
                });

                questionsReview.Add(new QuestionResultReviewDto
                {
                    QuestionId = q.Id,
                    QuestionNumber = q.QuestionNumber,
                    QuestionText = q.QuestionText,
                    SelectedOptionId = selectedOptId,
                    CorrectOptionId = correctOptId,
                    CorrectOptionLabel = correctOptLabel,
                    IsCorrect = isCorrect,
                    Hint = q.Hint,
                    Options = q.Options.OrderBy(o => o.OptionLabel).Select(o => new OptionDetailDto
                    {
                        Id = o.Id,
                        OptionLabel = o.OptionLabel,
                        OptionText = o.OptionText
                    }).ToList()
                });
            }

            int skippedCount = totalQuestions - answeredCount;
            // TOEIC Reading 495-point scale or percentage:
            double score = Math.Round((double)correctCount / Math.Max(totalQuestions, 1) * 495, 0);

            var attempt = new ExamAttempt
            {
                ExamId = exam.Id,
                DeviceId = input.DeviceId ?? "anonymous",
                StartTime = DateTime.UtcNow.AddSeconds(-input.TimeSpentSeconds),
                SubmitTime = DateTime.UtcNow,
                TimeSpentSeconds = input.TimeSpentSeconds,
                AnsweredCount = answeredCount,
                CorrectCount = correctCount,
                WrongCount = wrongCount,
                SkippedCount = skippedCount,
                Score = score
            };

            _dbContext.ExamAttempts.Add(attempt);
            await _dbContext.SaveChangesAsync();

            foreach (var a in attemptAnswersToSave)
            {
                a.ExamAttemptId = attempt.Id;
                _dbContext.ExamAttemptAnswers.Add(a);
            }
            await _dbContext.SaveChangesAsync();

            var result = new SubmitExamResultDto
            {
                AttemptId = attempt.Id,
                ExamId = exam.Id,
                ExamTitle = exam.Title,
                TimeSpentSeconds = input.TimeSpentSeconds,
                TotalQuestions = totalQuestions,
                AnsweredCount = answeredCount,
                CorrectCount = correctCount,
                WrongCount = wrongCount,
                SkippedCount = skippedCount,
                Score = score,
                QuestionsReview = questionsReview
            };

            return Ok(result);
        }

        [HttpGet("api/student/exams/attempts/{attemptId}")]
        public async Task<IActionResult> GetAttemptResult(int attemptId)
        {
            var attempt = await _dbContext.ExamAttempts
                .Include(a => a.Exam)
                .Include(a => a.Answers)
                    .ThenInclude(ans => ans.Question)
                        .ThenInclude(q => q!.Options)
                .FirstOrDefaultAsync(a => a.Id == attemptId);

            if (attempt == null)
            {
                return NotFound(new { error = "Không tìm thấy kết quả ca thi." });
            }

            var questionsReview = attempt.Answers
                .OrderBy(a => a.Question?.QuestionNumber ?? 0)
                .Select(a =>
                {
                    var q = a.Question!;
                    var correctOpt = q.Options.FirstOrDefault(o => o.IsCorrect);
                    return new QuestionResultReviewDto
                    {
                        QuestionId = q.Id,
                        QuestionNumber = q.QuestionNumber,
                        QuestionText = q.QuestionText,
                        SelectedOptionId = a.SelectedOptionId,
                        CorrectOptionId = correctOpt?.Id ?? 0,
                        CorrectOptionLabel = correctOpt?.OptionLabel ?? "A",
                        IsCorrect = a.IsCorrect,
                        Hint = q.Hint,
                        Options = q.Options.OrderBy(o => o.OptionLabel).Select(o => new OptionDetailDto
                        {
                            Id = o.Id,
                            OptionLabel = o.OptionLabel,
                            OptionText = o.OptionText
                        }).ToList()
                    };
                }).ToList();

            var result = new SubmitExamResultDto
            {
                AttemptId = attempt.Id,
                ExamId = attempt.ExamId,
                ExamTitle = attempt.Exam?.Title ?? string.Empty,
                TimeSpentSeconds = attempt.TimeSpentSeconds,
                TotalQuestions = attempt.Exam?.TotalQuestions ?? 100,
                AnsweredCount = attempt.AnsweredCount,
                CorrectCount = attempt.CorrectCount,
                WrongCount = attempt.WrongCount,
                SkippedCount = attempt.SkippedCount,
                Score = attempt.Score,
                QuestionsReview = questionsReview
            };

            return Ok(result);
        }
    }
}
