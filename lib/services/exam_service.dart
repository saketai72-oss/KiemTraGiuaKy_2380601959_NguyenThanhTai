import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/exam_models.dart';

class ExamService {
  Future<List<ExamSummary>> fetchPublishedExams() async {
    final response = await http.get(Uri.parse(ApiConstants.publishedExamsUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> list = data['result'] ?? [];
      return list.map((item) => ExamSummary.fromJson(item)).toList();
    } else {
      throw Exception('Lỗi khi tải danh sách đề thi (${response.statusCode})');
    }
  }

  Future<ExamForTakeModel> fetchExamForTake(int examId) async {
    final response =
        await http.get(Uri.parse(ApiConstants.examForTakeUrl(examId)));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ExamForTakeModel.fromJson(data['result']);
    } else {
      throw Exception('Lỗi khi tải chi tiết đề thi (${response.statusCode})');
    }
  }

  Future<SubmitExamResultModel> submitExam({
    required int examId,
    required int timeSpentSeconds,
    required Map<int, int?> answersMap,
    String? deviceId,
  }) async {
    final answersList = answersMap.entries
        .where((e) => e.value != null)
        .map((e) => {
              'questionId': e.key,
              'selectedOptionId': e.value,
            })
        .toList();

    final payload = {
      'examId': examId,
      'timeSpentSeconds': timeSpentSeconds,
      'deviceId': deviceId ?? 'flutter_mobile_user',
      'answers': answersList,
    };

    final response = await http.post(
      Uri.parse(ApiConstants.submitExamUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SubmitExamResultModel.fromJson(data['result']);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['error'] ?? 'Lỗi khi nộp bài thi');
    }
  }
}
