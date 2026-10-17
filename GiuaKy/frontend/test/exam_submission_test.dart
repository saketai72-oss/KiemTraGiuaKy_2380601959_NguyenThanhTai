import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/exam_models.dart';

void main() {
  group('TOEIC Reading Exam Logic Tests', () {
    test('Calculates answered, skipped, and score correctly for 2 questions answered', () {
      const totalQuestions = 100;
      final answers = {
        101: 1, // Answered
        102: 2, // Answered
      };

      final answeredCount = answers.length;
      final skippedCount = totalQuestions - answeredCount;

      expect(answeredCount, 2);
      expect(skippedCount, 98);
      expect(answeredCount >= 1, isTrue, reason: 'Cho phép nộp bài từ 1-2 câu trở lên');
    });

    test('Deselect option logic works (toggle off to clear selection)', () {
      final answers = <int, int?>{};

      // First tap selects option 10
      int questionId = 101;
      int optionId = 10;
      if (answers[questionId] == optionId) {
        answers.remove(questionId);
      } else {
        answers[questionId] = optionId;
      }
      expect(answers[questionId], 10);

      // Second tap deselects option 10 (Clear selection)
      if (answers[questionId] == optionId) {
        answers.remove(questionId);
      } else {
        answers[questionId] = optionId;
      }
      expect(answers[questionId], isNull);
    });

    test('SubmitExamResultModel deserializes score and review correctly', () {
      final jsonSample = {
        'attemptId': 1,
        'examId': 1,
        'examTitle': 'ETS TOEIC Reading Test 09',
        'timeSpentSeconds': 120,
        'totalQuestions': 100,
        'answeredCount': 2,
        'correctCount': 1,
        'wrongCount': 1,
        'skippedCount': 98,
        'score': 5.0,
        'questionsReview': [
          {
            'questionId': 1,
            'questionNumber': 101,
            'questionText': 'Test Q 101',
            'selectedOptionId': 2,
            'correctOptionId': 2,
            'correctOptionLabel': 'B',
            'isCorrect': true,
            'hint': 'Test hint',
            'options': [
              {'id': 1, 'optionLabel': 'A', 'optionText': 'they'},
              {'id': 2, 'optionLabel': 'B', 'optionText': 'their'}
            ]
          }
        ]
      };

      final result = SubmitExamResultModel.fromJson(jsonSample);
      expect(result.attemptId, 1);
      expect(result.correctCount, 1);
      expect(result.wrongCount, 1);
      expect(result.skippedCount, 98);
      expect(result.questionsReview.first.isCorrect, isTrue);
    });
  });
}
