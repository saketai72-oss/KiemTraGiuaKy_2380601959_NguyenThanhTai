import 'package:flutter/material.dart';
import 'screens/exam_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ToeicReadingApp());
}

class ToeicReadingApp extends StatelessWidget {
  const ToeicReadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TOEIC Reading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          primary: Colors.blueAccent,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const ExamListScreen(),
    );
  }
}
