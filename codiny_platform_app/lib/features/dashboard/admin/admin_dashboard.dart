import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'create_school/create_school_screen.dart';
import 'manage_schools/manage_schools_screen.dart';
import 'manage_students/manage_students_screen.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/layout/base_scaffold.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/models/admin/admin_overview.dart';
import '../../../state/theme/theme_controller.dart';
import '../../../shared/ui/stat_card.dart';
import '../../../shared/widgets/revenue_stats_widget.dart';
import '../../../shared/widgets/exam_stats_widget.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<AdminOverview> _futureOverview;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      final session = context.read<SessionController>();
      _futureOverview = AdminRepository().getAdminOverview(token: session.token);
      _inited = true;
    }
  }

  Future<void> _reload() async {
    final session = context.read<SessionController>();
    setState(() {
      _futureOverview = AdminRepository().getAdminOverview(token: session.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final cs = Theme.of(context).colorScheme;

    return BaseScaffold(
      title: 'Admin Dashboard',
      showBackButton: false, // Dashboard screen - no back button
      actions: [
        IconButton(
          tooltip: 'Toggle theme',
          icon: Icon(
            context.watch<ThemeController>().isDark
                ? Icons.light_mode
                : Icons.dark_mode,
          ),
          onPressed: () {
            context.read<ThemeController>().toggle();
          },
        ),
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: _reload,
        ),
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await session.logout();
          },
        ),
      ],
      body: FutureBuilder<AdminOverview>(
        future: _futureOverview,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Card(
                    elevation: 0,
                    color: cs.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Could not load dashboard',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onErrorContainer,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: cs.onErrorContainer,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          final overview = snapshot.data ??
              const AdminOverview(
                totalStudents: 0,
                totalSchools: 0,
                monthlyRevenue: 0,
                owedBySchools: 0,
              );

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _HeaderCard(
                title: 'Overview',
                subtitle: 'Live metrics from your platform',
              ),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  StatCard(
                    title: 'Total Students',
                    value: overview.totalStudents,
                    icon: Icons.people,
                    color: cs.primary,
                    showTrend: true,
                    trend: '+15%',
                  ),
                  StatCard(
                    title: 'Auto-écoles',
                    value: overview.totalSchools,
                    icon: Icons.school,
                    color: const Color(0xFF10B981),
                    showTrend: true,
                    trend: '+5%',
                  ),
                  StatCard(
                    title: 'Monthly Revenue',
                    value: overview.monthlyRevenue,
                    icon: Icons.attach_money,
                    color: const Color(0xFF8B5CF6),
                  ),
                  StatCard(
                    title: 'Owed by Schools',
                    value: overview.owedBySchools,
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Revenue Stats Widget
              RevenueStatsWidget(token: session.token ?? ''),

              const SizedBox(height: 20),

              // Exam Stats Widget
              ExamStatsWidget(
                token: session.token ?? '',
                userRole: 'admin',
              ),

              const SizedBox(height: 20),

              _SectionTitle(
                title: 'Quick Actions',
                subtitle: 'Manage key areas of the platform',
              ),
              const SizedBox(height: 10),

              _ActionTile(
                label: 'Create Auto-école',
                icon: Icons.add_business,
                description: 'Add a new school account',
                onTap: () async {
                  final created = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateSchoolScreen(),
                    ),
                  );

                  if (created == true) {
                    await _reload();
                  }
                },
              ),
              const SizedBox(height: 10),

              _ActionTile(
                label: 'Manage Auto-écoles',
                icon: Icons.apartment,
                description: 'View, block, and review school stats',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageSchoolsScreen(),
                    ),
                  ).then((_) => _reload());
                },
              ),
              const SizedBox(height: 10),

              _ActionTile(
                label: 'Manage Students',
                icon: Icons.manage_accounts,
                description: 'Search students and inspect subscriptions',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageStudentsScreen(),
                    ),
                  ).then((_) => _reload());
                },
              ),

              const SizedBox(height: 10),

              _ActionTile(
                label: 'Financial Reports',
                icon: Icons.bar_chart,
                description: 'Revenue and payout analytics (soon)',
                onTap: () {
                  // Next screen later
                },
                enabled: false,
              ),
              const SizedBox(height: 10),
              _ActionTile(
                label: 'Content Management',
                icon: Icons.video_library,
                description: 'Courses and media library (soon)',
                onTap: () {
                  // Next screen later
                },
                enabled: false,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.12),
            cs.secondary.withOpacity(0.10),
          ],
        ),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.dashboard_rounded, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionTitle({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionTile({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        splashColor: cs.primary.withOpacity(0.10),
        highlightColor: cs.primary.withOpacity(0.06),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
            color: cs.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: cs.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
