import 'package:flutter/material.dart';
import '../models/exam_models.dart';
import '../services/exam_service.dart';
import 'exam_taking_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final ExamService _examService = ExamService();
  late Future<List<ExamSummary>> _examsFuture;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  void _loadExams() {
    setState(() {
      _examsFuture = _examService.fetchPublishedExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: const Row(
          children: [
            Icon(Icons.menu_book_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Luyện Thi TOEIC Reading',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadExams,
            tooltip: 'Làm mới',
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadExams(),
        child: FutureBuilder<List<ExamSummary>>(
          future: _examsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 64, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text(
                        'Không thể kết nối đến máy chủ\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadExams,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final exams = snapshot.data ?? [];

            if (exams.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 72, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'Hiện chưa có ca thi nào được mở.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Giảng viên cần xuất bản đề thi trên Cổng Web để hiển thị ở đây.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.black45),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.blue.shade50.withOpacity(0.3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.description,
                                  color: Colors.blueAccent, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exam.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'TOEIC Reading (Part 5, 6, 7)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Chip(
                              avatar: const Icon(Icons.timer_outlined, size: 16),
                              label: Text('${exam.durationMinutes} phút'),
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: const TextStyle(fontSize: 12),
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              avatar: const Icon(Icons.format_list_numbered, size: 16),
                              label: Text('${exam.totalQuestions} câu hỏi'),
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: const TextStyle(fontSize: 12),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 1,
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 22),
                            label: const Text(
                              'Bắt đầu thi ngay',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExamTakingScreen(examId: exam.id),
                                ),
                              ).then((_) => _loadExams());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
