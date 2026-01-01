class SchoolStudent {
  final String id;
  final String name;
  final String studentType;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;

  const SchoolStudent({
    required this.id,
    required this.name,
    required this.studentType,
    required this.subscriptionStart,
    required this.subscriptionEnd,
  });

  bool get hasActiveSubscription {
    final end = subscriptionEnd;
    if (end == null) return false;
    return end.isAfter(DateTime.now());
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
    );
  }
}
