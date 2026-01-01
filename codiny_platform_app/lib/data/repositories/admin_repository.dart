import '../services/api_service.dart';
import '../models/profiles/school_profile.dart';
import '../models/admin/admin_overview.dart';
import '../models/admin/admin_student.dart';

class AdminRepository {
  final ApiService _api;

  AdminRepository({ApiService? api}) : _api = api ?? ApiService();

  // =========================
  // 📊 OVERVIEW
  // =========================

  Future<AdminOverview> getAdminOverview({String? token}) async {
    final response = await _api.get('/admin/overview', token: token);
    if (response is Map) {
      return AdminOverview.fromJson(Map<String, dynamic>.from(response));
    }
    throw Exception('Unexpected response from /admin/overview: $response');
  }

  // =========================
  // 🏫 SCHOOLS
  // =========================

  Future<List<SchoolProfile>> getSchools({String? token}) async {
    final response = await _api.get('/admin/schools', token: token);
    if (response is List) {
      return response
          .map((json) => SchoolProfile.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    throw Exception('Unexpected response from /admin/schools: $response');
  }

  Future<SchoolProfile> getSchoolDetails(String schoolId, {String? token}) async {
    final response = await _api.get('/admin/schools/$schoolId', token: token);
    if (response is Map) {
      return SchoolProfile.fromJson(Map<String, dynamic>.from(response));
    }
    throw Exception('Failed to load school details: $response');
  }

  Future<void> blockSchool(String schoolId, {String? token}) async {
    await _api.post('/admin/schools/$schoolId/block', token: token);
  }

  Future<void> unblockSchool(String schoolId, {String? token}) async {
    await _api.post('/admin/schools/$schoolId/unblock', token: token);
  }

  // =========================
  // ➕ CREATE SCHOOL (NEW)
  // =========================
  Future<void> createSchool({
    required String name,
    required String identifier,
    required String password,
    String? token,
  }) async {
    await _api.post(
      '/admin/create-school',
      token: token,
      body: {
        'name': name.trim(),
        'identifier': identifier.trim().toLowerCase(),
        'password': password,
      },
    );
  }

  // =========================
  // 👥 STUDENTS
  // =========================
  Future<List<AdminStudent>> getAllStudents({String? token}) async {
    final response = await _api.get('/admin/students', token: token);
    if (response is List) {
      return response
          .map((e) => AdminStudent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Unexpected response from /admin/students: $response');
  }

  Future<AdminStudent> getStudentDetails(String studentId, {String? token}) async {
    final response = await _api.get('/admin/students/$studentId', token: token);
    if (response is Map) {
      return AdminStudent.fromJson(Map<String, dynamic>.from(response));
    }
    throw Exception('Unexpected response from /admin/students/$studentId: $response');
  }

  // =========================
  // 💰 FINANCE
  // =========================
  Future<Map<String, dynamic>> getFinanceOverview({String? token}) async {
    final response = await _api.get('/admin/finance', token: token);
    return Map<String, dynamic>.from(response as Map);
  }
}

