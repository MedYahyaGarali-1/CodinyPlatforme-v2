import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/state/session/session_controller.dart';
import '/shared/layout/base_scaffold.dart';
import '/data/models/profiles/school_profile.dart';
import '/data/repositories/admin_repository.dart';

class SchoolDetailsScreen extends StatelessWidget {
  final String schoolId;

  const SchoolDetailsScreen({
    super.key,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();

    return BaseScaffold(
      title: 'Auto-école Details',
      body: FutureBuilder<SchoolProfile>(
        future: AdminRepository().getSchoolDetails(schoolId, token: session.token),
        builder: (context, snapshot) {
          // ⏳ Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ❌ Error
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('Failed to load school details: ${snapshot.error}'));
          }

          final school = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🏫 Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    school.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  _StatusChip(active: school.active),
                ],
              ),

              const SizedBox(height: 20),

              // 📊 KPIs
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Students',
                      value: '${school.students}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      label: 'Earned',
                      value: '${school.earned} DT',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Owed',
                      value: '${school.owed} DT',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _KpiCard(
                      label: 'Status',
                      value: school.active ? 'Active' : 'Blocked',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ⚙️ Admin Actions
              Text(
                'Admin Actions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final repo = AdminRepository();
                    final wasActive = school.active;

                    if (wasActive) {
                      await repo.blockSchool(schoolId, token: session.token);
                    } else {
                      await repo.unblockSchool(schoolId, token: session.token);
                    }

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          wasActive
                              ? 'School blocked'
                              : 'School unblocked',
                        ),
                      ),
                    );

                    Navigator.pop(context); // go back & refresh list
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Action failed: $e'),
                      ),
                    );
                  }
                },
                icon: Icon(
                  school.active ? Icons.block : Icons.lock_open,
                ),
                label: Text(
                  school.active ? 'Block Auto-école' : 'Unblock Auto-école',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      school.active ? Colors.red : Colors.green,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================= WIDGETS =================

class _StatusChip extends StatelessWidget {
  final bool active;

  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(active ? 'Active' : 'Blocked'),
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

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;

  const _KpiCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}


