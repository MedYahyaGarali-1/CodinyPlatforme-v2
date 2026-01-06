import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/school_repository.dart';
import '../../../data/models/exam/exam_models.dart';
import '../../../data/models/school/school_student.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/layout/base_scaffold.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';

class ExamAnswersDetailScreen extends StatefulWidget {
  final SchoolStudent student;
  final ExamResult exam;

  const ExamAnswersDetailScreen({
    super.key,
    required this.student,
    required this.exam,
  });

  @override
  State<ExamAnswersDetailScreen> createState() => _ExamAnswersDetailScreenState();
}

class _ExamAnswersDetailScreenState extends State<ExamAnswersDetailScreen> {
  final _repo = SchoolRepository();
  late Future<List<ExamDetailedAnswer>> _answersFuture;

  @override
  void initState() {
    super.initState();
    _answersFuture = _loadAnswers();
  }

  Future<List<ExamDetailedAnswer>> _loadAnswers() async {
    final token = context.read<SessionController>().token;
    if (token == null) throw Exception('Not authenticated');
    
    return await _repo.getExamAnswers(
      token: token,
      studentId: widget.student.id.toString(),
      examId: widget.exam.id,
    );
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _answersFuture = _loadAnswers();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BaseScaffold(
      title: 'Exam Answers',
      body: FutureBuilder<List<ExamDetailedAnswer>>(
        future: _answersFuture,
        builder: (context, snap) {
          // Loading State
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 10,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, __) => ShimmerLoading(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );
          }

          // Error State
          if (snap.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Failed to Load',
              message: snap.error.toString(),
              actionLabel: 'Retry',
              onAction: _refresh,
            );
          }

          final answers = snap.data ?? const <ExamDetailedAnswer>[];

          if (answers.isEmpty) {
            return EmptyState(
              icon: Icons.history_edu_outlined,
              title: 'No Detailed Answers Available',
              message: 'This exam was taken before the detailed answer tracking feature was added.\n\nOnly new exams will have question-by-question details.\n\nThe student can take a new exam to see this feature in action!',
              actionLabel: 'Go Back',
              onAction: () => Navigator.of(context).pop(),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                // Header with exam summary
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.student.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Exam Results',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniStat(
                              'Score',
                              '${widget.exam.score.toStringAsFixed(1)}%',
                              Icons.percent,
                              Colors.white,
                            ),
                            _buildMiniStat(
                              'Correct',
                              '${widget.exam.correctAnswers}',
                              Icons.check_circle,
                              Colors.green.shade300,
                            ),
                            _buildMiniStat(
                              'Wrong',
                              '${widget.exam.wrongAnswers}',
                              Icons.cancel,
                              Colors.red.shade300,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter buttons
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'All (${answers.length})',
                          true,
                          colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Wrong (${answers.where((a) => !a.isCorrect).length})',
                          false,
                          Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),

                // Answers list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final answer = answers[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: index == answers.length - 1 ? 16 : 8,
                        ),
                        child: _buildAnswerCard(answer, colorScheme),
                      );
                    },
                    childCount: answers.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildAnswerCard(ExamDetailedAnswer answer, ColorScheme colorScheme) {
    final isCorrect = answer.isCorrect;
    final borderColor = isCorrect ? Colors.green : Colors.red;
    final bgColor = isCorrect ? Colors.green.shade50 : Colors.red.shade50;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with question number and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: borderColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${answer.questionNumber}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isCorrect ? 'Correct Answer ✓' : 'Wrong Answer ✗',
                    style: TextStyle(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: borderColor,
                  size: 28,
                ),
              ],
            ),
          ),

          // Question content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question text
                Text(
                  answer.questionText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),

                // Question image if available
                if (answer.imageUrl != null && answer.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/exam_images/${answer.imageUrl}',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                answer.imageUrl!,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // Options
                _buildOption('A', answer.optionA, answer.studentAnswer, answer.correctAnswer),
                const SizedBox(height: 8),
                _buildOption('B', answer.optionB, answer.studentAnswer, answer.correctAnswer),
                const SizedBox(height: 8),
                _buildOption('C', answer.optionC, answer.studentAnswer, answer.correctAnswer),

                // Summary
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 20, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Student answered: ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            answer.studentAnswer.isNotEmpty ? answer.studentAnswer : 'No answer',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (!isCorrect) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.check_circle, size: 20, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'Correct answer: ',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              answer.correctAnswer,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String letter, String text, String studentAnswer, String correctAnswer) {
    final isStudentAnswer = studentAnswer == letter;
    final isCorrectAnswer = correctAnswer == letter;
    
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    IconData? icon;
    Color? iconColor;

    if (isCorrectAnswer) {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green.shade600;
      icon = Icons.check_circle;
      iconColor = Colors.green.shade700;
    }
    
    if (isStudentAnswer && !isCorrectAnswer) {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red.shade600;
      icon = Icons.cancel;
      iconColor = Colors.red.shade700;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: borderColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, color: iconColor, size: 26),
          ],
        ],
      ),
    );
  }
}
