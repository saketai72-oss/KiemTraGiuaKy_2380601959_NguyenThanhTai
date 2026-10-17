import 'package:flutter/material.dart';
import '../models/exam_models.dart';
import 'exam_taking_screen.dart';

class ExamResultScreen extends StatelessWidget {
  final SubmitExamResultModel result;

  const ExamResultScreen({super.key, required this.result});

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popUntil(context, (route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: const Text(
            'Kết Quả Bài Thi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Về trang chủ',
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      result.examTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${result.score.toInt()}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '/ 495 điểm',
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Thời gian hoàn thành: ${_formatTime(result.timeSpentSeconds)}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3 Stat Cards: Đúng, Sai, Bỏ qua
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Đúng',
                      count: result.correctCount,
                      color: Colors.green,
                      icon: Icons.check_circle_outline,
                      bgColor: Colors.green.shade50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Sai',
                      count: result.wrongCount,
                      color: Colors.redAccent,
                      icon: Icons.cancel_outlined,
                      bgColor: Colors.red.shade50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Bỏ qua',
                      count: result.skippedCount,
                      color: Colors.grey.shade700,
                      icon: Icons.help_outline_rounded,
                      bgColor: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Về trang chủ'),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Thi lại đề này'),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExamTakingScreen(examId: result.examId),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Detailed Question Review
              const Text(
                'Chi tiết đáp án & Giải thích (Review)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: result.questionsReview.length,
                itemBuilder: (context, index) {
                  final q = result.questionsReview[index];
                  final isAnswered = q.selectedOptionId != null;

                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: !isAnswered
                                      ? Colors.grey.shade200
                                      : (q.isCorrect ? Colors.green.shade100 : Colors.red.shade100),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Câu ${q.questionNumber}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: !isAnswered
                                        ? Colors.black54
                                        : (q.isCorrect ? Colors.green.shade800 : Colors.red.shade800),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                !isAnswered
                                    ? Icons.remove_circle_outline
                                    : (q.isCorrect ? Icons.check_circle : Icons.cancel),
                                size: 18,
                                color: !isAnswered
                                    ? Colors.grey
                                    : (q.isCorrect ? Colors.green : Colors.red),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                !isAnswered
                                    ? 'Chưa trả lời'
                                    : (q.isCorrect ? 'Chính xác' : 'Trả lời sai'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: !isAnswered
                                      ? Colors.grey
                                      : (q.isCorrect ? Colors.green : Colors.red),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            q.questionText,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          ...q.options.map((opt) {
                            final isUserSelected = q.selectedOptionId == opt.id;
                            final isCorrectOption = q.correctOptionId == opt.id;

                            Color itemBg = Colors.white;
                            Color borderCol = Colors.grey.shade200;
                            Color textCol = Colors.black87;

                            if (isCorrectOption) {
                              itemBg = Colors.green.shade50;
                              borderCol = Colors.green;
                              textCol = Colors.green.shade900;
                            } else if (isUserSelected && !q.isCorrect) {
                              itemBg = Colors.red.shade50;
                              borderCol = Colors.redAccent;
                              textCol = Colors.red.shade900;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: itemBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: borderCol),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '[${opt.optionLabel}]',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textCol,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      opt.optionText,
                                      style: TextStyle(fontSize: 13, color: textCol),
                                    ),
                                  ),
                                  if (isUserSelected)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Chip(
                                        label: const Text('Bạn chọn'),
                                        labelStyle: const TextStyle(fontSize: 10, color: Colors.white),
                                        backgroundColor: q.isCorrect ? Colors.green : Colors.redAccent,
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  if (isCorrectOption && !isUserSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: Icon(Icons.check, color: Colors.green, size: 18),
                                    ),
                                ],
                              ),
                            );
                          }),
                          if (q.hint != null && q.hint!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Giải thích: ${q.hint}',
                                      style: TextStyle(fontSize: 12.5, color: Colors.amber.shade900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
