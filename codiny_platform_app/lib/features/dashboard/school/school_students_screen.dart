import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/school_repository.dart';
import '../../../state/session/session_controller.dart';
import '../../../data/models/school/school_student.dart';
import '../../../shared/ui/snackbar_helper.dart';
import '../../../shared/ui/smooth_page_transition.dart';
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
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'My Students',
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
            return const Center(child: CircularProgressIndicator());
          }

          // Error State
          if (snap.hasError || snap.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load students',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snap.error?.toString() ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final students = snap.data!;

          // Empty State
          if (students.isEmpty) {
            return _buildEmptyState();
          }

          // Stats summary
          final activeCount = students.where((s) => s.hasActiveSubscription).length;
          final inactiveCount = students.length - activeCount;

          // Success State
          return RefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              slivers: [
                // Stats Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            students.length,
                            Icons.people_rounded,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Active',
                            activeCount,
                            Icons.check_circle_rounded,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Inactive',
                            inactiveCount,
                            Icons.pause_circle_rounded,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Students List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStudent,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.shade600, size: 24),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 600),
            builder: (context, val, _) => Text(
              val.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(SchoolStudent st) {
    final isActive = st.hasActiveSubscription;
    final name = st.name;
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final subEnd = st.subscriptionEnd;
    
    // Calculate days left safely
    int? daysLeft;
    if (subEnd != null) {
      daysLeft = subEnd.difference(DateTime.now()).inDays;
    }
    final isExpiringSoon = daysLeft != null && daysLeft >= 0 && daysLeft <= 7;

    return Card(
      elevation: 2,
      shadowColor: isActive ? Colors.blue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isExpiringSoon
              ? Colors.orange.shade300
              : isActive
                  ? Colors.blue.shade100
                  : Theme.of(context).colorScheme.outlineVariant,
          width: isExpiringSoon ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await context.pushSmooth(StudentInfoScreen(student: st));
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
                        ? [Colors.blue.shade400, Colors.blue.shade700]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
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
                    if (subEnd != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Expires: ${DateFormat('MMM d, y').format(subEnd)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      children: [
                        _buildStatusBadge(
                          isActive ? 'Active' : 'Inactive',
                          isActive ? Icons.check_circle : Icons.pause_circle,
                          isActive ? Colors.green : Colors.grey,
                        ),
                        if (isExpiringSoon) ...[
                          const SizedBox(width: 6),
                          _buildStatusBadge(
                            '$daysLeft days left',
                            Icons.timer,
                            Colors.orange,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 20),
                      color: Colors.red.shade600,
                      tooltip: 'Remove student',
                      onPressed: () => _removeStudent(st),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.shade200, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color.shade700),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
        ],
      ),
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
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 64,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Students Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Add your first student to get started.\nThey can then access courses and materials.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _addStudent,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Add Your First Student'),
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
