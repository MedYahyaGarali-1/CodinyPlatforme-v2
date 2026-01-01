import '../services/api_service.dart';
import '../../state/session/session_controller.dart';
import '../models/profiles/student_profile.dart';

class SubscriptionRepository {
  final ApiService _api;

  SubscriptionRepository({ApiService? api})
      : _api = api ?? ApiService();

  Future<void> activate(SessionController session) async {
    final token = session.token;
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final response = await _api.post(
      '/subscriptions/activate',
      token: token,
    );

    // Update only dates, keep student type
    final current = session.studentProfile;
    if (current == null) {
      throw Exception('Student profile not loaded');
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString());
    }

    final updatedProfile = StudentProfile(
      id: current.id,
      studentType: current.studentType,
      subscriptionStart: parseDate(response['subscription_start']),
      subscriptionEnd: parseDate(response['subscription_end']),
    );

    session.setStudentProfile(updatedProfile);
  }
}
