import '../services/api_service.dart';
import '../models/school/school_student.dart';
import '../models/school/student_event.dart';
import '../models/exam/exam_models.dart';

class SchoolRepository {
  final ApiService _api;

  SchoolRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<SchoolStudent>> getStudents({required String token}) async {
    final res = await _api.get('/schools/students', token: token);
    if (res is List) {
      return res.map((e) => SchoolStudent.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('Unexpected response from /schools/students: $res');
  }

  Future<void> attachStudent({required String token, required String studentId}) async {
    await _api.post(
      '/schools/students/attach',
      token: token,
      body: {'studentId': studentId},
    );
  }

  Future<void> detachStudent({required String token, required String studentId}) async {
    await _api.post(
      '/schools/students/$studentId/detach',
      token: token,
    );
  }

  Future<List<ExamResult>> getStudentExamHistory({
    required String token,
    required String studentId,
  }) async {
    final res = await _api.get('/schools/students/$studentId/exams', token: token);
    if (res is Map && res['success'] == true && res['exams'] is List) {
      return (res['exams'] as List)
          .map((e) => ExamResult.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to fetch student exam history');
  }

  Future<List<StudentEvent>> getStudentEvents({required String token, required String studentId}) async {
    final res = await _api.get('/schools/students/$studentId/events', token: token);
    if (res is List) {
      return res.map((e) => StudentEvent.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('Unexpected response from /schools/students/$studentId/events: $res');
  }

  Future<void> createStudentEvent({
    required String token,
    required String studentId,
    required StudentEvent event,
  }) async {
    await _api.post(
      '/schools/students/$studentId/events',
      token: token,
      body: event.toCreateJson(),
    );
  }

  Future<void> deleteEvent({required String token, required String eventId}) async {
    await _api.post(
      '/schools/events/$eventId/delete',
      token: token,
    );
  }
}