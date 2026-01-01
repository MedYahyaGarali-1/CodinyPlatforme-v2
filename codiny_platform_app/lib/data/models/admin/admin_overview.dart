class AdminOverview {
  final int totalStudents;
  final int totalSchools;
  final int monthlyRevenue;
  final int owedBySchools;

  const AdminOverview({
    required this.totalStudents,
    required this.totalSchools,
    required this.monthlyRevenue,
    required this.owedBySchools,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory AdminOverview.fromJson(Map<String, dynamic> json) {
    return AdminOverview(
      totalStudents: _asInt(json['totalStudents']),
      totalSchools: _asInt(json['totalSchools']),
      monthlyRevenue: _asInt(json['monthlyRevenue']),
      owedBySchools: _asInt(json['owedBySchools']),
    );
  }
}
