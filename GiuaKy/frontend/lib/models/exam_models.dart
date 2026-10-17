class ExamSummary {
  final int id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final DateTime? creationTime;

  ExamSummary({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    this.creationTime,
  });

  factory ExamSummary.fromJson(Map<String, dynamic> json) {
    return ExamSummary(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Đề thi TOEIC',
      durationMinutes: json['durationMinutes'] as int? ?? 75,
      totalQuestions: json['totalQuestions'] as int? ?? 100,
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime'])
          : null,
    );
  }
}

class OptionModel {
  final int id;
  final String optionLabel;
  final String optionText;

  OptionModel({
    required this.id,
    required this.optionLabel,
    required this.optionText,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      id: json['id'] as int,
      optionLabel: json['optionLabel'] as String? ?? '',
      optionText: json['optionText'] as String? ?? '',
    );
  }
}

class QuestionModel {
  final int id;
  final int questionNumber;
  final String questionText;
  final List<OptionModel> options;

  QuestionModel({
    required this.id,
    required this.questionNumber,
    required this.questionText,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'] as List<dynamic>? ?? [];
    return QuestionModel(
      id: json['id'] as int,
      questionNumber: json['questionNumber'] as int,
      questionText: json['questionText'] as String? ?? '',
      options: rawOptions.map((o) => OptionModel.fromJson(o)).toList(),
    );
  }
}

class QuestionGroupModel {
  final int id;
  final int partNumber;
  final String? directionText;
  final String? passageContentHtml;
  final int orderIndex;
  final List<QuestionModel> questions;

  QuestionGroupModel({
    required this.id,
    required this.partNumber,
    this.directionText,
    this.passageContentHtml,
    required this.orderIndex,
    required this.questions,
  });

  factory QuestionGroupModel.fromJson(Map<String, dynamic> json) {
    var rawQuestions = json['questions'] as List<dynamic>? ?? [];
    return QuestionGroupModel(
      id: json['id'] as int,
      partNumber: json['partNumber'] as int? ?? 5,
      directionText: json['directionText'] as String?,
      passageContentHtml: json['passageContentHtml'] as String?,
      orderIndex: json['orderIndex'] as int? ?? 0,
      questions: rawQuestions.map((q) => QuestionModel.fromJson(q)).toList(),
    );
  }
}

class ExamForTakeModel {
  final int id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final List<QuestionGroupModel> groups;

  ExamForTakeModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.groups,
  });

  factory ExamForTakeModel.fromJson(Map<String, dynamic> json) {
    var rawGroups = json['groups'] as List<dynamic>? ?? [];
    return ExamForTakeModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      durationMinutes: json['durationMinutes'] as int? ?? 75,
      totalQuestions: json['totalQuestions'] as int? ?? 100,
      groups: rawGroups.map((g) => QuestionGroupModel.fromJson(g)).toList(),
    );
  }
}

class QuestionReviewModel {
  final int questionId;
  final int questionNumber;
  final String questionText;
  final int? selectedOptionId;
  final int correctOptionId;
  final String correctOptionLabel;
  final bool isCorrect;
  final String? hint;
  final List<OptionModel> options;

  QuestionReviewModel({
    required this.questionId,
    required this.questionNumber,
    required this.questionText,
    this.selectedOptionId,
    required this.correctOptionId,
    required this.correctOptionLabel,
    required this.isCorrect,
    this.hint,
    required this.options,
  });

  factory QuestionReviewModel.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'] as List<dynamic>? ?? [];
    return QuestionReviewModel(
      questionId: json['questionId'] as int,
      questionNumber: json['questionNumber'] as int,
      questionText: json['questionText'] as String? ?? '',
      selectedOptionId: json['selectedOptionId'] as int?,
      correctOptionId: json['correctOptionId'] as int,
      correctOptionLabel: json['correctOptionLabel'] as String? ?? 'A',
      isCorrect: json['isCorrect'] as bool? ?? false,
      hint: json['hint'] as String?,
      options: rawOptions.map((o) => OptionModel.fromJson(o)).toList(),
    );
  }
}

class SubmitExamResultModel {
  final int attemptId;
  final int examId;
  final String examTitle;
  final int timeSpentSeconds;
  final int totalQuestions;
  final int answeredCount;
  final int correctCount;
  final int wrongCount;
  final int skippedCount;
  final double score;
  final List<QuestionReviewModel> questionsReview;

  SubmitExamResultModel({
    required this.attemptId,
    required this.examId,
    required this.examTitle,
    required this.timeSpentSeconds,
    required this.totalQuestions,
    required this.answeredCount,
    required this.correctCount,
    required this.wrongCount,
    required this.skippedCount,
    required this.score,
    required this.questionsReview,
  });

  factory SubmitExamResultModel.fromJson(Map<String, dynamic> json) {
    var rawReviews = json['questionsReview'] as List<dynamic>? ?? [];
    return SubmitExamResultModel(
      attemptId: json['attemptId'] as int,
      examId: json['examId'] as int,
      examTitle: json['examTitle'] as String? ?? '',
      timeSpentSeconds: json['timeSpentSeconds'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 100,
      answeredCount: json['answeredCount'] as int? ?? 0,
      correctCount: json['correctCount'] as int? ?? 0,
      wrongCount: json['wrongCount'] as int? ?? 0,
      skippedCount: json['skippedCount'] as int? ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      questionsReview:
          rawReviews.map((r) => QuestionReviewModel.fromJson(r)).toList(),
    );
  }
}
