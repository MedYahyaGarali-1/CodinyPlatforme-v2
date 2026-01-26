import '../../core/config/constants.dart';

/// Subscription helper service
/// Note: Activation is handled server-side only (security)
/// - Schools activate their students via POST /schools/students/activate
/// - Independent students are activated during onboarding
class SubscriptionService {
  /// Check if subscription is still active
  bool isActive(DateTime endDate, DateTime now) {
    return now.isBefore(endDate);
  }

  /// Remaining days (used by UI countdown)
  int remainingDays(DateTime endDate, DateTime now) {
    final diff = endDate.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Subscription duration in days (from constants)
  int get subscriptionDays => AppConstants.subscriptionDays;
}

