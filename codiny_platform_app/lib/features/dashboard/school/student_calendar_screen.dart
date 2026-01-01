import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/calendar_repository.dart';
import '../../../data/models/school/student_event.dart';
import '../../../data/models/school/school_student.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/empty_state.dart';
import '../../../shared/ui/snackbar_helper.dart';
import '../../../shared/layout/base_scaffold.dart';

class StudentCalendarScreen extends StatefulWidget {
  final SchoolStudent student;

  const StudentCalendarScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
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
      _futureEvents = _repo.getStudentEvents(
        studentId: widget.student.id,
        token: session.token!,
      );
    });
  }

  Future<void> _showAddEventDialog() async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Calendar Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Event Title *',
                    hintText: 'e.g., Driving Lesson',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('EEE, MMM d, y').format(selectedDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: const Text('Time'),
                  subtitle: Text(selectedTime.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setDialogState(() => selectedTime = picked);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., School parking',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Additional information',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Add Event'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    if (titleController.text.trim().isEmpty) {
      SnackBarHelper.showError(context, 'Event title is required');
      return;
    }

    try {
      final session = context.read<SessionController>();
      final startsAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      await _repo.createEvent(
        studentId: widget.student.id,
        title: titleController.text.trim(),
        startsAt: startsAt,
        location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : null,
        notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
        token: session.token!,
      );

      if (!mounted) return;
      SnackBarHelper.showSuccess(context, 'Event added successfully');
      _loadEvents();
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Failed to add event: $e');
    }
  }

  Future<void> _deleteEvent(StudentEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event?'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final session = context.read<SessionController>();
      await _repo.deleteEvent(
        eventId: event.id,
        token: session.token!,
      );

      if (!mounted) return;
      SnackBarHelper.showSuccess(context, 'Event deleted');
      _loadEvents();
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, 'Failed to delete event: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BaseScaffold(
      title: '${widget.student.name}\'s Calendar',
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add Event',
          onPressed: _showAddEventDialog,
        ),
      ],
      body: FutureBuilder<List<StudentEvent>>(
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
              title: 'No Events Yet',
              message: 'Add driving lessons, exams, or other important dates for ${widget.student.name}.',
              actionLabel: 'Add First Event',
              onAction: _showAddEventDialog,
            );
          }

          // Success State
          return RefreshIndicator(
            onRefresh: () async => _loadEvents(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final event = events[i];
                final isToday = event.isToday;
                final isPast = event.isPast;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isToday
                          ? cs.primary
                          : cs.outlineVariant,
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Date Circle
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: isToday
                                    ? cs.primary
                                    : isPast
                                        ? cs.surfaceContainerHighest
                                        : cs.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    event.startsAt.day.toString(),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                                              ),
                                        ),
                                      ),
                                      if (isToday)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: cs.primary,
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
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 16, color: cs.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.formattedTime,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                      if (event.location != null) ...[
                                        const SizedBox(width: 12),
                                        Icon(Icons.location_on, size: 16, color: cs.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            event.location!,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (event.notes != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      event.notes!,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: cs.onSurfaceVariant,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Delete Button
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _deleteEvent(event),
                              color: cs.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
