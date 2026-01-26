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

  Future<List<ExamResult>> getStudentExams({required String token, required String studentId}) async {
    final res = await _api.get('/schools/students/$studentId/exams', token: token);
    
    if (res is Map && res['success'] == true && res['exams'] is List) {
      final exams = res['exams'] as List;
      return exams.map((e) => ExamResult.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    
    throw Exception('Unexpected response from /schools/students/$studentId/exams: $res');
  }

  Future<List<ExamDetailedAnswer>> getExamAnswers({
    required String token,
    required String studentId,
    required String examId,
  }) async {
    final res = await _api.get(
      '/schools/students/$studentId/exams/$examId/answers',
      token: token,
    );
    
    if (res is Map && res['success'] == true && res['answers'] is List) {
      final answers = res['answers'] as List;
      return answers.map((e) => ExamDetailedAnswer.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    
    throw Exception('Unexpected response from /schools/students/$studentId/exams/$examId/answers: $res');
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

  /// Activate a student's subscription (30 days)
  /// School earns 20 DT, owes 30 DT to platform
  Future<void> activateStudent({required String token, required String studentId}) async {
    await _api.post(
      '/schools/students/activate',
      token: token,
      body: {'studentId': studentId},
    );
  }
}
