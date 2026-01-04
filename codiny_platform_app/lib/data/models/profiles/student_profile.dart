import '../../../core/enums/student_type.dart';

class StudentProfile {
  final String id;
  final StudentType studentType;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  
  // Onboarding fields
  final bool onboardingComplete;
  final String? accessMethod;
  final bool? paymentVerified;
  final String? subscriptionType;
  final String? subscriptionStatus;
  final String? schoolId;
  final String? schoolApprovalStatus;
  final bool? isActive;
  final String? accessLevel;
  final String? permitType; // 'A', 'B', or 'C'

  const StudentProfile({
    required this.id,
    required this.studentType,
    this.subscriptionStart,
    this.subscriptionEnd,
    this.onboardingComplete = false,
    this.accessMethod,
    this.paymentVerified,
    this.subscriptionType,
    this.subscriptionStatus,
    this.schoolId,
    this.schoolApprovalStatus,
    this.isActive,
    this.accessLevel,
    this.permitType,
  });

  // ---------- FROM JSON ----------
  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: (json['id'] ?? '').toString(),
      studentType: StudentTypeExtension.fromString(
        json['student_type'] ?? 'independent',
      ),
      subscriptionStart: json['subscription_start'] != null
          ? DateTime.parse(json['subscription_start'])
          : null,
      subscriptionEnd: json['subscription_end'] != null
          ? DateTime.parse(json['subscription_end'])
          : null,
      onboardingComplete: json['onboarding_complete'] ?? false,
      accessMethod: json['access_method'],
      paymentVerified: json['payment_verified'],
      subscriptionType: json['subscription_type'],
      subscriptionStatus: json['subscription_status'],
      schoolId: json['school_id'],
      schoolApprovalStatus: json['school_approval_status'],
      isActive: json['is_active'],
      accessLevel: json['access_level'],
      permitType: json['permit_type'],
    );
  }

  // ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_type': studentType.name,
      'subscription_start': subscriptionStart?.toIso8601String(),
      'subscription_end': subscriptionEnd?.toIso8601String(),
      'onboarding_complete': onboardingComplete,
      'access_method': accessMethod,
      'payment_verified': paymentVerified,
      'subscription_type': subscriptionType,
      'subscription_status': subscriptionStatus,
      'school_id': schoolId,
      'school_approval_status': schoolApprovalStatus,
      'is_active': isActive,
      'access_level': accessLevel,
      'permit_type': permitType,
    };
  }

  // ---------- HELPERS (OPTIONAL BUT USEFUL) ----------
  bool get hasActiveSubscription {
    if (subscriptionEnd == null) return false;
    return subscriptionEnd!.isAfter(DateTime.now());
  }
}

