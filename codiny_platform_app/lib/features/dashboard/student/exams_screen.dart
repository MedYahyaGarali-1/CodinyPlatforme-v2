import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/access_guard.dart';
import '../../../state/session/session_controller.dart';
import '../../../data/repositories/exam_repository.dart';
import '../../../data/models/exam/exam_models.dart';
import '../../exams/exam_taking_screen.dart';
import '../../exams/exam_history_screen.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  final ExamRepository _examRepo = ExamRepository();
  bool _isLoadingHistory = true;
  List<ExamResult> _recentExams = [];

  @override
  void initState() {
    super.initState();
    _loadRecentExams();
  }

  Future<void> _loadRecentExams() async {
    try {
      final session = Provider.of<SessionController>(context, listen: false);
      final token = session.token ?? '';
      final exams = await _examRepo.getExamHistory(token);
      setState(() {
        _recentExams = exams.take(3).toList();
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  void _startNewExam() {
    final session = Provider.of<SessionController>(context, listen: false);
    final token = session.token ?? '';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamTakingScreen(token: token),
      ),
    ).then((_) {
      // Refresh exam history when returning
      _loadRecentExams();
    });
  }

  void _viewHistory() {
    final session = Provider.of<SessionController>(context, listen: false);
    final token = session.token ?? '';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamHistoryScreen(token: token),
      ),
    ).then((_) {
      // Refresh when returning
      _loadRecentExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AccessGuard(
      requiresFullAccess: true,
      featureName: 'exams',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[700]!, Colors.blue[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.quiz,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'اختبار رخصة السياقة',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '30 سؤال • 45 دقيقة • 23/30 للنجاح',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _startNewExam,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.play_arrow, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'ابدأ اختبار جديد',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'تعليمات الاختبار',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInstruction(Icons.quiz, '30 سؤال عشوائي من بنك الأسئلة'),
                    _buildInstruction(Icons.timer, 'مدة الاختبار 45 دقيقة'),
                    _buildInstruction(Icons.check_circle, 'الحد الأدنى للنجاح: 23 إجابة صحيحة من 30 (76.67%)'),
                    _buildInstruction(Icons.bookmark, 'يمكنك وضع علامة على الأسئلة للمراجعة'),
                    _buildInstruction(Icons.visibility, 'يمكنك مراجعة الإجابات بعد الانتهاء'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recent exams
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'آخر المحاولات',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _viewHistory,
                  icon: const Icon(Icons.history),
                  label: const Text(
                    'عرض الكل',
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _isLoadingHistory
                ? const Center(child: CircularProgressIndicator())
                : _recentExams.isEmpty
                    ? Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: const [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لم تقم بأي اختبار بعد',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: _recentExams
                            .map((exam) => _buildRecentExamCard(exam))
                            .toList(),
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExamCard(ExamResult exam) {
    final dateTime = exam.completedAt ?? exam.startedAt;
    final dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: exam.passed ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: exam.passed ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                exam.passed ? Icons.check_circle : Icons.cancel,
                color: exam.passed ? Colors.green : Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.passed ? 'نجحت' : 'راسب',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: exam.passed ? Colors.green[800] : Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$dateStr • ${exam.correctAnswers}/30 صحيح',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${exam.score.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: exam.passed ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

