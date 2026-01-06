import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/calendar_repository.dart';
import '../../../data/models/school/student_event.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/layout/base_scaffold.dart';

class MyCalendarScreen extends StatefulWidget {
  const MyCalendarScreen({super.key});

  @override
  State<MyCalendarScreen> createState() => _MyCalendarScreenState();
}

class _MyCalendarScreenState extends State<MyCalendarScreen> {
  final _repo = CalendarRepository();
  late Future<List<StudentEvent>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
  }

  Future<List<StudentEvent>> _loadEvents() async {
    final token = context.read<SessionController>().token;
    if (token == null) throw Exception('Not authenticated');
    return await _repo.getMyEvents(token: token);
  }

  Future<void> _refresh() async {
    setState(() {
      _eventsFuture = _loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'My Calendar',
      body: FutureBuilder<List<StudentEvent>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final events = snapshot.data ?? [];
          
          if (events.isEmpty) {
            return EmptyState(
              title: 'No Events',
              message: 'Your school hasn\'t scheduled any events yet.',
              icon: Icons.event_busy_outlined,
              actionLabel: 'Refresh',
              onAction: _refresh,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: _buildEventsList(events),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => ShimmerLoading(
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<StudentEvent> events) {
    // Sort events by date (upcoming first)
    events.sort((a, b) => a.startsAt.compareTo(b.startsAt));

    // Group events by date
    final groupedEvents = <String, List<StudentEvent>>{};
    for (final event in events) {
      final dateKey = DateFormat('yyyy-MM-dd').format(event.startsAt);
      groupedEvents.putIfAbsent(dateKey, () => []).add(event);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: groupedEvents.length,
      itemBuilder: (context, index) {
        final dateKey = groupedEvents.keys.elementAt(index);
        final eventsForDate = groupedEvents[dateKey]!;
        final date = DateTime.parse(dateKey);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date),
            const SizedBox(height: 12),
            ...eventsForDate.map((event) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEventCard(event),
            )),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(date.year, date.month, date.day);
    
    String label;
    Color color;
    
    if (eventDate == today) {
      label = 'Today';
      color = Theme.of(context).primaryColor;
    } else if (eventDate == today.add(const Duration(days: 1))) {
      label = 'Tomorrow';
      color = Colors.orange;
    } else if (eventDate.isBefore(today)) {
      label = DateFormat('EEEE, MMMM d').format(date);
      color = Colors.grey.shade400;
    } else {
      label = DateFormat('EEEE, MMMM d').format(date);
      color = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Row(
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
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(StudentEvent event) {
    final now = DateTime.now();
    final isPast = event.startsAt.isBefore(now);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPast 
              ? [Colors.grey.shade300, Colors.grey.shade400]
              : [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPast 
              ? Colors.grey.shade400
              : Theme.of(context).primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and time
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.event,
                  color: isPast ? Colors.grey.shade600 : Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isPast ? Colors.grey.shade700 : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: isPast ? Colors.grey.shade600 : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeRange(event),
                            style: TextStyle(
                              fontSize: 14,
                              color: isPast ? Colors.grey.shade600 : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (event.isToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            // Location
            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: isPast ? Colors.grey.shade600 : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isPast ? Colors.grey.shade600 : Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Notes
            if (event.notes != null && event.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes,
                      size: 16,
                      color: isPast ? Colors.grey.shade600 : Colors.grey.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.notes!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isPast ? Colors.grey.shade600 : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimeRange(StudentEvent event) {
    final startTime = DateFormat('h:mm a').format(event.startsAt);
    if (event.endsAt != null) {
      final endTime = DateFormat('h:mm a').format(event.endsAt!);
      return '$startTime - $endTime';
    }
    return startTime;
  }
}
