import 'package:flutter/material.dart';
import '../../data/models/exam/exam_models.dart';
import '../../data/repositories/exam_repository.dart';
import 'exam_review_screen.dart';

class ExamHistoryScreen extends StatefulWidget {
  final String token;

  const ExamHistoryScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ExamHistoryScreen> createState() => _ExamHistoryScreenState();
}

class _ExamHistoryScreenState extends State<ExamHistoryScreen> {
  final ExamRepository _examRepo = ExamRepository();
  
  bool _isLoading = true;
  String? _error;
  List<ExamResult> _exams = [];

  @override
  void initState() {
    super.initState();
    _loadExamHistory();
  }

  Future<void> _loadExamHistory() async {
    try {
      final exams = await _examRepo.getExamHistory(widget.token);
      setState(() {
        _exams = exams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل سجل الاختبارات: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل الاختبارات', textDirection: TextDirection.rtl),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textDirection: TextDirection.rtl),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadExamHistory,
                        child: const Text('إعادة المحاولة', textDirection: TextDirection.rtl),
                      ),
                    ],
                  ),
                )
              : _exams.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'لم تقم بأي اختبار بعد',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadExamHistory,
                      child: Column(
                        children: [
                          // Statistics summary
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.blue[50],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryItem(
                                  'محاولات',
                                  _exams.length.toString(),
                                  Icons.assignment,
                                ),
                                _buildSummaryItem(
                                  'نجحت',
                                  _exams.where((e) => e.passed).length.toString(),
                                  Icons.check_circle,
                                ),
                                _buildSummaryItem(
                                  'راسب',
                                  _exams.where((e) => !e.passed).length.toString(),
                                  Icons.cancel,
                                ),
                                _buildSummaryItem(
                                  'أفضل نتيجة',
                                  _exams.isEmpty
                                      ? '0%'
                                      : '${_exams.map((e) => e.score).reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}%',
                                  Icons.star,
                                ),
                              ],
                            ),
                          ),
                          
                          // Exam list
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _exams.length,
                              itemBuilder: (context, index) {
                                final exam = _exams[index];
                                return _buildExamCard(exam);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }

  Widget _buildExamCard(ExamResult exam) {
    final dateTime = exam.completedAt ?? exam.startedAt;
    final dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: exam.passed ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExamReviewScreen(
                token: widget.token,
                examId: exam.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: exam.passed ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          exam.passed ? Icons.check_circle : Icons.cancel,
                          color: exam.passed ? Colors.green : Colors.red,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exam.passed ? 'نجحت' : 'راسب',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: exam.passed ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                          Text(
                            exam.getGrade(),
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${exam.score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: exam.passed ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoChip(
                    Icons.check,
                    'صحيح: ${exam.correctAnswers}',
                    Colors.green,
                  ),
                  _buildInfoChip(
                    Icons.close,
                    'خطأ: ${exam.wrongAnswers}',
                    Colors.red,
                  ),
                  _buildInfoChip(
                    Icons.timer,
                    exam.getFormattedTime(),
                    Colors.blue,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Text(
                        'مراجعة الإجابات',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 16, color: Colors.blue),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
