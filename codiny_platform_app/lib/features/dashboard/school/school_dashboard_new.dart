import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/layout/dashboard_shell.dart';
import '../../../state/session/session_controller.dart';
import '../../../data/repositories/user_repository.dart';
import 'attach_student_screen.dart';
import 'school_students_screen.dart';
import 'student_calendars_screen.dart';
import 'track_student_progress_screen.dart';
import 'financial_reports_screen.dart';
import '../../../shared/ui/dashboard_cards.dart';
import '../../../shared/widgets/revenue_stats_widget.dart';
import '../../../shared/widgets/exam_stats_widget.dart';

class SchoolDashboard extends StatelessWidget {
  const SchoolDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardShell(
      showLogout: true,
      showThemeToggle: true,
      tabs: [
        DashboardTab(
          label: 'Home',
          icon: Icons.home,
          body: _SchoolHomeLoader(),
        ),
      ],
    );
  }
}

class _SchoolHomeLoader extends StatefulWidget {
  const _SchoolHomeLoader();

  @override
  State<_SchoolHomeLoader> createState() => _SchoolHomeLoaderState();
}

class _SchoolHomeLoaderState extends State<_SchoolHomeLoader> {
  late Future<void> _load;

  @override
  void initState() {
    super.initState();
    _load = _loadProfile();
  }

  Future<void> _loadProfile() async {
    final session = context.read<SessionController>();
    final repo = UserRepository();
    await repo.loadSchoolProfile(session);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load,
      builder: (context, snap) {
        final session = context.watch<SessionController>();
        final profile = session.schoolProfile;

        if (snap.connectionState == ConnectionState.waiting && profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError && profile == null) {
          return Center(
            child: Text(
              'Failed to load profile\n${snap.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        return SchoolHomeScreen(
          students: profile?.students ?? 0,
          earned: profile?.earned ?? 0,
          owed: profile?.owed ?? 0,
          onRefresh: () {
            setState(() {
              _load = _loadProfile();
            });
          },
        );
      },
    );
  }
}

class SchoolHomeScreen extends StatelessWidget {
  final int students;
  final int earned;
  final int owed;
  final VoidCallback onRefresh;

  const SchoolHomeScreen({
    super.key,
    required this.students,
    required this.earned,
    required this.owed,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalRevenue = earned + owed;

    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Welcome Header with Gradient
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary,
                  cs.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'School Dashboard',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage students and track performance',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: onRefresh,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          DashboardSectionHeader(
            title: 'Overview',
            subtitle: 'Your school metrics at a glance',
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.5,
            children: [
              _EnhancedStatCard(
                title: 'Total Students',
                value: '$students',
                icon: Icons.people_rounded,
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                trend: '+12%',
                trendUp: true,
              ),
              _EnhancedStatCard(
                title: 'Your Earnings',
                value: '$earned TND',
                icon: Icons.payments_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                trend: '+8%',
                trendUp: true,
              ),
              _EnhancedStatCard(
                title: 'Platform Share',
                value: '$owed TND',
                icon: Icons.account_balance_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              _EnhancedStatCard(
                title: 'Total Revenue',
                value: '$totalRevenue TND',
                icon: Icons.trending_up_rounded,
                gradient: LinearGradient(
                  colors: [cs.secondary, cs.secondary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Revenue Stats Widget
          Builder(
            builder: (context) {
              final session = context.watch<SessionController>();
              final schoolId = session.schoolProfile?.id;
              
              if (schoolId != null) {
                return RevenueStatsWidget(
                  token: session.token ?? '',
                  schoolId: schoolId,
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 24),

          // Exam Stats Widget
          Builder(
            builder: (context) {
              final session = context.watch<SessionController>();
              final schoolId = session.schoolProfile?.id;
              
              if (schoolId != null) {
                return ExamStatsWidget(
                  token: session.token ?? '',
                  userRole: 'school',
                  schoolId: schoolId,
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 28),

          DashboardSectionHeader(
            title: 'Student Management',
            subtitle: 'Manage your students efficiently',
          ),
          const SizedBox(height: 16),

          _EnhancedActionCard(
            label: 'View All Students',
            icon: Icons.people_rounded,
            description: 'See all students and their subscription status',
            gradient: LinearGradient(
              colors: [cs.primaryContainer, cs.primaryContainer.withOpacity(0.5)],
            ),
            iconColor: cs.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SchoolStudentsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _EnhancedActionCard(
            label: 'Add New Student',
            icon: Icons.person_add_rounded,
            description: 'Attach an existing student account to your school',
            gradient: const LinearGradient(
              colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
            ),
            iconColor: const Color(0xFF10B981),
            onTap: () async {
              final ok = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttachStudentScreen()),
              );
              if (ok == true) onRefresh();
            },
          ),
          const SizedBox(height: 12),

          _EnhancedActionCard(
            label: 'Student Calendars',
            icon: Icons.calendar_month_rounded,
            description: 'Schedule lessons, exams, and appointments',
            gradient: const LinearGradient(
              colors: [Color(0xFFDDD6FE), Color(0xFFC4B5FD)],
            ),
            iconColor: const Color(0xFF8B5CF6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentCalendarsScreen()),
              );
            },
          ),
          const SizedBox(height: 12),

          _EnhancedActionCard(
            label: 'Track Progress',
            icon: Icons.assessment_rounded,
            description: 'View test results and learning progress',
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
            ),
            iconColor: const Color(0xFFF59E0B),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TrackStudentProgressScreen()),
              );
            },
          ),

          const SizedBox(height: 28),

          DashboardSectionHeader(
            title: 'Reports & Analytics',
            subtitle: 'Financial and performance insights',
          ),
          const SizedBox(height: 16),

          _EnhancedActionCard(
            label: 'Financial Reports',
            icon: Icons.receipt_long_rounded,
            description: 'View earnings, payments, and revenue history',
            gradient: const LinearGradient(
              colors: [Color(0xFFBFDBFE), Color(0xFF93C5FD)],
            ),
            iconColor: const Color(0xFF3B82F6),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FinancialReportsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Enhanced Stat Card Widget
class _EnhancedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final String? trend;
  final bool trendUp;

  const _EnhancedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.trend,
    this.trendUp = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    if (trend != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trendUp ? Icons.trending_up : Icons.trending_down,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              trend!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced Action Card Widget
class _EnhancedActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback onTap;

  const _EnhancedActionCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.black38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
