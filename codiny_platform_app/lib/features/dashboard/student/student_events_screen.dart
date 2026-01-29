import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/calendar_repository.dart';
import '../../../data/models/school/student_event.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/staggered_animation.dart';

class StudentEventsScreen extends StatefulWidget {
  const StudentEventsScreen({super.key});

  @override
  State<StudentEventsScreen> createState() => _StudentEventsScreenState();
}

class _StudentEventsScreenState extends State<StudentEventsScreen> {
  final _repo = CalendarRepository();
  late Future<List<StudentEvent>> _futureEvents;
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _loadEvents();
      _inited = true;
    }
  }

  void _loadEvents() {
    final session = context.read<SessionController>();
    setState(() {
      _futureEvents = _repo.getMyEvents(token: session.token!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<StudentEvent>>(
      future: _futureEvents,
      builder: (context, snap) {
        // Loading State
        if (snap.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ShimmerLoading(
                isLoading: true,
                child: SkeletonCard(
                  height: 120,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        }

        // Error State
        if (snap.hasError) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Failed to Load',
            message: snap.error.toString(),
            actionLabel: 'Retry',
            onAction: _loadEvents,
          );
        }

        final events = snap.data ?? [];

        // Empty State
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF6C63FF).withOpacity(0.1) 
                        : const Color(0xFF3B82F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 48,
                    color: isDark ? const Color(0xFF6C63FF) : const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Upcoming Events',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1D1E33),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your driving school will schedule\nlessons and exams here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Group events by status
        final upcoming = events.where((e) => e.isUpcoming).toList();
        final past = events.where((e) => e.isPast).toList();

        // Success State
        return RefreshIndicator(
          onRefresh: () async => _loadEvents(),
          color: isDark ? const Color(0xFF6C63FF) : const Color(0xFF3B82F6),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                StaggeredAnimationWrapper(
                  index: 0,
                  child: _SectionHeader(
                    title: 'Upcoming Events',
                    count: upcoming.length,
                    isDark: isDark,
                    isUpcoming: true,
                  ),
                ),
                const SizedBox(height: 16),
                ...upcoming.asMap().entries.map((entry) => StaggeredAnimationWrapper(
                      index: entry.key + 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EventCard(event: entry.value, isPast: false, isDark: isDark),
                      ),
                    )),
                const SizedBox(height: 24),
              ],
              if (past.isNotEmpty) ...[
                StaggeredAnimationWrapper(
                  index: upcoming.length + 1,
                  child: _SectionHeader(
                    title: 'Past Events',
                    count: past.length,
                    isDark: isDark,
                    isUpcoming: false,
                  ),
                ),
                const SizedBox(height: 16),
                ...past.asMap().entries.map((entry) => StaggeredAnimationWrapper(
                      index: upcoming.length + entry.key + 2,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _EventCard(event: entry.value, isPast: true, isDark: isDark),
                      ),
                    )),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isDark;
  final bool isUpcoming;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.isDark,
    required this.isUpcoming,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUpcoming 
        ? (isDark ? const Color(0xFF6C63FF) : const Color(0xFF3B82F6))
        : (isDark ? Colors.grey[400]! : Colors.grey[600]!);

    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1D1E33),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final StudentEvent event;
  final bool isPast;
  final bool isDark;

  const _EventCard({
    required this.event,
    required this.isPast,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = event.isToday;
    final dayName = DateFormat('EEEE').format(event.startsAt);
    
    // Different colors for variety
    final List<List<Color>> colorPalette = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)], // Purple-Blue
      [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Teal-Green
      [const Color(0xFFFC466B), const Color(0xFF3F5EFB)], // Pink-Blue
      [const Color(0xFFF093FB), const Color(0xFFF5576C)], // Pink-Red
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)], // Blue-Cyan
      [const Color(0xFF43E97B), const Color(0xFF38F9D7)], // Green-Cyan
      [const Color(0xFFFA709A), const Color(0xFFFEE140)], // Pink-Yellow
    ];
    
    // Pick color based on event title hash for consistency
    final colorIndex = event.title.hashCode.abs() % colorPalette.length;
    final cardColors = isPast 
        ? [const Color(0xFF4A5568), const Color(0xFF2D3748)] // Muted for past
        : colorPalette[colorIndex];
    
    final accentColor = isPast ? Colors.grey[400]! : cardColors[0];

    return Container(
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isPast ? Colors.grey : cardColors[0]).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Gradient with date
          Container(
            width: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: cardColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Month and Day number
                Text(
                  DateFormat('MMM').format(event.startsAt),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  event.startsAt.day.toString(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                // Day name
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Right side - Light with event details
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1D1E33) : const Color(0xFFF8F9FA),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Event type label
                  Text(
                    isPast ? 'PAST' : 'UPCOMING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Event item with colored bar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 3,
                        height: 40,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF1D1E33),
                                decoration: isPast ? TextDecoration.lineThrough : null,
                                decorationColor: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.formattedTime,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Location if available
                  if (event.location != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
