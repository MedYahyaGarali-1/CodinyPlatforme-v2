import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/calendar_repository.dart';
import '../../../data/models/school/student_event.dart';
import '../../../data/models/school/school_student.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/ui/shimmer_loading.dart';
import '../../../shared/ui/snackbar_helper.dart';

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
  
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  bool _showTwoWeeks = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_inited) {
      _selectedDate = DateTime.now();
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: FutureBuilder<List<StudentEvent>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          final events = snapshot.data ?? [];
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          final hasError = snapshot.hasError;

          return CustomScrollView(
            slivers: [
              // App Bar
              _buildSliverAppBar(context),
              
              // Calendar Section
              SliverToBoxAdapter(
                child: _buildCalendarSection(events),
              ),
              
              // Events Section
              if (isLoading)
                SliverToBoxAdapter(child: _buildLoadingState())
              else if (hasError)
                SliverToBoxAdapter(child: _buildErrorState(snapshot.error.toString()))
              else
                _buildEventsSection(events),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventDialog,
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Event', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF0A0E21),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
          onPressed: _loadEvents,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
              ],
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
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.3),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
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
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
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

  Widget _buildCalendarSection(List<StudentEvent> events) {
    // Get dates with events
    final eventDates = <DateTime>{};
    for (final event in events) {
      eventDates.add(DateTime(
        event.startsAt.year,
        event.startsAt.month,
        event.startsAt.day,
      ));
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month - 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_left, color: Colors.white70),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    // View Toggle
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: InkWell(
                        onTap: () => setState(() => _showTwoWeeks = !_showTwoWeeks),
                        child: Text(
                          _showTwoWeeks ? '2 weeks' : 'Month',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                        });
                      },
                      icon: const Icon(Icons.chevron_right, color: Colors.white70),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Weekday Headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => SizedBox(
                        width: 40,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: day == 'Fri' || day == 'Sat'
                                ? Colors.amber.shade300
                                : Colors.white54,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          
          // Calendar Grid
          _buildCalendarGrid(eventDates),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Set<DateTime> eventDates) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate first day of the grid
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    
    // Calculate number of weeks to show
    int weeksToShow = _showTwoWeeks ? 2 : 6;
    
    // If showing 2 weeks, start from current week
    DateTime gridStart = _showTwoWeeks
        ? today.subtract(Duration(days: today.weekday % 7))
        : startDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: List.generate(weeksToShow, (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final date = gridStart.add(Duration(days: weekIndex * 7 + dayIndex));
                final isCurrentMonth = date.month == _focusedMonth.month;
                final isToday = date == today;
                final isSelected = _selectedDate != null &&
                    date.year == _selectedDate!.year &&
                    date.month == _selectedDate!.month &&
                    date.day == _selectedDate!.day;
                final hasEvent = eventDates.contains(date);
                final isPast = date.isBefore(today);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            )
                          : isToday
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFF667eea).withOpacity(0.3),
                                    const Color(0xFF764ba2).withOpacity(0.3),
                                  ],
                                )
                              : null,
                      color: !isSelected && !isToday
                          ? (hasEvent ? Colors.white.withOpacity(0.05) : null)
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: isToday && !isSelected
                          ? Border.all(color: const Color(0xFF667eea), width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday || isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : !isCurrentMonth
                                    ? Colors.white24
                                    : isPast
                                        ? Colors.white38
                                        : Colors.white,
                          ),
                        ),
                        if (hasEvent)
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF667eea),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
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

  Widget _buildEventsSection(List<StudentEvent> events) {
    // Filter events for selected date
    List<StudentEvent> filteredEvents = events;
    if (_selectedDate != null) {
      filteredEvents = events.where((event) {
        final eventDate = DateTime(
          event.startsAt.year,
          event.startsAt.month,
          event.startsAt.day,
        );
        final selected = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
        );
        return eventDate == selected;
      }).toList();
    }

    // Sort events by time
    filteredEvents.sort((a, b) => a.startsAt.compareTo(b.startsAt));

    if (filteredEvents.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyEventsState(),
      );
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${filteredEvents.length} Event${filteredEvents.length != 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? DateFormat('EEEE, MMM d').format(_selectedDate!)
                          : 'All Events',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildEventCard(filteredEvents[index - 1]),
            );
          },
          childCount: filteredEvents.length + 1,
        ),
      ),
    );
  }

  Widget _buildEmptyEventsState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_available_outlined,
              size: 50,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Events Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap on a date to add an event',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ShimmerLoading(
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D1F33),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1F33),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to Load Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadEvents,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(StudentEvent event) {
    final now = DateTime.now();
    final isPast = event.startsAt.isBefore(now);
    final isUpcoming = event.startsAt.isAfter(now) && 
        event.startsAt.isBefore(now.add(const Duration(hours: 2)));
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPast 
              ? [const Color(0xFF2D2D3A), const Color(0xFF252532)]
              : isUpcoming
                  ? [const Color(0xFF667eea), const Color(0xFF764ba2)]
                  : [const Color(0xFF1D1F33), const Color(0xFF252538)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPast 
              ? Colors.white.withOpacity(0.1)
              : isUpcoming
                  ? Colors.white.withOpacity(0.3)
                  : const Color(0xFF667eea).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          if (!isPast)
            BoxShadow(
              color: const Color(0xFF667eea).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPast
                          ? Colors.white.withOpacity(0.05)
                          : isUpcoming
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFF667eea).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('h:mm').format(event.startsAt),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPast ? Colors.white38 : Colors.white,
                          ),
                        ),
                        Text(
                          DateFormat('a').format(event.startsAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: isPast ? Colors.white30 : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  
                  // Event Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isPast ? Colors.white54 : Colors.white,
                          ),
                        ),
                        if (event.endsAt != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.timelapse_rounded,
                                size: 14,
                                color: isPast ? Colors.white30 : Colors.white54,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(event),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isPast ? Colors.white30 : Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Delete Button
                  IconButton(
                    onPressed: () => _deleteEvent(event),
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: isPast ? Colors.white30 : Colors.redAccent.withOpacity(0.7),
                      size: 22,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ],
              ),

              // Location
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: isPast ? Colors.white30 : const Color(0xFF667eea),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          event.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isPast ? Colors.white38 : Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Notes
              if (event.notes != null && event.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_rounded,
                        size: 16,
                        color: isPast ? Colors.white30 : Colors.white54,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          event.notes!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isPast ? Colors.white30 : Colors.white60,
                            height: 1.4,
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
      ),
    );
  }

  String _formatDuration(StudentEvent event) {
    if (event.endsAt == null) return '';
    final duration = event.endsAt!.difference(event.startsAt);
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    }
    return '${duration.inMinutes}m';
  }
}
