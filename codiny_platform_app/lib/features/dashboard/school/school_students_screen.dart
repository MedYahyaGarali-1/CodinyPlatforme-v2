import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/school_repository.dart';
import '../../../state/session/session_controller.dart';
import '../../../data/models/school/school_student.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/snackbar_helper.dart';
import '../../../shared/ui/smooth_page_transition.dart';
import '../../../shared/ui/staggered_animation.dart';
import 'attach_student_screen.dart';
import 'student_info_screen.dart';

class SchoolStudentsScreen extends StatefulWidget {
  const SchoolStudentsScreen({super.key});

  @override
  State<SchoolStudentsScreen> createState() => _SchoolStudentsScreenState();
}

class _SchoolStudentsScreenState extends State<SchoolStudentsScreen> {
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

  Future<void> _addStudent() async {
    final result = await context.pushSmooth(const AttachStudentScreen());
    if (result == true && mounted) {
      SnackBarHelper.showSuccess(context, 'Student attached successfully');
      _refresh();
    }
  }

  Future<void> _removeStudent(SchoolStudent student) async {
    // Show enhanced confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Remove Student',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action will:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildWarningItem('Remove school association', Icons.link_off),
                  _buildWarningItem('Revoke course access', Icons.school_outlined),
                  _buildWarningItem('Preserve exam history', Icons.check_circle_outline, isPositive: true),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remove', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final token = context.read<SessionController>().token;
      if (token == null) throw Exception('Not authenticated');

      await _repo.detachStudent(token: token, studentId: student.id.toString());

      if (mounted) {
        SnackBarHelper.showSuccess(context, 'Student removed successfully');
        _refresh();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Failed to remove student: ${e.toString()}');
      }
    }
  }

  Widget _buildWarningItem(String text, IconData icon, {bool isPositive = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isPositive ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isPositive ? Colors.green.shade900 : Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.people_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'My Students',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: 'Add Student',
              icon: Icon(Icons.person_add_rounded, color: Colors.green.shade700),
              onPressed: _addStudent,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: 'Refresh',
              icon: Icon(Icons.refresh_rounded, color: Colors.blue.shade700),
              onPressed: _refresh,
            ),
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
                    height: 88,
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
              icon: Icons.people_outline,
              title: 'No Students Yet',
              message: 'Add your first student to get started.\nThey can then access courses and materials.',
              actionLabel: 'Add Student',
              onAction: _addStudent,
            );
          }

          // Success State
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: students.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final st = students[i];
                final isActive = st.hasActiveSubscription;

                return StaggeredAnimationWrapper(
                  index: i,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Card(
                      elevation: 2,
                      shadowColor: isActive ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isActive 
                              ? Colors.blue.shade100
                              : Theme.of(context).colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          await context.pushSmooth(
                            StudentInfoScreen(student: st),
                          );
                          _refresh();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: isActive
                                ? LinearGradient(
                                    colors: [
                                      Colors.blue.shade50.withOpacity(0.3),
                                      Colors.white,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Enhanced Avatar with gradient and shadow
                                Hero(
                                  tag: 'student_${st.id}',
                                  child: Container(
                                    width: 60,
                                    height: 60,
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
                                          color: isActive 
                                              ? Colors.blue.withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                              ),
                              const SizedBox(width: 16),
                              // Info with better typography
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      st.name,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            letterSpacing: 0.3,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isActive 
                                            ? Colors.green.shade50
                                            : Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isActive 
                                              ? Colors.green.shade200
                                              : Colors.orange.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isActive ? Icons.check_circle : Icons.warning_amber_rounded,
                                            size: 14,
                                            color: isActive 
                                                ? Colors.green.shade700
                                                : Colors.orange.shade700,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isActive ? 'Active' : 'Inactive',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isActive 
                                                  ? Colors.green.shade700
                                                  : Colors.orange.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Enhanced Remove button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded),
                                  color: Colors.red.shade700,
                                  iconSize: 22,
                                  tooltip: 'Remove student',
                                  onPressed: () => _removeStudent(st),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 18,
                                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ));
              },
            ),
          );
        },
      ),
    );
  }
}
