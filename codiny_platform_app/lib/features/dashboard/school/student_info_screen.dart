import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../data/models/school/school_student.dart';

class StudentInfoScreen extends StatelessWidget {
  final SchoolStudent student;

  const StudentInfoScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = student.hasActiveSubscription;
    final name = student.name;
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final subEnd = student.subscriptionEnd;
    final subStart = student.subscriptionStart;
    
    // Calculate days left and progress
    int? daysLeft;
    double subscriptionProgress = 0;
    if (subEnd != null && subStart != null) {
      final now = DateTime.now();
      daysLeft = subEnd.difference(now).inDays;
      final totalDays = subEnd.difference(subStart).inDays;
      final usedDays = now.difference(subStart).inDays;
      if (totalDays > 0) {
        subscriptionProgress = (usedDays / totalDays).clamp(0.0, 1.0);
      }
    }
    final isExpiringSoon = daysLeft != null && daysLeft >= 0 && daysLeft <= 7;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.blue.shade600,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar with status ring
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive ? Colors.greenAccent : Colors.grey.shade400,
                                width: 3,
                              ),
                            ),
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  firstLetter,
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Online indicator
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: Icon(
                                isActive ? Icons.check : Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Student type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              student.studentType.replaceAll('_', ' ').toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.more_vert_rounded, color: Colors.white),
                ),
                onPressed: () {
                  // Show options menu
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Column(
                    children: [
                      // Quick Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _QuickStatCard(
                              icon: Icons.timer_outlined,
                              label: 'Days Left',
                              value: daysLeft != null && daysLeft > 0 ? '$daysLeft' : '0',
                              color: isExpiringSoon ? Colors.orange : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickStatCard(
                              icon: Icons.check_circle_outlined,
                              label: 'Passed',
                              value: '${student.passedExams}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickStatCard(
                              icon: Icons.quiz_outlined,
                              label: 'Exams',
                              value: '${student.totalExams}',
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Subscription Card (if expiring soon)
                      if (isExpiringSoon)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade400, Colors.orange.shade600],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Subscription Expiring Soon',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$daysLeft days remaining',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'Renew',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Contact Information
                      _EnhancedInfoSection(
                        title: 'Contact Information',
                        icon: Icons.contact_phone_rounded,
                        iconColor: Colors.blue,
                        children: [
                          _EnhancedInfoRow(
                            icon: Icons.badge_outlined,
                            label: 'Student ID',
                            value: '#${student.id.substring(0, 8).toUpperCase()}',
                            onCopy: () {
                              Clipboard.setData(ClipboardData(text: student.id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ID copied to clipboard')),
                              );
                            },
                          ),
                          _EnhancedInfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: '+212 6XX XXX XXX',
                          ),
                          _EnhancedInfoRow(
                            icon: Icons.person_outline_rounded,
                            label: 'Student Type',
                            value: student.studentType.replaceAll('_', ' '),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Exam Progress
                      _EnhancedInfoSection(
                        title: 'Exam Progress',
                        icon: Icons.auto_graph_rounded,
                        iconColor: Colors.purple,
                        children: [
                          const SizedBox(height: 8),
                          // Circular Progress
                          Row(
                            children: [
                              SizedBox(
                                width: 80,
                                height: 80,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: CircularProgressIndicator(
                                        value: student.totalExams > 0 
                                            ? student.passedExams / student.totalExams 
                                            : 0,
                                        strokeWidth: 8,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          student.progressPercent >= 80 
                                              ? Colors.green.shade500
                                              : student.progressPercent >= 50
                                                  ? Colors.orange.shade500
                                                  : Colors.purple.shade500,
                                        ),
                                        strokeCap: StrokeCap.round,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        '${student.progressPercent}%',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: student.progressPercent >= 80 
                                              ? Colors.green.shade700
                                              : student.progressPercent >= 50
                                                  ? Colors.orange.shade700
                                                  : Colors.purple.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _ProgressItem(
                                      label: 'Exams Passed',
                                      value: '${student.passedExams} / ${student.totalExams}',
                                      progress: student.totalExams > 0 
                                          ? student.passedExams / student.totalExams 
                                          : 0,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(height: 12),
                                    _ProgressItem(
                                      label: 'Total Exams Taken',
                                      value: '${student.totalExams}',
                                      progress: student.totalExams > 0 ? 1.0 : 0,
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Subscription Details
                      _EnhancedInfoSection(
                        title: 'Subscription',
                        icon: Icons.card_membership_rounded,
                        iconColor: Colors.green,
                        children: [
                          _EnhancedInfoRow(
                            icon: Icons.category_outlined,
                            label: 'Plan Type',
                            value: student.studentType.replaceAll('_', ' '),
                          ),
                          if (subStart != null)
                            _EnhancedInfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Start Date',
                              value: DateFormat('MMM d, y').format(subStart),
                            ),
                          if (subEnd != null)
                            _EnhancedInfoRow(
                              icon: Icons.event_outlined,
                              label: 'End Date',
                              value: DateFormat('MMM d, y').format(subEnd),
                            ),
                          // Subscription Progress Bar
                          if (subStart != null && subEnd != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Subscription Period',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            '${(subscriptionProgress * 100).toInt()}% used',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: LinearProgressIndicator(
                                          value: subscriptionProgress,
                                          minHeight: 8,
                                          backgroundColor: Colors.grey.shade200,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            isExpiringSoon ? Colors.orange : Colors.green,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ],
                          // Status Row
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isActive ? Colors.green.shade200 : Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.green.shade100 : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    isActive ? Icons.verified_rounded : Icons.cancel_rounded,
                                    color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isActive ? 'Active Subscription' : 'Inactive Subscription',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                                        ),
                                      ),
                                      if (daysLeft != null && daysLeft > 0)
                                        Text(
                                          '$daysLeft days remaining',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isActive ? Colors.green.shade600 : Colors.red.shade600,
                                          ),
                                        ),
                                    ],
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
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final MaterialColor color;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.shade600, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color.shade700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedInfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _EnhancedInfoSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _EnhancedInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _EnhancedInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (onCopy != null) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onCopy,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final MaterialColor color;

  const _ProgressItem({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color.shade500),
          ),
        ),
      ],
    );
  }
}
