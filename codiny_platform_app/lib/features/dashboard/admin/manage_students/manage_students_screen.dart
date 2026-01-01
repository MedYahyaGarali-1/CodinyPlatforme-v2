import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/shared/layout/base_scaffold.dart';
import '/state/session/session_controller.dart';
import '/data/repositories/admin_repository.dart';
import '/data/models/admin/admin_student.dart';
import 'student_details_screen.dart';

class ManageStudentsScreen extends StatefulWidget {
  const ManageStudentsScreen({super.key});

  @override
  State<ManageStudentsScreen> createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  late Future<List<AdminStudent>> _futureStudents;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final session = context.read<SessionController>();
      _futureStudents = AdminRepository().getAllStudents(token: session.token);
      _inited = true;
    }
  }

  Future<void> _reload() async {
    final session = context.read<SessionController>();
    setState(() {
      _futureStudents = AdminRepository().getAllStudents(token: session.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Manage Students',
      body: FutureBuilder<List<AdminStudent>>(
        future: _futureStudents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Failed to load students: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final students = snapshot.data ?? <AdminStudent>[];
          if (students.isEmpty) {
            return const Center(child: Text('No students found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final student = students[index];
              return _StudentCard(
                studentId: student.id,
                name: student.name,
                type: student.type,
                school: student.school,
                status: student.status,
                daysLeft: student.daysLeft,
              );
            },
          );
        },
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String studentId;
  final String name;
  final String type;
  final String? school;
  final String status;
  final int daysLeft;

  const _StudentCard({
    required this.studentId,
    required this.name,
    required this.type,
    required this.school,
    required this.status,
    required this.daysLeft,
  });

  bool get isActive => status == 'Active';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Name + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                _StatusChip(active: isActive),
              ],
            ),

            const SizedBox(height: 8),

            // 🧾 Info
            Text(
              'Type: $type',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            if (school != null) ...[
              const SizedBox(height: 4),
              Text(
                'School: $school',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[700]),
              ),
            ],

            const SizedBox(height: 8),

            // ⏳ Subscription
            Text(
              isActive
                  ? 'Days left: $daysLeft'
                  : 'Subscription expired',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            // ⚙️ Actions (future)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentDetailsScreen(studentId: studentId),
                      ),
                    );
                  },
                  child: const Text('View'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                  },
                  child: Text(isActive ? 'Block' : 'Unblock'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool active;

  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(active ? 'Active' : 'Expired'),
      backgroundColor: active
          ? Colors.green.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
      labelStyle: TextStyle(
        color: active ? Colors.green : Colors.red,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
