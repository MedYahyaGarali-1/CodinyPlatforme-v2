import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/enums/user_role.dart';
import '../state/session/session_controller.dart';

// Auth
import '../features/auth/login/login_screen.dart';

// Dashboards
import '../features/dashboard/student/student_dashboard.dart';
import '../features/dashboard/school/school_dashboard.dart';
import '../features/dashboard/admin/admin_dashboard.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionController>(
      builder: (context, session, _) {
        // Show loading screen while checking session
        if (session.user == null && session.token == null) {
          // Check if we're still loading or just not logged in
          // For now, assume not logged in after a brief moment
          return const LoginScreen();
        }

        // ⏳ Not logged in
        if (!session.isLoggedIn) {
          return const LoginScreen();
        }

        // 🎯 Logged in → route by role
        switch (session.role) {
          case UserRole.student:
            return const StudentDashboard();

          case UserRole.school:
            return const SchoolDashboard();

          case UserRole.admin:
            return const AdminDashboard();

          case UserRole.user:
          default:
            return const StudentDashboard();
        }
      },
    );
  }
}

