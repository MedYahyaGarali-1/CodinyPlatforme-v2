class StudentEvent {
  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? location;
  final String? notes;

  const StudentEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.location,
    required this.notes,
  });

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    return DateTime.tryParse(v.toString());
  }

  factory StudentEvent.fromJson(Map<String, dynamic> json) {
    return StudentEvent(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      startsAt: _asDate(json['starts_at'] ?? json['startsAt']) ?? DateTime.now(),
      endsAt: _asDate(json['ends_at'] ?? json['endsAt']),
      location: json['location']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'starts_at': startsAt.toIso8601String(),
      'ends_at': endsAt?.toIso8601String(),
      'location': location,
      'notes': notes,
    };
  }

  // Helper methods for calendar display
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(startsAt.year, startsAt.month, startsAt.day);
    return today == eventDate;
  }

  bool get isUpcoming {
    return startsAt.isAfter(DateTime.now());
  }

  bool get isPast {
    return startsAt.isBefore(DateTime.now());
  }

  String get formattedDate {
    final now = DateTime.now();
    final eventDate = DateTime(startsAt.year, startsAt.month, startsAt.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = eventDate.difference(today).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    
    return '${startsAt.day}/${startsAt.month}/${startsAt.year}';
  }

  String get formattedTime {
    final hour = startsAt.hour.toString().padLeft(2, '0');
    final minute = startsAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDateLong {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${startsAt.day} ${months[startsAt.month - 1]} ${startsAt.year}';
  }
}
