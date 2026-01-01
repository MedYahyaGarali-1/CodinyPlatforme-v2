import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/layout/dashboard_shell.dart';
import '../../../state/session/session_controller.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/onboarding_repository.dart';
import '../../../core/config/environment.dart';
import '../../onboarding/onboarding_screen.dart';

import 'student_home_screen.dart';
import 'courses_screen.dart';
import 'exams_screen.dart';
import 'student_events_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isCheckingOnboarding = true;
  bool _needsOnboarding = false;

  @override
  void initState() {
    super.initState();

    // 🔥 Load student profile and check onboarding status
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final session = context.read<SessionController>();
      final repo = UserRepository();
      final onboardingRepo = OnboardingRepository(baseUrl: Environment.baseUrl);

      // Load profile if not loaded
      if (session.studentProfile == null) {
        await repo.loadStudentProfile(session);
      }

      // Check if onboarding is complete
      try {
        final accessStatus = await onboardingRepo.getAccessStatus(token: session.token!);
        
        setState(() {
          _needsOnboarding = !accessStatus.student.onboardingComplete;
          _isCheckingOnboarding = false;
        });
      } catch (e) {
        setState(() {
          _isCheckingOnboarding = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while checking onboarding
    if (_isCheckingOnboarding) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show onboarding screen if needed
    if (_needsOnboarding) {
      return const OnboardingScreen();
    }

    // Show normal dashboard
    return DashboardShell(
      showLogout: true,
      showThemeToggle: true,
      tabs: const [
        DashboardTab(
          label: 'Home',
          icon: Icons.home,
          body: StudentHomeScreen(),
        ),
        DashboardTab(
          label: 'Calendar',
          icon: Icons.calendar_month,
          body: StudentEventsScreen(),
        ),
        DashboardTab(
          label: 'Courses',
          icon: Icons.play_circle,
          body: CoursesScreen(),
        ),
        DashboardTab(
          label: 'Exams',
          icon: Icons.assignment,
          body: ExamsScreen(),
        ),
      ],
    );
  }
}


