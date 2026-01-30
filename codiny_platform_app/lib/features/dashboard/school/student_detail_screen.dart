import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/calendar_repository.dart';
import '../../../data/models/school/school_student.dart';
import '../../../data/models/school/student_event.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/ui/snackbar_helper.dart';

class StudentDetailScreen extends StatefulWidget {
  final SchoolStudent student;

  const StudentDetailScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _repo = CalendarRepository();
  late Future<List<StudentEvent>> _futureEvents;
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<StudentEvent>> _eventsByDate = {};
  bool _inited = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _selectedDay = DateTime.now();
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

    _futureEvents.then((events) {
      setState(() {
        _eventsByDate = _groupEventsByDate(events);
      });
    });
  }

  Map<DateTime, List<StudentEvent>> _groupEventsByDate(List<StudentEvent> events) {
    final map = <DateTime, List<StudentEvent>>{};
    for (var event in events) {
      final date = DateTime(
        event.startsAt.year,
        event.startsAt.month,
        event.startsAt.day,
      );
      if (map[date] == null) {
        map[date] = [];
      }
      map[date]!.add(event);
    }
    return map;
  }

  List<StudentEvent> _getEventsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _eventsByDate[date] ?? [];
  }

  Future<void> _showAddEventDialog(DateTime selectedDate) async {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Container(
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 40,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E30) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(
                      children: [
                        // Calendar Icon
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.primary.withOpacity(0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.event_note_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Event',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cs.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  DateFormat('EEEE, MMM d, yyyy').format(selectedDate),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Close Button
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx, false),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: isDark ? Colors.white70 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Form Fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Title
                        Text(
                          'Event Title *',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.grey.shade200,
                            ),
                          ),
                          child: TextField(
                            controller: titleController,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.grey.shade900,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., Driving Lesson',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white38 : Colors.grey.shade400,
                              ),
                              prefixIcon: Icon(
                                Icons.edit_rounded,
                                color: isDark ? Colors.white54 : Colors.grey.shade500,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            autofocus: true,
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Time Picker
                        Text(
                          'Time',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    timePickerTheme: TimePickerThemeData(
                                      backgroundColor: isDark ? const Color(0xFF252540) : Colors.white,
                                      hourMinuteShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() => selectedTime = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white12 : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.access_time_rounded,
                                    color: cs.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedTime.format(context),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.grey.shade900,
                                      ),
                                    ),
                                    Text(
                                      'Tap to change',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white54 : Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Location
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.grey.shade200,
                            ),
                          ),
                          child: TextField(
                            controller: locationController,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.grey.shade900,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g., School parking lot',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white38 : Colors.grey.shade400,
                              ),
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: isDark ? Colors.white54 : Colors.grey.shade500,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Notes
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.grey.shade200,
                            ),
                          ),
                          child: TextField(
                            controller: notesController,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.grey.shade900,
                            ),
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Additional information...',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white38 : Colors.grey.shade400,
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: Icon(
                                  Icons.notes_rounded,
                                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                                ),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      children: [
                        // Cancel Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Add Event Button
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [cs.primary, cs.primary.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Add Event',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  Future<void> _showEventDetails(List<StudentEvent> events) async {
    final cs = Theme.of(context).colorScheme;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${events.length} Event${events.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final event = events[i];
                  return _buildDetailCard(event, cs, () async {
                    Navigator.pop(context);
                    await _deleteEvent(event);
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(StudentEvent event, ColorScheme cs, VoidCallback onDelete) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: cs.error),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                '${event.formattedTime} • ${event.formattedDateLong}',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          if (event.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(event.location!, style: TextStyle(color: cs.onSurfaceVariant))),
              ],
            ),
          ],
          if (event.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notes, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(child: Text(event.notes!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: cs.surface,
      body: FutureBuilder<List<StudentEvent>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          final events = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, isDark, cs),
              SliverToBoxAdapter(
                child: _buildCalendarSection(isDark, cs),
              ),
              if (isLoading)
                SliverToBoxAdapter(child: _buildLoadingState(cs))
              else if (hasError)
                SliverToBoxAdapter(child: _buildErrorState(snapshot.error.toString(), isDark, cs))
              else
                _buildEventsSection(events, isDark, cs),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEventDialog(_selectedDay ?? DateTime.now()),
        backgroundColor: cs.primary,
        icon: Icon(Icons.add, color: cs.onPrimary),
        label: Text('Add Event', style: TextStyle(color: cs.onPrimary)),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool isDark, ColorScheme cs) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: cs.surface,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back, color: cs.onSurface, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.refresh, color: cs.onSurface, size: 20),
          ),
          onPressed: _loadEvents,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.primary, cs.secondary],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            widget.student.name.isNotEmpty
                                ? widget.student.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.student.name} - Calendar',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Manage scheduled events',
                              style: TextStyle(fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection(bool isDark, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Picker Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                // Date Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? cs.surfaceContainerHighest : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18, color: cs.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd.MM.yyyy').format(_focusedMonth),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down, size: 20, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
                const Spacer(),
                // Navigation Buttons
                Row(
                  children: [
                    _buildNavButton(Icons.chevron_left, () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                      });
                    }, isDark, cs),
                    const SizedBox(width: 8),
                    _buildNavButton(Icons.chevron_right, () {
                      setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                      });
                    }, isDark, cs),
                  ],
                ),
              ],
            ),
          ),
          
          // Month/Year Title
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              DateFormat('MMMM yyyy').format(_focusedMonth),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          
          // Weekday Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .asMap()
                  .entries
                  .map((entry) => SizedBox(
                        width: 42,
                        child: Text(
                          entry.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: entry.key == 5 || entry.key == 6 
                                ? Colors.grey.shade400 
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          
          // Calendar Grid
          _buildCalendarGrid(isDark, cs),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap, bool isDark, ColorScheme cs) {
    return Material(
      color: isDark ? cs.surfaceContainerHighest : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(bool isDark, ColorScheme cs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    
    // Calculate weeks needed
    final daysInView = (firstDayOfMonth.weekday % 7) + lastDayOfMonth.day;
    final weeksToShow = (daysInView / 7).ceil();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(weeksToShow, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
                final isCurrentMonth = date.month == _focusedMonth.month;
                final isToday = date == today;
                final isSelected = _selectedDay != null &&
                    date.year == _selectedDay!.year &&
                    date.month == _selectedDay!.month &&
                    date.day == _selectedDay!.day;
                final hasEvent = _eventsByDate.containsKey(date);
                final isPast = date.isBefore(today);

                // Different styles based on state
                Color? bgColor;
                Color textColor;
                BoxBorder? border;

                if (isSelected) {
                  bgColor = cs.primary;
                  textColor = cs.onPrimary;
                } else if (hasEvent) {
                  // Events get a light green/mint background like in the design
                  bgColor = const Color(0xFFE8F5E9); // Light mint green
                  textColor = isDark ? Colors.green.shade700 : Colors.green.shade800;
                } else if (isToday) {
                  bgColor = isDark ? cs.surfaceContainerHighest : Colors.grey.shade200;
                  textColor = cs.onSurface;
                  border = Border.all(color: cs.primary, width: 2);
                } else if (!isCurrentMonth) {
                  textColor = cs.onSurface.withOpacity(0.25);
                } else if (isPast) {
                  textColor = cs.onSurface.withOpacity(0.4);
                } else {
                  textColor = cs.onSurface;
                }

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedDay = date);
                    final dayEvents = _getEventsForDay(date);
                    if (dayEvents.isNotEmpty) {
                      _showEventDetails(dayEvents);
                    } else {
                      _showAddEventDialog(date);
                    }
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: border,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: (isToday || isSelected || hasEvent) 
                              ? FontWeight.w600 
                              : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEventsSection(List<StudentEvent> events, bool isDark, ColorScheme cs) {
    List<StudentEvent> filteredEvents = events;
    if (_selectedDay != null) {
      filteredEvents = events.where((event) {
        final eventDate = DateTime(event.startsAt.year, event.startsAt.month, event.startsAt.day);
        final selected = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
        return eventDate == selected;
      }).toList();
    }
    filteredEvents.sort((a, b) => a.startsAt.compareTo(b.startsAt));

    if (filteredEvents.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: _buildEmptyEventsState(isDark, cs));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [cs.primary, cs.secondary]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filteredEvents.length} Event${filteredEvents.length != 1 ? 's' : ''}',
                        style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDay != null ? DateFormat('EEEE, MMM d').format(_selectedDay!) : 'All Events',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEventCard(filteredEvents[index - 1], isDark, cs),
            );
          },
          childCount: filteredEvents.length + 1,
        ),
      ),
    );
  }

  Widget _buildEmptyEventsState(bool isDark, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available_outlined, size: 50, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text('No Events Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(
            'Tap on a date to add an event',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(child: CircularProgressIndicator(color: cs.primary)),
    );
  }

  Widget _buildErrorState(String error, bool isDark, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.error.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cs.error.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.error_outline_rounded, size: 40, color: cs.error),
          ),
          const SizedBox(height: 16),
          Text('Failed to Load Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadEvents,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(StudentEvent event, bool isDark, ColorScheme cs) {
    final now = DateTime.now();
    final isPast = event.startsAt.isBefore(now);
    final isUpcoming = event.startsAt.isAfter(now) && 
        event.startsAt.isBefore(now.add(const Duration(hours: 2)));

    // Different card colors like in the design
    final List<Color> cardColors = [
      const Color(0xFFE8F5E9), // Light mint green
      const Color(0xFFE3F2FD), // Light blue
      const Color(0xFFFCE4EC), // Light pink
      const Color(0xFFFFF3E0), // Light orange
      const Color(0xFFEDE7F6), // Light purple
    ];
    
    // Pick color based on event title hash
    final colorIndex = event.title.hashCode.abs() % cardColors.length;
    final cardColor = isPast 
        ? (isDark ? cs.surfaceContainerHighest : Colors.grey.shade100)
        : cardColors[colorIndex];
    
    final textColor = isPast 
        ? cs.onSurfaceVariant 
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade800);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isUpcoming 
            ? Border.all(color: cs.primary, width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showEventDetails([event]),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row with Arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          if (event.notes != null && event.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              event.notes!,
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Arrow button
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_outward,
                        size: 18,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Bottom Row - Time and Priority Badge
                Row(
                  children: [
                    // Time Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: textColor.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.formattedTime,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Location or Priority Badge
                    if (event.location != null && event.location!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: textColor.withOpacity(0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.location!.length > 15 
                                  ? '${event.location!.substring(0, 15)}...'
                                  : event.location!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Delete Button
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _deleteEvent(event),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red.shade400,
                        ),
                      ),
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
