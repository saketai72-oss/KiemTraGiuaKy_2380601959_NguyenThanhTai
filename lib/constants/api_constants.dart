import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use localhost for Web, Windows, macOS, iOS; 10.0.2.2 for Android emulator
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }

  static String get publishedExamsUrl =>
      '$baseUrl/api/services/app/StudentExam/GetPublishedExams';

  static String examForTakeUrl(int examId) =>
      '$baseUrl/api/services/app/StudentExam/GetExamForTake?examId=$examId';

  static String get submitExamUrl =>
      '$baseUrl/api/services/app/StudentExam/SubmitExam';
}
