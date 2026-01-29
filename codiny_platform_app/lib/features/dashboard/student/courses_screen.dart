import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/access_guard.dart';
import '../../../shared/ui/staggered_animation.dart';
import '../../../data/repositories/course_repository.dart';
import '../../../data/models/course_models.dart';
import '../../courses/screens/course_detail_screen.dart';
import '../../courses/screens/traffic_signs_viewer_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with TickerProviderStateMixin, StaggeredAnimationMixin {
  List<Course> _courses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    initAnimations(sectionCount: 10); // Support up to 10 course cards
    _loadCourses();
  }

  @override
  void dispose() {
    disposeAnimations();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final repository = Provider.of<CourseRepository>(context, listen: false);
      final courses = await repository.getCourses();

      setState(() {
        _courses = courses;
        _isLoading = false;
      });
      
      // Start animations after data loads
      startAnimations();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AccessGuard(
      requiresFullAccess: true,
      featureName: 'courses',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6C63FF),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1D1E33),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadCourses,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد دروس متاحة حالياً',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1D1E33),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'سيتم إضافة الدروس قريباً',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1a1a2e),
                  const Color(0xFF16213e),
                  const Color(0xFF0f0f1a),
                ]
              : [
                  Colors.blue.shade50.withOpacity(0.5),
                  Colors.purple.shade50.withOpacity(0.3),
                  Theme.of(context).colorScheme.surface,
                ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: RefreshIndicator(
        onRefresh: _loadCourses,
        color: const Color(0xFF6C63FF),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          itemCount: _courses.length,
          itemBuilder: (context, index) {
            final course = _courses[index];
            return buildAnimatedSection(index, _buildCourseCard(course, isDark, index));
          },
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course, bool isDark, int index) {
    // Different gradients for different course types
    final bool isTrafficSigns = course.pdfPath == 'interactive_traffic_signs';
    
    final List<Color> cardGradient = isTrafficSigns
        ? [const Color(0xFF11998e), const Color(0xFF38ef7d)] // Green-teal for traffic signs
        : [const Color(0xFF667eea), const Color(0xFF764ba2)]; // Blue-purple for PDF
    
    final IconData courseIcon = course.isLocked
        ? Icons.lock_rounded
        : isTrafficSigns
            ? Icons.traffic_rounded
            : Icons.menu_book_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardGradient[0].withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -15,
            bottom: -15,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          // Main content
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: course.isLocked
                  ? null
                  : () {
                      if (isTrafficSigns) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrafficSignsViewerScreen(),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailScreen(course: course),
                          ),
                        );
                      }
                    },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Chevron on the left (for RTL)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content in the middle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Title
                          Text(
                            course.title,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Description
                          Text(
                            course.description,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.85),
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          // Metadata chips
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildMetaChip(
                                Icons.description_outlined,
                                '${course.pageCount} صفحة',
                              ),
                              const SizedBox(width: 8),
                              _buildMetaChip(
                                Icons.category_outlined,
                                course.category,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Icon on the right (for RTL)
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        courseIcon,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
