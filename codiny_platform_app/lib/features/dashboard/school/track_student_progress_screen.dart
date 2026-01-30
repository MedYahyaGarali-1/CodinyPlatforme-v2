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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: FutureBuilder<List<SchoolStudent>>(
        future: _future,
        builder: (context, snap) {
          // Loading State
          if (snap.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          // Error State
          if (snap.hasError || snap.data == null) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Failed to Load',
                    message: snap.error?.toString() ?? 'Unknown error',
                    actionLabel: 'Retry',
                    onAction: _refresh,
                  ),
                ),
              ],
            );
          }

          final students = snap.data!;

          // Empty State
          if (students.isEmpty) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverFillRemaining(
                  child: _buildEmptyState(),
                ),
              ],
            );
          }

          final activeCount = students.where((s) => s.hasActiveSubscription).length;
          
          // Calculate real exam stats
          final totalExamsTaken = students.fold<int>(0, (sum, s) => sum + s.totalExams);
          final totalExamsPassed = students.fold<int>(0, (sum, s) => sum + s.passedExams);

          // Success State
          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                
                // Stats Summary
                SliverToBoxAdapter(
                  child: _buildStatsSummary(
                    students.length, 
                    activeCount,
                    totalExamsTaken,
                    totalExamsPassed,
                  ),
                ),

                // Students List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildStudentCard(students[i], i),
                      ),
                      childCount: students.length,
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

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade50, Theme.of(context).colorScheme.surface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.analytics_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Track Progress',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh_rounded, color: Colors.purple.shade700),
            onPressed: _refresh,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSummary(int totalStudents, int activeCount, int totalExams, int passedExams) {
    final passRate = totalExams > 0 ? ((passedExams / totalExams) * 100).round() : 0;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.people_rounded,
                value: totalStudents.toString(),
                label: 'Total Students',
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.check_circle_rounded,
                value: activeCount.toString(),
                label: 'Active Now',
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            Expanded(
              child: _buildSummaryItem(
                icon: Icons.emoji_events_rounded,
                value: '$passRate%',
                label: 'Pass Rate',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStudentCard(SchoolStudent student, int index) {
    final isActive = student.hasActiveSubscription;
    final name = student.name;
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

    // Use real data from API
    final progressPercent = student.progressPercent;
    final examsPassed = student.passedExams;
    final totalExams = student.totalExams;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.pushSmooth(
            StudentProgressDetailScreen(student: student),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Top Row - Avatar, Name, Progress Ring
              Row(
                children: [
                  // Avatar with gradient
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isActive
                            ? [Colors.blue.shade400, Colors.blue.shade700]
                            : [Colors.grey.shade400, Colors.grey.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isActive ? Colors.blue : Colors.grey).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  
                  // Name & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isActive ? Colors.green.shade200 : Colors.grey.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isActive ? Colors.green : Colors.grey,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.purple.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.emoji_events_rounded, size: 12, color: Colors.purple.shade600),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$examsPassed/$totalExams Exams',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Progress Ring
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: CircularProgressIndicator(
                            value: progressPercent / 100,
                            strokeWidth: 5,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progressPercent >= 80 
                                  ? Colors.green 
                                  : progressPercent >= 50 
                                      ? Colors.orange 
                                      : Colors.red,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Center(
                          child: Text(
                            '$progressPercent%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 14),
              
              // Progress Bar Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exam Progress',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '$examsPassed/$totalExams passed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: totalExams > 0 ? examsPassed / totalExams : 0,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressPercent >= 80 
                              ? Colors.green.shade500
                              : progressPercent >= 50
                                  ? Colors.orange.shade500
                                  : Colors.blue.shade500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.quiz_rounded,
                      label: 'View Exams',
                      color: Colors.blue,
                      onTap: () {
                        context.pushSmooth(
                          StudentProgressDetailScreen(student: student),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.insights_rounded,
                      label: 'Full Report',
                      color: Colors.purple,
                      onTap: () {
                        context.pushSmooth(
                          StudentProgressDetailScreen(student: student),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color.shade600),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ShimmerLoading(
              isLoading: true,
              child: SkeletonCard(height: 100, borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerLoading(
                  isLoading: true,
                  child: SkeletonCard(height: 180, borderRadius: BorderRadius.circular(20)),
                ),
              ),
              childCount: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 64,
                color: Colors.purple.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Students to Track',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add students to your school to track\ntheir learning progress and exam results.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.people_rounded),
              label: const Text('Go to Students'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
