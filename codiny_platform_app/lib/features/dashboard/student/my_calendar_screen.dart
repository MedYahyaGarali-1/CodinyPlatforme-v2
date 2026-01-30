import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../data/repositories/calendar_repository.dart';
import '../../../data/models/school/student_event.dart';
import '../../../state/session/session_controller.dart';
import '../../../shared/ui/shimmer_loading.dart';

class MyCalendarScreen extends StatefulWidget {
  const MyCalendarScreen({super.key});

  @override
  State<MyCalendarScreen> createState() => _MyCalendarScreenState();
}

class _MyCalendarScreenState extends State<MyCalendarScreen> {
  final _repo = CalendarRepository();
  late Future<List<StudentEvent>> _eventsFuture;
  
  DateTime _focusedMonth = DateTime.now();
  Set<DateTime> _selectedDates = {};

  // Colors for event cards like in the design
  static const _cardColors = [
    Color(0xFFD4E7D4), // Mint green
    Color(0xFFE8D4F0), // Lavender purple
    Color(0xFFFFF3E0), // Light orange
    Color(0xFFE3F2FD), // Light blue
    Color(0xFFFCE4EC), // Light pink
  ];

  @override
  void initState() {
    super.initState();
    // Select today by default
    final now = DateTime.now();
    _selectedDates.add(DateTime(now.year, now.month, now.day));
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    
    // Background color - light lavender like in design
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF0EBF8);
    
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FutureBuilder<List<StudentEvent>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            final events = snapshot.data ?? [];
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;

            return Column(
              children: [
                // Top Header
                _buildHeader(isDark, cs),
                
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        _buildTitle(isDark),
                        const SizedBox(height: 20),
                        
                        // Date Picker & Edit Button Row
                        _buildDatePickerRow(isDark, cs),
                        const SizedBox(height: 24),
                        
                        // Calendar Grid
                        _buildCalendarSection(events, isDark, cs),
                        const SizedBox(height: 24),
                        
                        // Events List
                        if (isLoading)
                          _buildLoadingState()
                        else if (hasError)
                          _buildErrorState(snapshot.error.toString(), isDark, cs)
                        else
                          _buildEventsList(events, isDark, cs),
                        
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
          ),
          
          // Profile Avatar
          GestureDetector(
            onTap: _refresh,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDark ? cs.primaryContainer : Colors.white,
                child: Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: cs.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        'Task Schedule',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.grey.shade900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildDatePickerRow(bool isDark, ColorScheme cs) {
    return Row(
      children: [
        // Date Picker Button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
            ),
            boxShadow: isDark ? null : [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
              const SizedBox(width: 10),
              Text(
                DateFormat('dd.MM.yyyy').format(_focusedMonth),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isDark ? Colors.white54 : Colors.grey.shade500,
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Edit Button
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.edit_outlined,
            size: 20,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarSection(List<StudentEvent> events, bool isDark, ColorScheme cs) {
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252540) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month - 1,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 24,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_focusedMonth),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _focusedMonth = DateTime(
                      _focusedMonth.year,
                      _focusedMonth.month + 1,
                    );
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 24,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Weekday Headers
          _buildWeekdayHeaders(isDark),
          const SizedBox(height: 12),
          
          // Calendar Grid
          _buildCalendarGrid(eventDates, isDark, cs),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(bool isDark) {
    final days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.map((day) => SizedBox(
        width: 40,
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white54 : Colors.grey.shade500,
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(Set<DateTime> eventDates, bool isDark, ColorScheme cs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate first day of the month
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));
    
    // Last day of month to determine weeks
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final endDate = lastDayOfMonth.add(Duration(days: 6 - lastDayOfMonth.weekday % 7));
    final totalDays = endDate.difference(startDate).inDays + 1;
    final weeksToShow = (totalDays / 7).ceil();

    return Column(
      children: List.generate(weeksToShow, (weekIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (dayIndex) {
              final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
              final normalizedDate = DateTime(date.year, date.month, date.day);
              final isCurrentMonth = date.month == _focusedMonth.month;
              final isToday = normalizedDate == today;
              final isSelected = _selectedDates.contains(normalizedDate);
              final hasEvent = eventDates.contains(normalizedDate);

              // Determine the visual style based on selection and events
              Color? bgColor;
              Color textColor;
              
              if (isSelected && hasEvent) {
                // Selected with event - use green like in design
                bgColor = const Color(0xFFB8E6B8);
                textColor = Colors.grey.shade800;
              } else if (isSelected) {
                // Just selected - dark/black
                bgColor = isDark ? Colors.white : Colors.grey.shade900;
                textColor = isDark ? Colors.grey.shade900 : Colors.white;
              } else if (hasEvent) {
                // Has event but not selected - light indicator
                bgColor = isDark 
                    ? cs.primary.withOpacity(0.3) 
                    : const Color(0xFFE8E0F0);
                textColor = isDark ? Colors.white : Colors.grey.shade800;
              } else if (isToday) {
                // Today
                bgColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100;
                textColor = isDark ? Colors.white : Colors.grey.shade800;
              } else {
                // Normal day
                bgColor = null;
                textColor = !isCurrentMonth 
                    ? (isDark ? Colors.white24 : Colors.grey.shade300)
                    : (isDark ? Colors.white : Colors.grey.shade700);
              }

              return GestureDetector(
                onTap: () {
                  // Toggle selection
                  setState(() {
                    if (_selectedDates.contains(normalizedDate)) {
                      _selectedDates.remove(normalizedDate);
                    } else {
                      _selectedDates.add(normalizedDate);
                    }
                  });
                  // Show date popup
                  _showDatePopup(normalizedDate, eventDates.contains(normalizedDate), isDark, cs);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected || isToday 
                            ? FontWeight.bold 
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
    );
  }

  void _showDatePopup(DateTime date, bool hasEvents, bool isDark, ColorScheme cs) {
    // Get events for this date from the future
    _eventsFuture.then((events) {
      if (!mounted) return;
      
      final dateEvents = events.where((e) {
        final eventDate = DateTime(e.startsAt.year, e.startsAt.month, e.startsAt.day);
        return eventDate == date;
      }).toList();
      
      dateEvents.sort((a, b) => a.startsAt.compareTo(b.startsAt));
      
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _buildDatePopupContent(date, dateEvents, isDark, cs),
      );
    }).catchError((error) {
      // Show popup even if loading fails
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _buildDatePopupContent(date, [], isDark, cs),
      );
    });
  }

  Widget _buildDatePopupContent(DateTime date, List<StudentEvent> events, bool isDark, ColorScheme cs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = date == today;
    final isTomorrow = date == today.add(const Duration(days: 1));
    final isPast = date.isBefore(today);
    
    // Determine day label
    String dayLabel;
    if (isToday) {
      dayLabel = 'Today';
    } else if (isTomorrow) {
      dayLabel = 'Tomorrow';
    } else {
      dayLabel = DateFormat('EEEE').format(date);
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E30) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                // Date Circle
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    gradient: isToday 
                        ? LinearGradient(
                            colors: [cs.primary, cs.primary.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isToday ? null : (isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100),
                    shape: BoxShape.circle,
                    boxShadow: isToday ? [
                      BoxShadow(
                        color: cs.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : (isDark ? Colors.white : Colors.grey.shade800),
                        ),
                      ),
                      Text(
                        DateFormat('MMM').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isToday ? Colors.white70 : (isDark ? Colors.white54 : Colors.grey.shade500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                
                // Day Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            dayLabel,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.grey.shade900,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '●  NOW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMMM d, yyyy').format(date),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Close Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
          
          const SizedBox(height: 24),
          
          // Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 1,
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
          ),
          
          const SizedBox(height: 20),
          
          // Events Section
          if (events.isEmpty)
            _buildNoEventsPopup(date, isPast, isDark, cs)
          else
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Events Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.event_note_rounded,
                            size: 18,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${events.length} Event${events.length != 1 ? 's' : ''} Scheduled',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Event Cards
                    ...events.asMap().entries.map((entry) {
                      final index = entry.key;
                      final event = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPopupEventCard(event, index, isDark, cs),
                      );
                    }),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNoEventsPopup(DateTime date, bool isPast, bool isDark, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        children: [
          // Illustration
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPast ? Icons.history_rounded : Icons.event_available_rounded,
              size: 48,
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isPast ? 'No Past Events' : 'No Events Scheduled',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPast 
                ? 'There were no events on this day'
                : 'Your schedule is free on this day',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Info Cards
          Row(
            children: [
              Expanded(
                child: _buildQuickInfoCard(
                  Icons.sunny,
                  'Free Day',
                  'Relax & Study',
                  const Color(0xFFFFF3E0),
                  Colors.orange.shade700,
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickInfoCard(
                  Icons.auto_stories_rounded,
                  'Practice',
                  'Take a test',
                  const Color(0xFFE8F5E9),
                  Colors.green.shade700,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(IconData icon, String title, String subtitle, Color bgColor, Color iconColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: isDark ? Colors.white70 : iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupEventCard(StudentEvent event, int index, bool isDark, ColorScheme cs) {
    final now = DateTime.now();
    final isPast = event.startsAt.isBefore(now);
    final isUpcoming = event.startsAt.isAfter(now) && 
        event.startsAt.isBefore(now.add(const Duration(hours: 2)));
    
    // Card colors
    final cardColor = isPast 
        ? (isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100)
        : _cardColors[index % _cardColors.length];
    
    final textColor = isPast 
        ? (isDark ? Colors.white54 : Colors.grey.shade500)
        : Colors.grey.shade800;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isUpcoming ? Border.all(color: cs.primary, width: 2) : null,
        boxShadow: isPast ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.pop(context);
            _showEventDetails(event, isDark, cs);
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('h:mm').format(event.startsAt),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            DateFormat('a').format(event.startsAt),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    
                    // Event Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 17,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Status Badges
                    if (isUpcoming)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_active, size: 12, color: Colors.grey.shade800),
                            const SizedBox(width: 4),
                            Text(
                              'SOON',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (isPast)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'DONE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                  ],
                ),
                
                // Location Row
                if (event.location != null && event.location!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: textColor.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor.withOpacity(0.7),
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
      ),
    );
  }

  Widget _buildEventsList(List<StudentEvent> events, bool isDark, ColorScheme cs) {
    // Filter events for selected dates
    List<StudentEvent> filteredEvents = events;
    if (_selectedDates.isNotEmpty) {
      filteredEvents = events.where((event) {
        final eventDate = DateTime(
          event.startsAt.year,
          event.startsAt.month,
          event.startsAt.day,
        );
        return _selectedDates.contains(eventDate);
      }).toList();
    }

    // Sort events by time
    filteredEvents.sort((a, b) => a.startsAt.compareTo(b.startsAt));

    if (filteredEvents.isEmpty) {
      return _buildEmptyEventsState(isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Text(
              '${filteredEvents.length} Event${filteredEvents.length != 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            if (_selectedDates.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _selectedDates.clear()),
                child: Text(
                  'Clear Selection',
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Event Cards
        ...filteredEvents.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildEventCard(event, index, isDark, cs),
          );
        }),
      ],
    );
  }

  Widget _buildEmptyEventsState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252540) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 60,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Events',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedDates.isNotEmpty
                ? 'No events on selected dates'
                : 'Your school hasn\'t scheduled any events',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(StudentEvent event, int index, bool isDark, ColorScheme cs) {
    final now = DateTime.now();
    final isPast = event.startsAt.isBefore(now);
    
    // Cycle through card colors
    final cardColor = isPast 
        ? (isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100)
        : _cardColors[index % _cardColors.length];
    
    final textColor = isPast 
        ? (isDark ? Colors.white54 : Colors.grey.shade500)
        : Colors.grey.shade800;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showEventDetails(event, isDark, cs),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Row
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_outward_rounded,
                        size: 18,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Bottom Row - Time and Priority
                Row(
                  children: [
                    // Time Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: textColor.withOpacity(0.8),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.formattedTime,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Priority Badge (if upcoming)
                    if (!isPast && event.startsAt.difference(now).inHours < 24)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'High Priority',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                      ),
                      
                    // Location Badge
                    if (event.location != null && event.location!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: textColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.location!.length > 12 
                                  ? '${event.location!.substring(0, 12)}...'
                                  : event.location!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetails(StudentEvent event, bool isDark, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252540) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              event.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade900,
              ),
            ),
            const SizedBox(height: 16),
            
            // Date & Time
            _buildDetailRow(
              Icons.calendar_today_rounded,
              DateFormat('EEEE, MMM d, yyyy').format(event.startsAt),
              isDark,
              cs,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.access_time_rounded,
              event.formattedTime,
              isDark,
              cs,
            ),
            
            // Location
            if (event.location != null && event.location!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.location_on_outlined,
                event.location!,
                isDark,
                cs,
              ),
            ],
            
            // Notes
            if (event.notes != null && event.notes!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                event.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
            ],
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark, ColorScheme cs) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: cs.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ShimmerLoading(
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252540) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 50,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Events',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
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
}
