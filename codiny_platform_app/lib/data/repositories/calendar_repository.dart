import '../services/api_service.dart';
import '../models/school/student_event.dart';

class CalendarRepository {
  final ApiService _api;

  CalendarRepository({ApiService? api}) : _api = api ?? ApiService();

  // School: Get events for a specific student
  Future<List<StudentEvent>> getStudentEvents({
    required String studentId,
    required String token,
  }) async {
    final data = await _api.get(
      '/schools/students/$studentId/events',
      token: token,
    );
    return (data as List).map((e) => StudentEvent.fromJson(e)).toList();
  }

  // School: Create event for a student
  Future<String> createEvent({
    required String studentId,
    required String title,
    required DateTime startsAt,
    DateTime? endsAt,
    String? location,
    String? notes,
    required String token,
  }) async {
    final result = await _api.post(
      '/schools/students/$studentId/events',
      token: token,
      body: {
        'title': title,
        'starts_at': startsAt.toIso8601String(),
        'ends_at': endsAt?.toIso8601String(),
        'location': location,
        'notes': notes,
      },
    );
    return (result['id'] ?? '').toString();
  }

  // School: Delete event
  Future<void> deleteEvent({
    required String eventId,
    required String token,
  }) async {
    await _api.post(
      '/schools/events/$eventId/delete',
      token: token,
    );
  }

  // Student: Get my events
  Future<List<StudentEvent>> getMyEvents({
    required String token,
  }) async {
    final data = await _api.get(
      '/students/events',
      token: token,
    );
    return (data as List).map((e) => StudentEvent.fromJson(e)).toList();
  }
}
