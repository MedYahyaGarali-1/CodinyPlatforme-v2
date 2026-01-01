class AdminStudent {
  final String id;
  final String name;
  final String type; // independent/school/etc (comes from backend)
  final String? school;
  final String status; // Active/Expired
  final int daysLeft;

  const AdminStudent({
    required this.id,
    required this.name,
    required this.type,
    required this.school,
    required this.status,
    required this.daysLeft,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory AdminStudent.fromJson(Map<String, dynamic> json) {
    return AdminStudent(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      school: json['school']?.toString(),
      status: (json['status'] ?? '').toString(),
      daysLeft: _asInt(json['daysLeft']),
    );
  }
}
