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
import '../../../shared/ui/stat_card.dart';
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        DashboardSectionHeader(
          title: 'Overview',
          subtitle: 'Your school metrics',
          trailing: IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
          ),
        ),
        const SizedBox(height: 14),

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
              value: students,
              icon: Icons.people,
              color: cs.primary,
              showTrend: true,
              trend: '+12%',
            ),
            StatCard(
              title: 'Your Earnings',
              value: earned,
              icon: Icons.attach_money,
              color: const Color(0xFF10B981),
              showTrend: true,
              trend: '+8%',
            ),
            StatCard(
              title: 'Owed to Platform',
              value: owed,
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFF59E0B),
            ),
            StatCard(
              title: 'Status',
              value: 1, // Active = 1
              icon: Icons.verified,
              color: const Color(0xFF10B981),
            ),
          ],
        ),

        const SizedBox(height: 22),

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

        const SizedBox(height: 22),

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

        const SizedBox(height: 22),

        DashboardSectionHeader(
          title: 'Student Management',
          subtitle: 'Manage your students',
        ),
        const SizedBox(height: 10),

        DashboardActionTile(
          label: 'View all students',
          icon: Icons.people,
          description: 'See attached students and their subscription status',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SchoolStudentsScreen()),
            );
          },
        ),
        const SizedBox(height: 10),

        DashboardActionTile(
          label: 'Add student to school',
          icon: Icons.person_add,
          description: 'Attach an existing student account',
          onTap: () async {
            final ok = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AttachStudentScreen()),
            );
            if (ok == true) onRefresh();
          },
        ),
        const SizedBox(height: 10),

        DashboardActionTile(
          label: 'Student calendars',
          icon: Icons.calendar_month,
          description: 'Schedule lessons, exams, and appointments',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentCalendarsScreen()),
            );
          },
        ),
        const SizedBox(height: 10),

        DashboardActionTile(
          label: 'Track student progress',
          icon: Icons.assessment,
          description: 'View test results and learning progress',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrackStudentProgressScreen()),
            );
          },
        ),

        const SizedBox(height: 22),

        DashboardSectionHeader(
          title: 'Reports & Analytics',
          subtitle: 'Financial and performance reports',
        ),
        const SizedBox(height: 10),

        DashboardActionTile(
          label: 'Financial reports',
          icon: Icons.receipt_long,
          description: 'View earnings, payments, and revenue history',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FinancialReportsScreen()),
            );
          },
        ),
      ],
    );
  }
}