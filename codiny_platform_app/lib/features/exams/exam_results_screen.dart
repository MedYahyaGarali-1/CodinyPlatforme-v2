import 'package:flutter/material.dart';
import '../../shared/ui/staggered_animation.dart';
import 'exam_review_screen.dart';

class ExamResultsScreen extends StatelessWidget {
  final String token;
  final Map<String, dynamic> result;
  final String examId;

  const ExamResultsScreen({
    Key? key,
    required this.token,
    required this.result,
    required this.examId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final correctAnswers = result['correct_answers'] as int;
    final wrongAnswers = result['wrong_answers'] as int;
    final score = double.parse(result['score'].toString());
    final passed = result['passed'] as bool;
    final passingScore = result['passing_score'] as int;
    final timeTaken = result['time_taken_seconds'] as int;

    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    final timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';

    String grade;
    if (score >= 90) {
      grade = 'ممتاز';
    } else if (score >= 80) {
      grade = 'جيد جداً';
    } else if (score >= 76.67) {
      grade = 'جيد';
    } else {
      grade = 'راسب';
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نتيجة الاختبار', textDirection: TextDirection.rtl),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pass/Fail status
              StaggeredAnimationWrapper(
                index: 0,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: passed ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: passed ? Colors.green : Colors.red,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        passed ? Icons.check_circle : Icons.cancel,
                        size: 80,
                        color: passed ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        passed ? 'نجحت!' : 'لم تنجح',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: passed ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        grade,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: passed ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Score card
              StaggeredAnimationWrapper(
                index: 1,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'النتيجة',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              score.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text(
                              '%',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Statistics
              StaggeredAnimationWrapper(
                index: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'إجابات صحيحة',
                        correctAnswers.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'إجابات خاطئة',
                        wrongAnswers.toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              StaggeredAnimationWrapper(
                index: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'علامة النجاح',
                        '$passingScore/30',
                        Icons.flag,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'الوقت المستغرق',
                        timeString,
                        Icons.timer,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Review answers button
              StaggeredAnimationWrapper(
                index: 4,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamReviewScreen(
                          token: token,
                          examId: examId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text(
                    'مراجعة الإجابات',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.blue,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Back to dashboard button
              StaggeredAnimationWrapper(
                index: 5,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text(
                    'العودة إلى لوحة التحكم',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Motivational message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  passed
                      ? '🎉 تهانينا! لقد نجحت في الاختبار. استمر في التدريب للحفاظ على مستواك.'
                      : '💪 لا تستسلم! راجع الأسئلة وحاول مرة أخرى. يمكنك النجاح!',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
