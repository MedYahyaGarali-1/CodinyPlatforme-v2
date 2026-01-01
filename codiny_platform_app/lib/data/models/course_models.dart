class Course {
  final String id;
  final String title;
  final String description;
  final String pdfPath;
  final String thumbnailPath;
  final int pageCount;
  final String category;
  final bool isLocked;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.pdfPath,
    required this.thumbnailPath,
    required this.pageCount,
    required this.category,
    this.isLocked = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      pdfPath: json['pdf_path'] ?? '',
      thumbnailPath: json['thumbnail_path'] ?? 'assets/illustrations/empty_state.png',
      pageCount: json['page_count'] ?? 0,
      category: json['category'] ?? 'General',
      isLocked: json['is_locked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pdf_path': pdfPath,
      'thumbnail_path': thumbnailPath,
      'page_count': pageCount,
      'category': category,
      'is_locked': isLocked,
    };
  }
}

class CourseProgress {
  final String courseId;
  final int currentPage;
  final int totalPages;
  final double progressPercentage;
  final DateTime lastAccessed;

  CourseProgress({
    required this.courseId,
    required this.currentPage,
    required this.totalPages,
    required this.progressPercentage,
    required this.lastAccessed,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['course_id'].toString(),
      currentPage: json['current_page'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
      lastAccessed: DateTime.parse(json['last_accessed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'current_page': currentPage,
      'total_pages': totalPages,
      'progress_percentage': progressPercentage,
      'last_accessed': lastAccessed.toIso8601String(),
    };
  }
}
