class SchoolProfile {
  final String id;
  final String name;
  final int students;
  final int earned;
  final int owed;
  final bool active;

  SchoolProfile({
    required this.id,
    required this.name,
    required this.students,
    required this.earned,
    required this.owed,
    required this.active,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is num) return v != 0;
    return false;
  }

  static String _asString(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  factory SchoolProfile.fromJson(Map<String, dynamic> json) {
    // Backend keys (current): total_students, total_earned, total_owed_to_platform
    // Legacy keys (older app code): students, earned, owed
    final students = json.containsKey('students') ? json['students'] : json['total_students'];
    final earned = json.containsKey('earned') ? json['earned'] : json['total_earned'];
    final owed = json.containsKey('owed') ? json['owed'] : json['total_owed_to_platform'];

    return SchoolProfile(
      id: _asString(json['id']),
      name: (json['name'] ?? '').toString(),
      students: _asInt(students),
      earned: _asInt(earned),
      owed: _asInt(owed),
      active: _asBool(json['active'] ?? json['is_active']),
    );
  }
}


