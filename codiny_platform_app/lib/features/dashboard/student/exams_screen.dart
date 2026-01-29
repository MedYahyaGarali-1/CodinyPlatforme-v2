import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/access_guard.dart';
import '../../../shared/ui/staggered_animation.dart';
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

class _ExamsScreenState extends State<ExamsScreen>
    with TickerProviderStateMixin, StaggeredAnimationMixin {
  final ExamRepository _examRepo = ExamRepository();
  bool _isLoadingHistory = true;
  List<ExamResult> _recentExams = [];

  @override
  void initState() {
    super.initState();
    initAnimations(sectionCount: 6);
    _loadRecentExams();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
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
      // Start animations after data loads
      startAnimations();
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
      // Still start animations on error
      startAnimations();
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

  // Calculate pass rate from recent exams
  double get _passRate {
    if (_recentExams.isEmpty) return 0;
    final passed = _recentExams.where((e) => e.passed).length;
    return (passed / _recentExams.length) * 100;
  }

  // Get friendly time ago string
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks أسبوع';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Check if scores are improving
  bool get _isImproving {
    if (_recentExams.length < 2) return true;
    return _recentExams.first.score >= _recentExams[1].score;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AccessGuard(
      requiresFullAccess: true,
      featureName: 'exams',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f0f1a),
                  ]
                : [
                    Colors.blue.shade50.withOpacity(0.5),
                    Colors.purple.shade50.withOpacity(0.3),
                    Theme.of(context).colorScheme.surface,
                  ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🎯 Enhanced Header Card
              buildAnimatedSection(0, _buildHeaderCard(isDark)),
              
              const SizedBox(height: 24),
              
              // 📋 Enhanced Instructions Card
              buildAnimatedSection(1, _buildInstructionsCard(isDark)),
              
              const SizedBox(height: 24),
              
              // 📊 Recent Attempts Header with Stats
              buildAnimatedSection(2, _buildRecentAttemptsHeader(isDark)),
              
              const SizedBox(height: 16),
              
              // 📈 Exam Cards or Empty State
              buildAnimatedSection(3, _isLoadingHistory
                  ? _buildLoadingState()
                  : _recentExams.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildExamsList(isDark)),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Driving icon with glow effect
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.drive_eta_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'اختبار رخصة السياقة',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Info chips
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.help_outline, '30 سؤال'),
                    _buildInfoChip(Icons.timer_outlined, '45 دقيقة'),
                    _buildInfoChip(Icons.emoji_events_outlined, '23/30 للنجاح'),
                  ],
                ),
                const SizedBox(height: 24),
                // Start button with animation
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _startNewExam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 28),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsCard(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'تعليمات الاختبار',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1D1E33),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Grouped instructions
            _buildInstructionGroup(
              'حول الاختبار',
              [
                _InstructionItem(Icons.shuffle, '30 سؤال عشوائي', Colors.purple),
                _InstructionItem(Icons.timer, '45 دقيقة', Colors.orange),
              ],
              isDark,
            ),
            const SizedBox(height: 16),
            _buildInstructionGroup(
              'معايير النجاح',
              [
                _InstructionItem(Icons.check_circle, '23 إجابة صحيحة (76.67%)', Colors.green),
              ],
              isDark,
            ),
            const SizedBox(height: 16),
            _buildInstructionGroup(
              'ميزات مساعدة',
              [
                _InstructionItem(Icons.bookmark, 'علّم الأسئلة للمراجعة', Colors.amber),
                _InstructionItem(Icons.visibility, 'راجع الإجابات بعد الانتهاء', Colors.teal),
              ],
              isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionGroup(String title, List<_InstructionItem> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  item.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildRecentAttemptsHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: _viewHistory,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            Icons.history,
            size: 18,
            color: isDark ? Colors.blue[300] : Colors.blue[700],
          ),
          label: Text(
            'عرض الكل',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: isDark ? Colors.blue[300] : Colors.blue[700],
            ),
          ),
        ),
        Row(
          children: [
            if (_recentExams.isNotEmpty) ...[
              // Pass rate indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _passRate >= 50 
                      ? Colors.green.withOpacity(0.15) 
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_passRate.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _passRate >= 50 ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isImproving ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: _passRate >= 50 ? Colors.green : Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text(
              'آخر المحاولات',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1D1E33),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Illustration
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade100.withOpacity(0.5),
                  Colors.purple.shade100.withOpacity(0.5),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.drive_eta_outlined,
              size: 64,
              color: isDark ? Colors.blue[300] : Colors.blue[600],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لم تقم بأي اختبار بعد',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1D1E33),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ابدأ اختبارك الأول الآن!\nكل محاولة تقربك من النجاح 🎯',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white60 : Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Quick start button
          OutlinedButton.icon(
            onPressed: _startNewExam,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(
                color: isDark ? Colors.blue[300]! : Colors.blue[600]!,
                width: 2,
              ),
            ),
            icon: Icon(
              Icons.rocket_launch,
              color: isDark ? Colors.blue[300] : Colors.blue[600],
            ),
            label: Text(
              'ابدأ الآن',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.blue[300] : Colors.blue[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamsList(bool isDark) {
    return Column(
      children: _recentExams.map((exam) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildRecentExamCard(exam, isDark),
        );
      }).toList(),
    );
  }

  Widget _buildRecentExamCard(ExamResult exam, bool isDark) {
    final dateTime = exam.completedAt ?? exam.startedAt;
    final timeAgo = _getTimeAgo(dateTime);
    final scorePercent = exam.score / 100;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: exam.passed 
              ? Colors.green.withOpacity(0.3) 
              : Colors.red.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (exam.passed ? Colors.green : Colors.red).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Score ring on the left
            SizedBox(
              width: 70,
              height: 70,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: scorePercent,
                      strokeWidth: 6,
                      backgroundColor: (exam.passed ? Colors.green : Colors.red).withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(
                        exam.passed ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${exam.score.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: exam.passed ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Details on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        timeAgo,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.grey[400],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: exam.passed 
                                ? [Colors.green.shade400, Colors.green.shade600]
                                : [Colors.red.shade400, Colors.red.shade600],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          exam.passed ? 'ناجح ✓' : 'راسب ✗',
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildStatChip(
                        Icons.timer_outlined,
                        exam.getFormattedTime(),
                        Colors.blue,
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.cancel_outlined,
                        '${exam.wrongAnswers}',
                        Colors.red,
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        Icons.check_circle_outline,
                        '${exam.correctAnswers}',
                        Colors.green,
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionItem {
  final IconData icon;
  final String text;
  final Color color;

  _InstructionItem(this.icon, this.text, this.color);
}
