enum StudentType {
  independent,
  attached_to_school, // Backend uses "attached_to_school"
  school, // Keeping for backward compatibility
}

extension StudentTypeExtension on StudentType {
  static StudentType fromString(String value) {
    switch (value) {
      case 'independent':
        return StudentType.independent;
      case 'attached_to_school':
        return StudentType.attached_to_school;
      case 'school':
        return StudentType.school;
      default:
        return StudentType.independent; // Default fallback
    }
  }
  
  String get displayName {
    switch (this) {
      case StudentType.independent:
        return 'Independent';
      case StudentType.attached_to_school:
      case StudentType.school:
        return 'School Student';
    }
  }
}
