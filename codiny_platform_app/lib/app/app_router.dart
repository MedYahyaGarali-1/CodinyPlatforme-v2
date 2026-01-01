import 'package:flutter/material.dart';

// Auth
import '../features/auth/login/login_screen.dart';
import '../features/auth/register/register_screen.dart';

// Dashboards
import '../features/dashboard/student/student_dashboard.dart';
import '../features/dashboard/school/school_dashboard.dart';
import '../features/dashboard/admin/admin_dashboard.dart';
import '../features/dashboard/admin/create_school/create_school_screen.dart';
import '../features/dashboard/admin/manage_schools/manage_schools_screen.dart';
import '../features/dashboard/admin/manage_students/manage_students_screen.dart';

class AppRouter {
  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Dashboards
  static const String studentDashboard = '/student';
  static const String schoolDashboard = '/school';
  static const String adminDashboard = '/admin';
  static const String userDashboard = '/user';

  // Admin actions
  static const String adminCreateSchool = '/admin/create-school';
  static const String adminSchools = '/admin/schools';
  static const String adminStudents = '/admin/students';

  // Route map
  static Map<String, WidgetBuilder> routes = {
    // Auth
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),

    // Dashboards
    studentDashboard: (context) => const StudentDashboard(),
    schoolDashboard: (context) => const SchoolDashboard(),
    adminDashboard: (context) => const AdminDashboard(),
    userDashboard: (context) => const StudentDashboard(),

    // Admin screens
    adminCreateSchool: (context) => const CreateSchoolScreen(),
    adminSchools: (context) => const ManageSchoolsScreen(),
    adminStudents: (context) => const ManageStudentsScreen(),
  };
}
