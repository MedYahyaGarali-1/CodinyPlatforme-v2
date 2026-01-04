import '../profiles/student_profile.dart';

/// Student access control and onboarding state
class StudentAccess {
  final String accessLevel;
  final bool isActive;
  final bool canAccessCourses;
  final bool canAccessQcm;
  final bool canAccessVideos;
  final bool canAccessExams;
  final String? redirectTo;
  final String? message;
  final String? reason;

  const StudentAccess({
    required this.accessLevel,
    required this.isActive,
    required this.canAccessCourses,
    required this.canAccessQcm,
    required this.canAccessVideos,
    required this.canAccessExams,
    this.redirectTo,
    this.message,
    this.reason,
  });

  bool get needsOnboarding => redirectTo == 'onboarding';
  bool get needsPayment => redirectTo == 'payment';
  bool get hasFullAccess => accessLevel == 'full' && isActive;
  bool get hasLimitedAccess => accessLevel == 'limited';

  factory StudentAccess.fromJson(Map<String, dynamic> json) {
    return StudentAccess(
      accessLevel: json['access_level'] as String? ?? 'none',
      isActive: json['is_active'] as bool? ?? false,
      canAccessCourses: json['can_access_courses'] as bool? ?? false,
      canAccessQcm: json['can_access_qcm'] as bool? ?? false,
      canAccessVideos: json['can_access_videos'] as bool? ?? false,
      canAccessExams: json['can_access_exams'] as bool? ?? false,
      redirectTo: json['redirect_to'] as String?,
      message: json['message'] as String?,
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_level': accessLevel,
      'is_active': isActive,
      'can_access_courses': canAccessCourses,
      'can_access_qcm': canAccessQcm,
      'can_access_videos': canAccessVideos,
      'can_access_exams': canAccessExams,
      'redirect_to': redirectTo,
      'message': message,
      'reason': reason,
    };
  }
}

class AccessStatusResponse {
  final StudentProfile student;
  final StudentAccess access;

  const AccessStatusResponse({
    required this.student,
    required this.access,
  });

  factory AccessStatusResponse.fromJson(Map<String, dynamic> json) {
    return AccessStatusResponse(
      student: StudentProfile.fromJson(json['student'] as Map<String, dynamic>),
      access: StudentAccess.fromJson(json['access'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'access': access.toJson(),
    };
  }
}
