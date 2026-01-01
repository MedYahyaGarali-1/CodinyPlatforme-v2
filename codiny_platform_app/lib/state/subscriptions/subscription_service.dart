import '../../core/enums/student_type.dart';
import '../../core/enums/payment_source.dart';
import '../../core/config/constants.dart';

class SubscriptionResult {
  final DateTime startDate;
  final DateTime endDate;
  final int platformCut;
  final int schoolCut;

  const SubscriptionResult({
    required this.startDate,
    required this.endDate,
    required this.platformCut,
    required this.schoolCut,
  });
}   

class SubscriptionService {
  /// Activate a new subscription
  /// This is the ONLY place money rules exist
  SubscriptionResult activate({
    required StudentType studentType,
    required PaymentSource paymentSource,
    required DateTime now,
  }) {
    // 🔒 Rule: source and type MUST match
    if (studentType == StudentType.independent &&
        paymentSource != PaymentSource.independent) {
      throw Exception('Invalid payment source for independent student');
    }

    if (studentType == StudentType.school &&
        paymentSource != PaymentSource.school) {
      throw Exception('Invalid payment source for school student');
    }

    final startDate = now;
    final endDate = now.add(
      const Duration(days: AppConstants.subscriptionDays),
    );

    // 💰 Revenue split (LOCKED)
    final platformCut =
        studentType == StudentType.independent ? 50 : 30;

    final schoolCut =
        studentType == StudentType.school ? 20 : 0;

    return SubscriptionResult(
      startDate: startDate,
      endDate: endDate,
      platformCut: platformCut,
      schoolCut: schoolCut,
    );
  }

  /// Check if subscription is still active
  bool isActive(DateTime endDate, DateTime now) {
    return now.isBefore(endDate);
  }

  /// Remaining days (used by UI countdown)
  int remainingDays(DateTime endDate, DateTime now) {
    final diff = endDate.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }
}

