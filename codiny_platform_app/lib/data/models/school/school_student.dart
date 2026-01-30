class SchoolStudent {
  final String id;
  final String name;
  final String studentType;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final int totalExams;
  final int passedExams;
  final DateTime? lastExamAt;

  const SchoolStudent({
    required this.id,
    required this.name,
    required this.studentType,
    required this.subscriptionStart,
    required this.subscriptionEnd,
    this.totalExams = 0,
    this.passedExams = 0,
    this.lastExamAt,
  });

  bool get hasActiveSubscription {
    final end = subscriptionEnd;
    if (end == null) return false;
    return end.isAfter(DateTime.now());
  }

  /// Progress percentage based on passed exams
  int get progressPercent {
    if (totalExams == 0) return 0;
    return ((passedExams / totalExams) * 100).round();
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory SchoolStudent.fromJson(Map<String, dynamic> json) {
    return SchoolStudent(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      studentType: (json['student_type'] ?? json['studentType'] ?? '').toString(),
      subscriptionStart: _asDate(json['subscription_start'] ?? json['subscriptionStart']),
      subscriptionEnd: _asDate(json['subscription_end'] ?? json['subscriptionEnd']),
      totalExams: (json['total_exams'] as int?) ?? 0,
      passedExams: (json['passed_exams'] as int?) ?? 0,
      lastExamAt: _asDate(json['last_exam_at'] ?? json['lastExamAt']),
    );
  }
}
