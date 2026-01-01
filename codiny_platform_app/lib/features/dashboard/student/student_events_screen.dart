import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/calendar_repository.dart';
import '../../../data/models/school/student_event.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';

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
    final cs = Theme.of(context).colorScheme;

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
          return EmptyState(
            icon: Icons.calendar_today_outlined,
            title: 'No Upcoming Events',
            message: 'Your driving school will schedule lessons and exams here.',
          );
        }

        // Group events by status
        final upcoming = events.where((e) => e.isUpcoming).toList();
        final past = events.where((e) => e.isPast).toList();

        // Success State
        return RefreshIndicator(
          onRefresh: () async => _loadEvents(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Upcoming Events',
                  count: upcoming.length,
                  color: cs.primary,
                ),
                const SizedBox(height: 12),
                ...upcoming.map((event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EventCard(event: event, isPast: false),
                    )),
                const SizedBox(height: 24),
              ],
              if (past.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Past Events',
                  count: past.length,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                ...past.map((event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EventCard(event: event, isPast: true),
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
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
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

  const _EventCard({
    required this.event,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isToday = event.isToday;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isToday ? cs.primary : cs.outlineVariant,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date Circle
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isToday
                      ? [cs.primary, cs.primary.withOpacity(0.7)]
                      : isPast
                          ? [cs.surfaceContainerHighest, cs.surfaceContainerHigh]
                          : [cs.primaryContainer, cs.primaryContainer.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.startsAt.day.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isToday
                              ? cs.onPrimary
                              : isPast
                                  ? cs.onSurfaceVariant
                                  : cs.onPrimaryContainer,
                        ),
                  ),
                  Text(
                    DateFormat('MMM').format(event.startsAt).toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isToday
                              ? cs.onPrimary
                              : isPast
                                  ? cs.onSurfaceVariant
                                  : cs.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Event Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isPast ? TextDecoration.lineThrough : null,
                              ),
                        ),
                      ),
                      if (isToday)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.primary.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'TODAY',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: cs.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '${event.formattedTime} • ${event.formattedDateLong}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (event.notes != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 16, color: cs.onSurfaceVariant),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.notes!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
