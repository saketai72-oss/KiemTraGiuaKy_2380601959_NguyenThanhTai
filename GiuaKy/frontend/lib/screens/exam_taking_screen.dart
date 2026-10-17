import 'dart:async';
import 'package:flutter/material.dart';
import '../models/exam_models.dart';
import '../services/exam_service.dart';
import 'exam_result_screen.dart';

class ExamTakingScreen extends StatefulWidget {
  final int examId;

  const ExamTakingScreen({super.key, required this.examId});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  final ExamService _examService = ExamService();
  bool _isLoading = true;
  String? _errorMessage;
  ExamForTakeModel? _exam;

  // Selected answers: questionId -> selectedOptionId
  final Map<int, int?> _answers = {};

  // Flattened questions for palette navigation
  final List<QuestionModel> _allQuestions = [];
  final Map<int, int> _questionToGroupIndex = {};

  int _selectedGroupIndex = 0;

  // Timer
  Timer? _timer;
  int _remainingSeconds = 75 * 60;
  int _timeSpentSeconds = 0;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _loadExamData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadExamData() async {
    try {
      final exam = await _examService.fetchExamForTake(widget.examId);
      _exam = exam;
      _remainingSeconds = exam.durationMinutes * 60;

      _allQuestions.clear();
      _questionToGroupIndex.clear();

      for (int gIdx = 0; gIdx < exam.groups.length; gIdx++) {
        final g = exam.groups[gIdx];
        for (var q in g.questions) {
          _allQuestions.add(q);
          _questionToGroupIndex[q.id] = gIdx;
        }
      }

      setState(() {
        _isLoading = false;
      });

      _startTimer();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _timeSpentSeconds++;
        });

        // 5-minute warning notification
        if (_remainingSeconds == 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CẢNH BÁO: Còn 5 phút cuối cùng! Hãy kiểm tra lại bài làm.'),
              backgroundColor: Colors.deepOrange,
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        _timer?.cancel();
        _autoSubmitOnTimeout();
      }
    });
  }

  void _autoSubmitOnTimeout() {
    if (_isSubmitted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã hết giờ làm bài! Hệ thống tự động thu bài và chấm điểm.'),
        backgroundColor: Colors.red,
      ),
    );
    _executeSubmit();
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Answer selection & deselection logic
  void _onOptionSelected(int questionId, int optionId) {
    if (_isSubmitted) return;
    setState(() {
      if (_answers[questionId] == optionId) {
        // Tap again on selected option -> deselect / clear selection
        _answers.remove(questionId);
      } else {
        _answers[questionId] = optionId;
      }
    });
  }

  int get _answeredCount => _answers.values.where((v) => v != null).length;
  int get _totalQuestions => _allQuestions.isNotEmpty ? _allQuestions.length : (_exam?.totalQuestions ?? 100);

  // Early Submission Validation & Dialog
  void _promptSubmit() {
    final answered = _answeredCount;
    final total = _totalQuestions;
    final unanswered = total - answered;

    if (answered == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn vui lòng làm tối thiểu 1-2 câu trước khi nộp bài.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.assignment_turned_in, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('Xác nhận Nộp bài'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.4),
            children: [
              const TextSpan(text: 'Bạn đã hoàn thành '),
              TextSpan(
                text: '$answered/$total',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              const TextSpan(text: ' câu (còn '),
              TextSpan(
                text: '$unanswered',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
              ),
              const TextSpan(
                text: ' câu chưa làm).\n\nBạn có chắc chắn muốn nộp bài và chấm điểm ngay bây giờ không?',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tiếp tục làm'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _executeSubmit();
            },
            child: const Text('Xác nhận nộp'),
          ),
        ],
      ),
    );
  }

  Future<void> _executeSubmit() async {
    _timer?.cancel();
    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });

    try {
      final result = await _examService.submitExam(
        examId: widget.examId,
        timeSpentSeconds: _timeSpentSeconds,
        answersMap: _answers,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExamResultScreen(result: result),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSubmitted = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi nộp bài: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Question Palette Bottom Sheet
  void _openQuestionPalette() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 380,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bảng Câu hỏi (Question Palette)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Đã làm: $_answeredCount/$_totalQuestions',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(Icons.circle, color: Colors.green, size: 12),
                  SizedBox(width: 4),
                  Text('Đã chọn', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 16),
                  Icon(Icons.circle, color: Colors.grey, size: 12),
                  SizedBox(width: 4),
                  Text('Chưa làm', style: TextStyle(fontSize: 12)),
                ],
              ),
              const Divider(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: _allQuestions.length,
                  itemBuilder: (context, index) {
                    final q = _allQuestions[index];
                    final isAnswered = _answers.containsKey(q.id) && _answers[q.id] != null;
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        final targetGroup = _questionToGroupIndex[q.id] ?? 0;
                        setState(() {
                          _selectedGroupIndex = targetGroup;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isAnswered ? Colors.green.shade600 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${q.questionNumber}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isAnswered ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đang tải bài thi...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final exam = _exam!;
    final isWarningTime = _remainingSeconds < 300;
    final currentGroup = exam.groups[_selectedGroupIndex];
    final isPart5 = currentGroup.partNumber == 5;

    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Thoát bài thi?'),
            content: const Text('Bài thi đang diễn ra. Nếu thoát, kết quả của bạn sẽ không được lưu.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Ở lại')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Thoát ra')),
            ],
          ),
        );
        return shouldLeave ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: Text(
            exam.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            // Real-time Timer Badge
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isWarningTime ? Colors.red.shade100 : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isWarningTime ? Colors.red : Colors.blueAccent,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isWarningTime ? Icons.warning_amber_rounded : Icons.timer_outlined,
                    size: 16,
                    color: isWarningTime ? Colors.red : Colors.blueAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isWarningTime ? Colors.red.shade800 : Colors.blueAccent.shade700,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.grid_view_rounded, color: Colors.blueAccent),
              onPressed: _openQuestionPalette,
              tooltip: 'Bảng câu hỏi',
            ),
          ],
        ),
        body: Column(
          children: [
            // Part Selector Chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(exam.groups.length, (gIdx) {
                    final g = exam.groups[gIdx];
                    final isSelected = gIdx == _selectedGroupIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          g.partNumber == 5
                              ? 'Part 5'
                              : 'Part ${g.partNumber} (${g.questions.first.questionNumber}-${g.questions.last.questionNumber})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Colors.blueAccent,
                        backgroundColor: Colors.grey.shade100,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedGroupIndex = gIdx;
                            });
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Content Area: Part 5 vs Part 6/7 Split View
            Expanded(
              child: isPart5
                  ? _buildPart5Layout(currentGroup)
                  : _buildSplitReadingLayout(currentGroup),
            ),

            // Bottom Submission Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.grid_on_rounded, size: 18),
                      label: Text('Bảng câu ($_answeredCount/$_totalQuestions)'),
                      onPressed: _openQuestionPalette,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _answeredCount >= 1 ? Colors.green.shade600 : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: _answeredCount >= 1 ? 2 : 0,
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        'Nộp bài ($_answeredCount/$_totalQuestions)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _promptSubmit,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Part 5 Layout: Scrollable list of independent questions
  Widget _buildPart5Layout(QuestionGroupModel group) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: group.questions.length,
      itemBuilder: (context, index) {
        final q = group.questions[index];
        return _buildQuestionCard(q);
      },
    );
  }

  // Part 6 & 7 Split Layout: Top Passage viewer + Bottom dependent questions
  Widget _buildSplitReadingLayout(QuestionGroupModel group) {
    return Column(
      children: [
        // Top: Passage Viewer (scrollable)
        Container(
          height: 220,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.shade50.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (group.directionText != null) ...[
                Text(
                  group.directionText!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                const Divider(height: 12),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    group.passageContentHtml ?? '',
                    style: const TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFF1E293B)),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bottom: Dependent Questions
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: group.questions.length,
            itemBuilder: (context, index) {
              final q = group.questions[index];
              return _buildQuestionCard(q);
            },
          ),
        ),
      ],
    );
  }

  // Question Card with A, B, C, D Option buttons
  Widget _buildQuestionCard(QuestionModel q) {
    final selectedOptionId = _answers[q.id];

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: selectedOptionId != null ? Colors.blue.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Câu ${q.questionNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: selectedOptionId != null ? Colors.blue.shade800 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    q.questionText,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, height: 1.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...q.options.map((opt) {
              final isChosen = selectedOptionId == opt.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _onOptionSelected(q.id, opt.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isChosen ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isChosen ? Colors.blueAccent : Colors.grey.shade300,
                        width: isChosen ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isChosen ? Colors.blueAccent : Colors.grey.shade100,
                          ),
                          child: Text(
                            opt.optionLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isChosen ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            opt.optionText,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: isChosen ? FontWeight.w600 : FontWeight.normal,
                              color: isChosen ? Colors.blue.shade900 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
