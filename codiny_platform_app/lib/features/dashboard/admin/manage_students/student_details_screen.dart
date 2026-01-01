import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/shared/layout/base_scaffold.dart';
import '/state/session/session_controller.dart';
import '/data/repositories/admin_repository.dart';
import '/data/models/admin/admin_student.dart';

class StudentDetailsScreen extends StatelessWidget {
  final String studentId;

  const StudentDetailsScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();

    return BaseScaffold(
      title: 'Student Details',
      body: FutureBuilder<AdminStudent>(
        future: AdminRepository().getStudentDetails(studentId, token: session.token),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Failed to load student details: ${snapshot.error}'),
            );
          }

          final s = snapshot.data!;
          final isActive = s.status == 'Active';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                s.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Type: ${s.type}'),
                      const SizedBox(height: 8),
                      Text('Status: ${s.status}'),
                      const SizedBox(height: 8),
                      Text(isActive ? 'Days left: ${s.daysLeft}' : 'Subscription expired'),
                      if (s.school != null && s.school!.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('School: ${s.school}'),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
