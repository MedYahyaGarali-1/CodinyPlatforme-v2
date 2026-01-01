import '../services/api_service.dart';
import '../models/profiles/student_profile.dart';
import '../models/profiles/school_profile.dart';
import '../../state/session/session_controller.dart';

class UserRepository {
  final ApiService _api;

  UserRepository({ApiService? api}) : _api = api ?? ApiService();

  // ---------- STUDENT PROFILE ----------
  Future<void> loadStudentProfile(SessionController session) async {
    final token = session.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _api.get(
      '/students/me',
      token: token,
    );

    final profile = StudentProfile.fromJson(response);
    session.setStudentProfile(profile);
  }

  // ---------- SCHOOL PROFILE ----------
  Future<void> loadSchoolProfile(SessionController session) async {
    final token = session.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _api.get(
      '/schools/me',
      token: token,
    );

    // ignore: avoid_print
    print('GET /schools/me -> $response');

    final profile = SchoolProfile.fromJson(response);
    session.setSchoolProfile(profile);
  }
}

