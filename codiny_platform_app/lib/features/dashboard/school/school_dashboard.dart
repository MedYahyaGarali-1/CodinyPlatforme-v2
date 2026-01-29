import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/layout/dashboard_shell.dart';
import '../../../state/session/session_controller.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/school_repository.dart';
import 'attach_student_screen.dart';
import 'school_students_screen.dart';
import 'student_calendars_screen.dart';
import 'track_student_progress_screen.dart';
import 'financial_reports_screen.dart';
import '../../../shared/widgets/revenue_stats_widget.dart';

// Language enum for dashboard
enum DashboardLanguage { english, french, arabic }

// Translations map
class DashboardTranslations {
  static Map<String, Map<DashboardLanguage, String>> translations = {
    'schoolDashboard': {
      DashboardLanguage.english: 'School Dashboard',
      DashboardLanguage.french: 'Tableau de Bord École',
      DashboardLanguage.arabic: 'لوحة تحكم المدرسة',
    },
    'manageStudents': {
      DashboardLanguage.english: 'Manage students and track performance',
      DashboardLanguage.french: 'Gérer les étudiants et suivre les performances',
      DashboardLanguage.arabic: 'إدارة الطلاب ومتابعة الأداء',
    },
    'overview': {
      DashboardLanguage.english: 'Overview',
      DashboardLanguage.french: 'Aperçu',
      DashboardLanguage.arabic: 'نظرة عامة',
    },
    'metricsGlance': {
      DashboardLanguage.english: 'Your school metrics at a glance',
      DashboardLanguage.french: 'Vos métriques scolaires en un coup d\'œil',
      DashboardLanguage.arabic: 'إحصائيات مدرستك بنظرة سريعة',
    },
    'totalStudents': {
      DashboardLanguage.english: 'Students',
      DashboardLanguage.french: 'Étudiants',
      DashboardLanguage.arabic: 'الطلاب',
    },
    'yourEarnings': {
      DashboardLanguage.english: 'Earnings',
      DashboardLanguage.french: 'Revenus',
      DashboardLanguage.arabic: 'أرباحك',
    },
    'platformShare': {
      DashboardLanguage.english: 'Platform',
      DashboardLanguage.french: 'Plateforme',
      DashboardLanguage.arabic: 'المنصة',
    },
    'totalRevenue': {
      DashboardLanguage.english: 'Revenue',
      DashboardLanguage.french: 'Total',
      DashboardLanguage.arabic: 'الإيرادات',
    },
    'studentManagement': {
      DashboardLanguage.english: 'Student Management',
      DashboardLanguage.french: 'Gestion des Étudiants',
      DashboardLanguage.arabic: 'إدارة الطلاب',
    },
    'manageEfficiently': {
      DashboardLanguage.english: 'Manage your students efficiently',
      DashboardLanguage.french: 'Gérez vos étudiants efficacement',
      DashboardLanguage.arabic: 'أدر طلابك بكفاءة',
    },
    'viewAllStudents': {
      DashboardLanguage.english: 'View All Students',
      DashboardLanguage.french: 'Voir Tous les Étudiants',
      DashboardLanguage.arabic: 'عرض جميع الطلاب',
    },
    'viewAllStudentsDesc': {
      DashboardLanguage.english: 'See all students and their subscription status',
      DashboardLanguage.french: 'Voir tous les étudiants et leur statut d\'abonnement',
      DashboardLanguage.arabic: 'عرض جميع الطلاب وحالة اشتراكهم',
    },
    'addNewStudent': {
      DashboardLanguage.english: 'Add New Student',
      DashboardLanguage.french: 'Ajouter un Étudiant',
      DashboardLanguage.arabic: 'إضافة طالب جديد',
    },
    'addNewStudentDesc': {
      DashboardLanguage.english: 'Attach an existing student account to your school',
      DashboardLanguage.french: 'Associer un compte étudiant existant à votre école',
      DashboardLanguage.arabic: 'ربط حساب طالب موجود بمدرستك',
    },
    'studentCalendars': {
      DashboardLanguage.english: 'Student Calendars',
      DashboardLanguage.french: 'Calendriers Étudiants',
      DashboardLanguage.arabic: 'تقويم الطلاب',
    },
    'studentCalendarsDesc': {
      DashboardLanguage.english: 'Schedule lessons, exams, and appointments',
      DashboardLanguage.french: 'Planifier les cours, examens et rendez-vous',
      DashboardLanguage.arabic: 'جدولة الدروس والاختبارات والمواعيد',
    },
    'trackProgress': {
      DashboardLanguage.english: 'Track Progress',
      DashboardLanguage.french: 'Suivre les Progrès',
      DashboardLanguage.arabic: 'متابعة التقدم',
    },
    'trackProgressDesc': {
      DashboardLanguage.english: 'View test results and learning progress',
      DashboardLanguage.french: 'Voir les résultats des tests et les progrès d\'apprentissage',
      DashboardLanguage.arabic: 'عرض نتائج الاختبارات وتقدم التعلم',
    },
    'reportsAnalytics': {
      DashboardLanguage.english: 'Reports & Analytics',
      DashboardLanguage.french: 'Rapports & Analyses',
      DashboardLanguage.arabic: 'التقارير والتحليلات',
    },
    'financialInsights': {
      DashboardLanguage.english: 'Financial and performance insights',
      DashboardLanguage.french: 'Informations financières et de performance',
      DashboardLanguage.arabic: 'رؤى مالية وأداء',
    },
    'financialReports': {
      DashboardLanguage.english: 'Financial Reports',
      DashboardLanguage.french: 'Rapports Financiers',
      DashboardLanguage.arabic: 'التقارير المالية',
    },
    'financialReportsDesc': {
      DashboardLanguage.english: 'View earnings, payments, and revenue history',
      DashboardLanguage.french: 'Voir les gains, paiements et historique des revenus',
      DashboardLanguage.arabic: 'عرض الأرباح والمدفوعات وسجل الإيرادات',
    },
    'refresh': {
      DashboardLanguage.english: 'Refresh',
      DashboardLanguage.french: 'Actualiser',
      DashboardLanguage.arabic: 'تحديث',
    },
    'quickStats': {
      DashboardLanguage.english: 'Quick Stats',
      DashboardLanguage.french: 'Statistiques Rapides',
      DashboardLanguage.arabic: 'إحصائيات سريعة',
    },
    'recentActivity': {
      DashboardLanguage.english: 'Recent Activity',
      DashboardLanguage.french: 'Activité Récente',
      DashboardLanguage.arabic: 'النشاط الأخير',
    },
    'latestUpdates': {
      DashboardLanguage.english: 'Latest updates from your school',
      DashboardLanguage.french: 'Dernières mises à jour de votre école',
      DashboardLanguage.arabic: 'آخر التحديثات من مدرستك',
    },
    'searchStudents': {
      DashboardLanguage.english: 'Search students...',
      DashboardLanguage.french: 'Rechercher des étudiants...',
      DashboardLanguage.arabic: 'البحث عن الطلاب...',
    },
    'passRate': {
      DashboardLanguage.english: 'Pass Rate',
      DashboardLanguage.french: 'Taux de Réussite',
      DashboardLanguage.arabic: 'نسبة النجاح',
    },
    'noActivity': {
      DashboardLanguage.english: 'No recent activity',
      DashboardLanguage.french: 'Aucune activité récente',
      DashboardLanguage.arabic: 'لا يوجد نشاط حديث',
    },
    'exportData': {
      DashboardLanguage.english: 'Export Data',
      DashboardLanguage.french: 'Exporter les Données',
      DashboardLanguage.arabic: 'تصدير البيانات',
    },
    'exportDesc': {
      DashboardLanguage.english: 'Download student list and reports',
      DashboardLanguage.french: 'Télécharger la liste des étudiants et les rapports',
      DashboardLanguage.arabic: 'تحميل قائمة الطلاب والتقارير',
    },
    'viewAll': {
      DashboardLanguage.english: 'View all',
      DashboardLanguage.french: 'Voir tout',
      DashboardLanguage.arabic: 'عرض الكل',
    },
    'newStudentJoined': {
      DashboardLanguage.english: 'New student joined',
      DashboardLanguage.french: 'Nouvel étudiant inscrit',
      DashboardLanguage.arabic: 'طالب جديد انضم',
    },
    'passedExam': {
      DashboardLanguage.english: 'Passed exam',
      DashboardLanguage.french: 'Examen réussi',
      DashboardLanguage.arabic: 'نجح في الاختبار',
    },
    'newPayment': {
      DashboardLanguage.english: 'New payment',
      DashboardLanguage.french: 'Nouveau paiement',
      DashboardLanguage.arabic: 'دفعة جديدة',
    },
    'hoursAgo': {
      DashboardLanguage.english: 'h ago',
      DashboardLanguage.french: 'h',
      DashboardLanguage.arabic: 'منذ س',
    },
    'yesterday': {
      DashboardLanguage.english: 'Yesterday',
      DashboardLanguage.french: 'Hier',
      DashboardLanguage.arabic: 'أمس',
    },
  };

  static String get(String key, DashboardLanguage lang) {
    return translations[key]?[lang] ?? key;
  }
}

class SchoolDashboard extends StatelessWidget {
  const SchoolDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardShell(
      showLogout: true,
      showThemeToggle: true,
      tabs: [
        DashboardTab(
          label: 'Home',
          icon: Icons.home,
          body: _SchoolHomeLoader(),
        ),
      ],
    );
  }
}

class _SchoolHomeLoader extends StatefulWidget {
  const _SchoolHomeLoader();

  @override
  State<_SchoolHomeLoader> createState() => _SchoolHomeLoaderState();
}

class _SchoolHomeLoaderState extends State<_SchoolHomeLoader> {
  late Future<void> _load;
  DashboardLanguage _language = DashboardLanguage.english;

  @override
  void initState() {
    super.initState();
    _load = _loadProfile();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final langIndex = prefs.getInt('dashboard_language') ?? 0;
    if (mounted) {
      setState(() {
        _language = DashboardLanguage.values[langIndex];
      });
    }
  }

  Future<void> _saveLanguagePreference(DashboardLanguage lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dashboard_language', lang.index);
  }

  void _changeLanguage(DashboardLanguage lang) {
    setState(() {
      _language = lang;
    });
    _saveLanguagePreference(lang);
  }

  Future<void> _loadProfile() async {
    final session = context.read<SessionController>();
    final repo = UserRepository();
    await repo.loadSchoolProfile(session);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _load,
      builder: (context, snap) {
        final session = context.watch<SessionController>();
        final profile = session.schoolProfile;

        if (snap.connectionState == ConnectionState.waiting && profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError && profile == null) {
          return Center(
            child: Text(
              'Failed to load profile\n${snap.error}',
              textAlign: TextAlign.center,
            ),
          );
        }

        return SchoolHomeScreen(
          students: profile?.students ?? 0,
          earned: profile?.earned ?? 0,
          owed: profile?.owed ?? 0,
          language: _language,
          onLanguageChanged: _changeLanguage,
          onRefresh: () {
            if (mounted) {
              setState(() {
                _load = _loadProfile();
              });
            }
          },
        );
      },
    );
  }
}

class SchoolHomeScreen extends StatelessWidget {
  final int students;
  final int earned;
  final int owed;
  final DashboardLanguage language;
  final Function(DashboardLanguage) onLanguageChanged;
  final VoidCallback onRefresh;

  const SchoolHomeScreen({
    super.key,
    required this.students,
    required this.earned,
    required this.owed,
    required this.language,
    required this.onLanguageChanged,
    required this.onRefresh,
  });

  String tr(String key) => DashboardTranslations.get(key, language);
  bool get isRTL => language == DashboardLanguage.arabic;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalRevenue = earned + owed;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: RefreshIndicator(
        onRefresh: () async {
          onRefresh();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Language Selector
            _buildLanguageSelector(context, isDark),
            const SizedBox(height: 16),

            // Welcome Header with Gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primary,
                    cs.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (!isRTL) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              tr('schoolDashboard'),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tr('manageStudents'),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isRTL) ...[
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: onRefresh,
                        tooltip: tr('refresh'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader(context, tr('overview'), tr('metricsGlance'), isDark),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _EnhancedStatCard(
                  title: tr('totalStudents'),
                  value: '$students',
                  icon: Icons.people_rounded,
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  trend: '+12%',
                  trendUp: true,
                  isRTL: isRTL,
                ),
                _EnhancedStatCard(
                  title: tr('yourEarnings'),
                  value: '$earned TND',
                  icon: Icons.payments_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  trend: '+8%',
                  trendUp: true,
                  isRTL: isRTL,
                ),
                _EnhancedStatCard(
                  title: tr('platformShare'),
                  value: '$owed TND',
                  icon: Icons.account_balance_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  isRTL: isRTL,
                ),
                _EnhancedStatCard(
                  title: tr('totalRevenue'),
                  value: '$totalRevenue TND',
                  icon: Icons.trending_up_rounded,
                  gradient: LinearGradient(
                    colors: [cs.secondary, cs.secondary.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  isRTL: isRTL,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Revenue Stats Widget
            Builder(
              builder: (context) {
                final session = context.watch<SessionController>();
                final schoolId = session.schoolProfile?.id;
                
                if (schoolId != null) {
                  return RevenueStatsWidget(
                    token: session.token ?? '',
                    schoolId: schoolId,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 24),

            // Recent Activity Feed (real data from backend)
            _buildRecentActivitySection(context, isDark),

            const SizedBox(height: 28),

            _buildSectionHeader(context, tr('studentManagement'), tr('manageEfficiently'), isDark),
            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(context, isDark),
            const SizedBox(height: 16),

            _EnhancedActionCard(
              label: tr('viewAllStudents'),
              icon: Icons.people_rounded,
              description: tr('viewAllStudentsDesc'),
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.primaryContainer.withOpacity(0.5)],
              ),
              iconColor: cs.primary,
              isRTL: isRTL,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SchoolStudentsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _EnhancedActionCard(
              label: tr('addNewStudent'),
              icon: Icons.person_add_rounded,
              description: tr('addNewStudentDesc'),
              gradient: const LinearGradient(
                colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
              ),
              iconColor: const Color(0xFF10B981),
              isRTL: isRTL,
              onTap: () async {
                final ok = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AttachStudentScreen()),
                );
                if (ok == true) onRefresh();
              },
            ),
            const SizedBox(height: 12),

            _EnhancedActionCard(
              label: tr('studentCalendars'),
              icon: Icons.calendar_month_rounded,
              description: tr('studentCalendarsDesc'),
              gradient: const LinearGradient(
                colors: [Color(0xFFDDD6FE), Color(0xFFC4B5FD)],
              ),
              iconColor: const Color(0xFF8B5CF6),
              isRTL: isRTL,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentCalendarsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),

            _EnhancedActionCard(
              label: tr('trackProgress'),
              icon: Icons.assessment_rounded,
              description: tr('trackProgressDesc'),
              gradient: const LinearGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
              ),
              iconColor: const Color(0xFFF59E0B),
              isRTL: isRTL,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrackStudentProgressScreen()),
                );
              },
            ),

            const SizedBox(height: 28),

            _buildSectionHeader(context, tr('reportsAnalytics'), tr('financialInsights'), isDark),
            const SizedBox(height: 16),

            _EnhancedActionCard(
              label: tr('financialReports'),
              icon: Icons.receipt_long_rounded,
              description: tr('financialReportsDesc'),
              gradient: const LinearGradient(
                colors: [Color(0xFFBFDBFE), Color(0xFF93C5FD)],
              ),
              iconColor: const Color(0xFF3B82F6),
              isRTL: isRTL,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FinancialReportsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLanguageOption(
            context,
            'EN',
            '🇬🇧',
            DashboardLanguage.english,
            isDark,
          ),
          const SizedBox(width: 8),
          _buildLanguageOption(
            context,
            'FR',
            '🇫🇷',
            DashboardLanguage.french,
            isDark,
          ),
          const SizedBox(width: 8),
          _buildLanguageOption(
            context,
            'AR',
            '🇹🇳',
            DashboardLanguage.arabic,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String flag,
    DashboardLanguage lang,
    bool isDark,
  ) {
    final isSelected = language == lang;
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () => onLanguageChanged(lang),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primary
                : (isDark ? Colors.transparent : Colors.white),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
              Text(
                code,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.grey[700]),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle, bool isDark) {
    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white60 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Recent Activity Section - Fetches real data from backend
  Widget _buildRecentActivitySection(BuildContext context, bool isDark) {
    final session = context.read<SessionController>();
    final token = session.token ?? '';
    final repo = SchoolRepository();

    // Helper function to format time ago
    String formatTimeAgo(DateTime date) {
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 60) {
        final mins = diff.inMinutes;
        return isRTL ? 'منذ $mins د' : 
               language == DashboardLanguage.french ? 'Il y a ${mins}m' : 
               '${mins}m ago';
      } else if (diff.inHours < 24) {
        final hours = diff.inHours;
        return isRTL ? 'منذ $hours س' : 
               language == DashboardLanguage.french ? 'Il y a ${hours}h' : 
               '${hours}h ago';
      } else if (diff.inDays == 1) {
        return tr('yesterday');
      } else {
        final days = diff.inDays;
        return isRTL ? 'منذ $days يوم' : 
               language == DashboardLanguage.french ? 'Il y a ${days}j' : 
               '${days}d ago';
      }
    }

    // Convert backend activity to display item
    _ActivityItem convertActivity(SchoolActivity activity) {
      switch (activity.type) {
        case 'new_student':
          return _ActivityItem(
            icon: Icons.person_add,
            color: const Color(0xFF10B981),
            title: tr('newStudentJoined'),
            subtitle: activity.studentName,
            time: formatTimeAgo(activity.createdAt),
          );
        case 'passed_exam':
          return _ActivityItem(
            icon: Icons.check_circle,
            color: const Color(0xFF3B82F6),
            title: tr('passedExam'),
            subtitle: activity.studentName,
            time: formatTimeAgo(activity.createdAt),
          );
        case 'payment':
          return _ActivityItem(
            icon: Icons.payment,
            color: const Color(0xFFF59E0B),
            title: tr('newPayment'),
            subtitle: '${activity.amount?.toStringAsFixed(0) ?? '0'} TND - ${activity.studentName}',
            time: formatTimeAgo(activity.createdAt),
          );
        default:
          return _ActivityItem(
            icon: Icons.info,
            color: Colors.grey,
            title: activity.type,
            subtitle: activity.studentName,
            time: formatTimeAgo(activity.createdAt),
          );
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isRTL) ...[
                Text(
                  tr('recentActivity'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SchoolStudentsScreen()),
                    );
                  },
                  child: Text(
                    tr('viewAll'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ] else ...[
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SchoolStudentsScreen()),
                    );
                  },
                  child: Text(
                    tr('viewAll'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  tr('recentActivity'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          // Fetch real activity data
          FutureBuilder<List<SchoolActivity>>(
            future: token.isNotEmpty ? repo.getRecentActivity(token: token) : Future.value([]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      tr('noActivity'),
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }
              
              final activities = snapshot.data ?? [];
              
              if (activities.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: isDark ? Colors.white24 : Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr('noActivity'),
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return Column(
                children: activities
                    .map((a) => convertActivity(a))
                    .map((activity) => _buildActivityItem(activity, isDark))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(_ActivityItem activity, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (!isRTL)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(activity.icon, color: activity.color, size: 20),
            ),
          if (!isRTL) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  activity.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isRTL) const SizedBox(width: 12),
          if (isRTL)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activity.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(activity.icon, color: activity.color, size: 20),
            ),
          if (!isRTL) ...[
            const SizedBox(width: 8),
            Text(
              activity.time,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Search Bar
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: TextField(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        decoration: InputDecoration(
          hintText: tr('searchStudents'),
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white38 : Colors.grey[500],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SchoolStudentsScreen(),
              ),
            );
          }
        },
      ),
    );
  }
}

// Activity Item Model
class _ActivityItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  _ActivityItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

// Enhanced Stat Card Widget - Fixed overflow
class _EnhancedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final String? trend;
  final bool trendUp;
  final bool isRTL;

  const _EnhancedStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.trend,
    this.trendUp = true,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isRTL)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    if (trend != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trendUp ? Icons.trending_up : Icons.trending_down,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              trend!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isRTL)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Enhanced Action Card Widget
class _EnhancedActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final Gradient gradient;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isRTL;

  const _EnhancedActionCard({
    required this.label,
    required this.icon,
    required this.description,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
    this.isRTL = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isRTL)
                  Icon(
                    Icons.arrow_back_ios_rounded,
                    size: 18,
                    color: Colors.black38,
                  ),
                if (!isRTL)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                if (!isRTL) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                        textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      ),
                    ],
                  ),
                ),
                if (isRTL) const SizedBox(width: 16),
                if (isRTL)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 28,
                    ),
                  ),
                if (!isRTL)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.black38,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
