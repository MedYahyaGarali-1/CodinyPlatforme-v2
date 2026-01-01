import 'package:flutter/material.dart';
import 'package:codiny_platform_app/data/models/profiles/school_profile.dart';
import 'package:provider/provider.dart';
import '/state/session/session_controller.dart';
import 'package:codiny_platform_app/data/repositories/admin_repository.dart';

import '/shared/layout/base_scaffold.dart';
import '../school_details/school_details_screen.dart';
import '../../../../shared/ui/shimmer_loading.dart';
import '../../../../shared/ui/empty_state.dart';
import '../../../../shared/ui/snackbar_helper.dart';
import '../../../../shared/ui/smooth_page_transition.dart';

class ManageSchoolsScreen extends StatefulWidget {
  const ManageSchoolsScreen({super.key});

  @override
  State<ManageSchoolsScreen> createState() => _ManageSchoolsScreenState();
}

class _ManageSchoolsScreenState extends State<ManageSchoolsScreen> {
  late Future<List<SchoolProfile>> _futureSchools;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final session = context.read<SessionController>();
      _futureSchools = AdminRepository().getSchools(token: session.token);
      _inited = true;
    }
  }

  Future<void> _reload() async {
    final session = context.read<SessionController>();
    setState(() {
      _futureSchools = AdminRepository().getSchools(token: session.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();

    return BaseScaffold(
      title: 'Manage Auto-écoles',
      body: FutureBuilder<List<SchoolProfile>>(
        future: _futureSchools,
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ShimmerLoading(
                  isLoading: true,
                  child: SkeletonCard(
                    height: 160,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );
          }

          // Error State
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Failed to Load',
              message: 'Could not load schools: ${snapshot.error}',
              actionLabel: 'Retry',
              onAction: _reload,
            );
          }

          final schools = snapshot.data ?? [];

          // Empty State
          if (schools.isEmpty) {
            return const EmptyState(
              icon: Icons.school_outlined,
              title: 'No Auto-écoles Yet',
              message: 'When schools register, they will appear here.',
            );
          }

          // Success State
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: schools.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final school = schools[index];

                return _SchoolCard(
                  school: school,
                  onView: () {
                    context.pushSmooth(
                      SchoolDetailsScreen(schoolId: school.id.toString()),
                    ).then((_) => _reload());
                  },
                  onToggle: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(school.active ? 'Block School?' : 'Unblock School?'),
                        content: Text(
                          school.active
                              ? 'This will prevent ${school.name} from accessing the platform.'
                              : 'This will restore access for ${school.name}.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(school.active ? 'Block' : 'Unblock'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true) return;

                    try {
                      if (school.active) {
                        await AdminRepository().blockSchool(school.id.toString(), token: session.token);
                      } else {
                        await AdminRepository().unblockSchool(school.id.toString(), token: session.token);
                      }
                      await _reload();
                      if (!mounted) return;
                      SnackBarHelper.showSuccess(
                        context,
                        school.active ? 'School blocked successfully' : 'School unblocked successfully',
                      );
                    } catch (e) {
                      if (!mounted) return;
                      SnackBarHelper.showError(context, 'Action failed: $e');
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  final SchoolProfile school;
  final VoidCallback onView;
  final VoidCallback onToggle;

  const _SchoolCard({
    required this.school,
    required this.onView,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏫 Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: school.active
                          ? [Colors.blue.shade400, Colors.blue.shade600]
                          : [Colors.grey.shade400, Colors.grey.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      _StatusChip(active: school.active),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📊 Stats
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(
                    label: 'Students',
                    value: '${school.students}',
                    icon: Icons.people_outline,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  _Stat(
                    label: 'Earned',
                    value: '${school.earned} DT',
                    icon: Icons.attach_money,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  _Stat(
                    label: 'Owed',
                    value: '${school.owed} DT',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ⚙️ Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    school.active ? Icons.block : Icons.check_circle_outline,
                    size: 18,
                  ),
                  label: Text(school.active ? 'Block' : 'Unblock'),
                  style: FilledButton.styleFrom(
                    backgroundColor: school.active
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            active ? 'Active' : 'Blocked',
            style: TextStyle(
              color: active ? Colors.green.shade700 : Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}


