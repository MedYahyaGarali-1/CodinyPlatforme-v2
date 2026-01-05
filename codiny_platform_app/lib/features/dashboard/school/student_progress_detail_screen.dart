import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../state/session/session_controller.dart';
import '../../../data/models/school/school_student.dart';
import '../../../data/models/exam/exam_models.dart';
import '../../../data/repositories/school_repository.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';

class StudentProgressDetailScreen extends StatefulWidget {
  final SchoolStudent student;

  const StudentProgressDetailScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentProgressDetailScreen> createState() => _StudentProgressDetailScreenState();
}

class _StudentProgressDetailScreenState extends State<StudentProgressDetailScreen> {
  final SchoolRepository _schoolRepo = SchoolRepository();
  late Future<List<ExamResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadExams();
  }

  Future<List<ExamResult>> _loadExams() async {
    final token = context.read<SessionController>().token;
    if (token == null) throw Exception('Not authenticated');
    
    try {
      return await _schoolRepo.getStudentExamHistory(
        token: token,
        studentId: widget.student.id.toString(),
      );
    } catch (e) {
      print('Error loading student exams: $e');
      rethrow;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('${widget.student.name} - Progress'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<ExamResult>>(
        future: _future,
        builder: (context, snap) {
          // Loading State
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerLoading(
                  isLoading: true,
                  child: SkeletonCard(
                    height: 100,
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

          final exams = snap.data ?? const <ExamResult>[];

          // Calculate statistics
          final totalExams = exams.length;
          final passedExams = exams.where((e) => e.passed).length;
          final averageScore = exams.isEmpty
              ? 0.0
              : exams.map((e) => e.score).reduce((a, b) => a + b) / exams.length;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                // Statistics Header
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
                        // Student Name
                        Text(
                          widget.student.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Stats Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                label: 'Total Exams',
                                value: totalExams.toString(),
                                icon: Icons.quiz,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                label: 'Passed',
                                value: passedExams.toString(),
                                icon: Icons.check_circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                label: 'Average Score',
                                value: '${(averageScore * 100).toStringAsFixed(1)}%',
                                icon: Icons.trending_up,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                label: 'Success Rate',
                                value: totalExams > 0
                                    ? '${((passedExams / totalExams) * 100).toStringAsFixed(0)}%'
                                    : '0%',
                                icon: Icons.emoji_events,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Exam History Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 20,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exam History',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Exam List or Empty State
                if (exams.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'No Exams Yet',
                      message: 'This student hasn\'t taken any exams yet.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final exam = exams[i];
                          final percentage = exam.score;
                          final isPassed = exam.passed;
                          final date = exam.completedAt ?? exam.startedAt;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color: colorScheme.outlineVariant,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header with Status Badge
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Exam ${i + 1}',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isPassed
                                                ? Colors.green.withOpacity(0.1)
                                                : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isPassed
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                size: 16,
                                                color: isPassed ? Colors.green : Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isPassed ? 'Passed' : 'Failed',
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: isPassed ? Colors.green : Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Score and Date
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.score,
                                          size: 16,
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${exam.correctAnswers}/${exam.totalQuestions} (${percentage.toStringAsFixed(1)}%)',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          DateFormat('MMM dd, yyyy').format(date),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    // Progress Bar
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: exam.correctAnswers / exam.totalQuestions,
                                        minHeight: 8,
                                        backgroundColor: colorScheme.surfaceVariant,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isPassed ? Colors.green : Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: exams.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
