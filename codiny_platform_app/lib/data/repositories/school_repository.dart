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

  /// Get recent activity for school dashboard
  Future<List<SchoolActivity>> getRecentActivity({required String token}) async {
    final res = await _api.get('/schools/activity', token: token);
    if (res is List) {
      return res.map((e) => SchoolActivity.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('Unexpected response from /schools/activity: $res');
  }

  /// Get upcoming events for all students (next 7 days)
  Future<List<UpcomingEvent>> getUpcomingEvents({required String token}) async {
    final res = await _api.get('/schools/upcoming-events', token: token);
    if (res is List) {
      return res.map((e) => UpcomingEvent.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('Unexpected response from /schools/upcoming-events: $res');
  }

  /// Get comprehensive dashboard statistics
  Future<DashboardStats> getDashboardStats({required String token}) async {
    final res = await _api.get('/schools/dashboard-stats', token: token);
    if (res is Map) {
      return DashboardStats.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected response from /schools/dashboard-stats: $res');
  }
}

/// Model for dashboard statistics
class DashboardStats {
  final int totalStudents;
  final double totalEarned;
  final double totalOwed;
  final int passRate;
  final int examsThisMonth;
  final int passedThisMonth;

  DashboardStats({
    required this.totalStudents,
    required this.totalEarned,
    required this.totalOwed,
    required this.passRate,
    required this.examsThisMonth,
    required this.passedThisMonth,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalStudents: json['total_students'] as int? ?? 0,
      totalEarned: (json['total_earned'] as num?)?.toDouble() ?? 0,
      totalOwed: (json['total_owed'] as num?)?.toDouble() ?? 0,
      passRate: json['pass_rate'] as int? ?? 0,
      examsThisMonth: json['exams_this_month'] as int? ?? 0,
      passedThisMonth: json['passed_this_month'] as int? ?? 0,
    );
  }
}

/// Model for upcoming events
class UpcomingEvent {
  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? location;
  final String? notes;
  final String studentName;
  final String studentId;

  UpcomingEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    this.endsAt,
    this.location,
    this.notes,
    required this.studentName,
    required this.studentId,
  });

  factory UpcomingEvent.fromJson(Map<String, dynamic> json) {
    return UpcomingEvent(
      id: json['id'].toString(),
      title: json['title'] as String,
      startsAt: DateTime.parse(json['starts_at'] as String),
      endsAt: json['ends_at'] != null ? DateTime.parse(json['ends_at'] as String) : null,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      studentName: json['student_name'] as String,
      studentId: json['student_id'].toString(),
    );
  }
}

/// Model for school activity items
class SchoolActivity {
  final String type; // 'new_student', 'passed_exam', 'payment'
  final String studentName;
  final DateTime createdAt;
  final double? amount; // For payments
  final int? correctAnswers; // For exams
  final int? totalQuestions; // For exams

  SchoolActivity({
    required this.type,
    required this.studentName,
    required this.createdAt,
    this.amount,
    this.correctAnswers,
    this.totalQuestions,
  });

  factory SchoolActivity.fromJson(Map<String, dynamic> json) {
    return SchoolActivity(
      type: json['type'] as String,
      studentName: json['student_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      correctAnswers: json['correct_answers'] as int?,
      totalQuestions: json['total_questions'] as int?,
    );
  }
}
