import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/school_repository.dart';
import '../../../state/session/session_controller.dart';
import '../../../data/models/school/school_student.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/smooth_page_transition.dart';
import 'student_detail_screen.dart';

class StudentCalendarsScreen extends StatefulWidget {
  const StudentCalendarsScreen({super.key});

  @override
  State<StudentCalendarsScreen> createState() => _StudentCalendarsScreenState();
}

class _StudentCalendarsScreenState extends State<StudentCalendarsScreen> {
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
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snap.hasError || snap.data == null) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverFillRemaining(
                  child: _buildErrorState(snap.error?.toString() ?? 'Unknown error'),
                ),
              ],
            );
          }

          final students = snap.data!;
          
          if (students.isEmpty) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverFillRemaining(
                  child: EmptyState(
                    title: 'No Students',
                    message: 'You haven\'t attached any students yet.',
                    icon: Icons.person_off_outlined,
                    actionLabel: 'Refresh',
                    onAction: _refresh,
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                
                // Stats Header
                SliverToBoxAdapter(
                  child: _buildStatsHeader(students),
                ),
                
                // Students List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildStudentCard(students[i]),
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
              colors: [Colors.indigo.shade50, Theme.of(context).colorScheme.surface],
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
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Student Calendars',
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
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh_rounded, color: Colors.indigo.shade700),
            onPressed: _refresh,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader(List<SchoolStudent> students) {
    final activeCount = students.where((s) => s.hasActiveSubscription).length;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade400, Colors.indigo.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.people_rounded,
                value: '${students.length}',
                label: 'Total Students',
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.check_circle_rounded,
                value: '$activeCount',
                label: 'Active',
              ),
            ),
            Container(
              width: 1,
              height: 50,
              color: Colors.white.withOpacity(0.3),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.event_note_rounded,
                value: '${students.length - activeCount}',
                label: 'Inactive',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(SchoolStudent student) {
    final isActive = student.hasActiveSubscription;
    final name = student.name;
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive 
              ? Colors.indigo.shade100 
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await context.pushSmooth(StudentDetailScreen(student: student));
          _refresh();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive
                        ? [Colors.indigo.shade400, Colors.indigo.shade600]
                        : [Colors.grey.shade400, Colors.grey.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (isActive ? Colors.indigo : Colors.grey).withOpacity(0.3),
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              
              // Info
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
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
                      ],
                    ),
                  ],
                ),
              ),
              
              // Calendar Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.indigo.shade600,
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
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
                  child: SkeletonCard(height: 84, borderRadius: BorderRadius.circular(16)),
                ),
              ),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to Load',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
