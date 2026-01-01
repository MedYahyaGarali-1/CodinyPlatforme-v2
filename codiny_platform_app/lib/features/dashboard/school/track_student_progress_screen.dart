import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/school_repository.dart';
import '../../../state/session/session_controller.dart';
import '../../../data/models/school/school_student.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/smooth_page_transition.dart';
import 'student_progress_detail_screen.dart';

class TrackStudentProgressScreen extends StatefulWidget {
  const TrackStudentProgressScreen({super.key});

  @override
  State<TrackStudentProgressScreen> createState() => _TrackStudentProgressScreenState();
}

class _TrackStudentProgressScreenState extends State<TrackStudentProgressScreen> {
  final _repo = SchoolRepository();
  late Future<List<SchoolStudent>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SchoolStudent>> _load() async {
    final token = context.read<SessionController>().token;
    if (token == null) throw Exception('Not authenticated');
    return _repo.getStudents(token: token);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Track Student Progress'),
        backgroundColor: colorScheme.surface,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<SchoolStudent>>(
        future: _future,
        builder: (context, snap) {
          // Loading State
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerLoading(
                  isLoading: true,
                  child: SkeletonCard(
                    height: 120,
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

          final students = snap.data ?? const <SchoolStudent>[];

          // Empty State
          if (students.isEmpty) {
            return EmptyState(
              icon: Icons.assessment_outlined,
              title: 'No Students to Track',
              message: 'Add students to your school to track their learning progress and exam results.',
              actionLabel: 'Go to Students',
              onAction: () => Navigator.pop(context),
            );
          }

          // Success State
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              itemBuilder: (context, i) {
                final student = students[i];
                final isActive = student.hasActiveSubscription;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        context.pushSmooth(
                          StudentProgressDetailScreen(student: student),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student Header
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.primary,
                                        colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: Center(
                                    child: Text(
                                      student.name.isNotEmpty
                                          ? student.name[0].toUpperCase()
                                          : '?',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Name & Status
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: isActive
                                                  ? Colors.green
                                                  : Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isActive ? 'Active' : 'Inactive',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: isActive
                                                  ? Colors.green
                                                  : colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Arrow
                                Icon(
                                  Icons.chevron_right,
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 12),
                            
                            // Quick Stats
                            Row(
                              children: [
                                _buildStatChip(
                                  context,
                                  icon: Icons.quiz,
                                  label: 'View Exams',
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                  context,
                                  icon: Icons.trending_up,
                                  label: 'See Progress',
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
