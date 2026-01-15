import 'package:flutter/material.dart';

import '../../core/enums/user_role.dart';
import '../../data/models/profiles/school_profile.dart';
import '../../data/models/profiles/student_profile.dart';
import '../../data/models/user.dart';
import '../../data/services/storage_service.dart';

class SessionController extends ChangeNotifier {
  User? _currentUser;
  String? _token;

  StudentProfile? _studentProfile;
  SchoolProfile? _schoolProfile;

  final StorageService _storage = StorageService();

  // ---------- GETTERS ----------
  bool get isLoggedIn => _currentUser != null && _token != null;

  User? get user => _currentUser;
  String? get token => _token;

  UserRole? get role => _currentUser?.role;

  StudentProfile? get studentProfile => _studentProfile;
  SchoolProfile? get schoolProfile => _schoolProfile;

  bool get isStudent => role == UserRole.student;
  bool get isSchool => role == UserRole.school;
  bool get isAdmin => role == UserRole.admin;

  // ---------- ACTIONS ----------

  /// 🔐 SET USER + TOKEN (USED BY AUTH)
  Future<void> setSession(User user, String token) async {
    _currentUser = user;
    _token = token;

    await _storage.saveToken(token);
    await _storage.saveUser(user);

    notifyListeners();
  }

  void setStudentProfile(StudentProfile profile) {
    _studentProfile = profile;
    notifyListeners();
  }

  void setSchoolProfile(SchoolProfile profile) {
    _schoolProfile = profile;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _studentProfile = null;
    _schoolProfile = null;

    await _storage.clear();

    notifyListeners();
  }

  // ---------- RESTORE ----------
  Future<void> restoreSession() async {
    try {
      print('🔄 Starting session restore...');
      final token = await _storage.getToken();
      print('📱 Token retrieved: ${token != null ? "exists" : "null"}');
      
      final user = await _storage.getUser();
      print('👤 User retrieved: ${user != null ? user.name : "null"}');

      if (token == null || user == null) {
        print('⚠️  No saved session found');
        return;
      }

      _token = token;
      _currentUser = user;
      print('✅ Session restored successfully');
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ Error restoring session: $e');
      print('Stack trace: $stackTrace');
      // Clear potentially corrupted data
      try {
        await _storage.clear();
        print('🧹 Cleared corrupted session data');
      } catch (clearError) {
        print('❌ Error clearing storage: $clearError');
      }
    }
  }
}
