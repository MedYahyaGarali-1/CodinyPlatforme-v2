import '../models/course_models.dart';

class CourseDataProvider {
  // Static list of courses with PDFs in assets
  static List<Course> getLocalCourses() {
    return [
      Course(
        id: '1',
        title: 'كود الطريق الكامل',
        description: 'الدليل الشامل الكامل لقانون المرور وقواعد القيادة - Code de la Route Complet',
        pdfPath: 'assets/courses/code_route_complet.pdf',
        thumbnailPath: 'assets/illustrations/empty_state.png',
        pageCount: 100,
        category: 'Code de la Route',
        isLocked: false,
      ),
      Course(
        id: '2',
        title: 'إشارات المرور',
        description: 'دليل شامل تفاعلي لجميع إشارات المرور وقواعد الطريق',
        pdfPath: 'interactive_traffic_signs', // Special marker for interactive content
        thumbnailPath: 'assets/illustrations/empty_state.png',
        pageCount: 30,
        category: 'Traffic Signs',
        isLocked: false,
      ),
    ];
  }

  // Check if PDF file exists in assets
  static bool isPdfAvailable(String pdfPath) {
    // This will be checked when trying to open the PDF
    // For now, we'll assume all PDFs are available if they're in the list
    return true;
  }
}
