import '../services/api_service.dart';
import '../models/course_models.dart';
import '../providers/course_data_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseRepository {
  final ApiService _api;

  CourseRepository({ApiService? api}) : _api = api ?? ApiService();

  // ---------- COURSES ----------
  Future<List<Course>> getCourses() async {
    // Try to get courses from API first, fallback to local courses
    try {
      final response = await _api.get('/courses');
      final coursesJson = response['courses'] as List?;
      if (coursesJson != null && coursesJson.isNotEmpty) {
        return coursesJson.map((json) => Course.fromJson(json)).toList();
      }
    } catch (e) {
      // If API fails, use local courses
      print('API failed, using local courses: $e');
    }
    
    // Return local courses from assets
    return CourseDataProvider.getLocalCourses();
  }

  // ---------- COURSE DETAILS ----------
  Future<Course?> getCourse(String courseId) async {
    try {
      final response = await _api.get('/courses/$courseId');
      return Course.fromJson(response);
    } catch (e) {
      // If API fails, get from local courses
      final courses = CourseDataProvider.getLocalCourses();
      return courses.firstWhere(
        (course) => course.id == courseId,
        orElse: () => courses.first,
      );
    }
  }

  // ---------- COURSE PROGRESS ----------
  Future<CourseProgress?> getCourseProgress(String courseId) async {
    try {
      final response = await _api.get('/courses/$courseId/progress');
      return CourseProgress.fromJson(response);
    } catch (e) {
      // If API fails, get from local storage
      return await _getLocalProgress(courseId);
    }
  }

  Future<void> updateCourseProgress({
    required String courseId,
    required int currentPage,
    required int totalPages,
  }) async {
    final progressPercentage = (currentPage / totalPages * 100).clamp(0.0, 100.0).toDouble();
    
    try {
      await _api.post(
        '/courses/$courseId/progress',
        body: {
          'current_page': currentPage,
          'total_pages': totalPages,
          'progress_percentage': progressPercentage,
        },
      );
    } catch (e) {
      // If API fails, save to local storage
      await _saveLocalProgress(
        courseId: courseId,
        currentPage: currentPage,
        totalPages: totalPages,
        progressPercentage: progressPercentage,
      );
    }
  }

  // Local storage helpers
  Future<CourseProgress?> _getLocalProgress(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentPage = prefs.getInt('course_${courseId}_page') ?? 0;
      final totalPages = prefs.getInt('course_${courseId}_total') ?? 0;
      final progress = prefs.getDouble('course_${courseId}_progress') ?? 0.0;
      final lastAccessed = prefs.getString('course_${courseId}_last_accessed');

      if (currentPage > 0) {
        return CourseProgress(
          courseId: courseId,
          currentPage: currentPage,
          totalPages: totalPages,
          progressPercentage: progress,
          lastAccessed: lastAccessed != null 
              ? DateTime.parse(lastAccessed)
              : DateTime.now(),
        );
      }
    } catch (e) {
      print('Error getting local progress: $e');
    }
    return null;
  }

  Future<void> _saveLocalProgress({
    required String courseId,
    required int currentPage,
    required int totalPages,
    required double progressPercentage,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('course_${courseId}_page', currentPage);
      await prefs.setInt('course_${courseId}_total', totalPages);
      await prefs.setDouble('course_${courseId}_progress', progressPercentage);
      await prefs.setString(
        'course_${courseId}_last_accessed',
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error saving local progress: $e');
    }
  }

  // ---------- EXAMS ----------
  Future<List<dynamic>> getExamQuestions() async {
    final response = await _api.get('/exams/questions');
    return response['questions'] ?? [];
  }
}
