import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../state/session/session_controller.dart';
import '../../../state/subscriptions/subscription_service.dart';
import '../../../shared/layout/base_scaffold.dart';
import '../../../shared/layout/dashboard_shell.dart';
import '../../../shared/ui/snackbar_helper.dart';
import '../school/student_calendars_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final subscriptionService = context.read<SubscriptionService>();
    final profile = session.studentProfile;
    final now = DateTime.now();

    final subscriptionEnd = profile?.subscriptionEnd;

    final daysLeft = subscriptionEnd == null
        ? 0
        : subscriptionService.remainingDays(subscriptionEnd, now);

    final isActive = subscriptionEnd != null &&
        subscriptionService.isActive(subscriptionEnd, now);

    return BaseScaffold(
      title: 'Dashboard',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔒 Access Status Banner
            _buildAccessStatusBanner(context, profile),

            const SizedBox(height: 16),

            // 👋 Welcome Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back! 👋',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.user?.name ?? 'Student',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (profile?.id.isNotEmpty == true) ...[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.badge,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    'Your Student ID',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      profile!.id,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                          ),
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'Copy ID',
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: profile.id));
                      if (!context.mounted) return;
                      SnackBarHelper.showSuccess(context, 'Student ID copied to clipboard');
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ⏳ Subscription status
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Subscription',
                    value: isActive ? '$daysLeft days' : 'Expired',
                    icon: Icons.timer_outlined,
                    gradient: isActive
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.orange.shade400, Colors.orange.shade600],
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: _InfoCard(
                    title: 'Progress',
                    value: '42%',
                    icon: Icons.bar_chart_outlined,
                    gradient: [Colors.blue, Colors.purple],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 🚀 Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
              children: [
                _ActionCard(
                  icon: Icons.play_circle_outline,
                  label: 'Courses',
                  gradient: const [Colors.blue, Colors.cyan],
                  onTap: _canAccessFeatures(profile) ? () {
                    // Navigate to Courses tab (index 2)
                    DashboardShell.of(context)?.changeTab(2);
                  } : () {
                    SnackBarHelper.showError(
                      context,
                      'Please complete payment to access courses',
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.quiz_outlined,
                  label: 'Tests',
                  gradient: const [Colors.purple, Colors.pink],
                  onTap: _canAccessFeatures(profile) ? () {
                    // Navigate to Exams tab (index 3)
                    DashboardShell.of(context)?.changeTab(3);
                  } : () {
                    SnackBarHelper.showError(
                      context,
                      'Please complete payment to access tests',
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.calendar_month_outlined,
                  label: 'View Calendar',
                  gradient: const [Colors.orange, Colors.deepOrange],
                  onTap: _canAccessFeatures(profile) ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StudentCalendarsScreen(),
                      ),
                    );
                  } : () {
                    SnackBarHelper.showError(
                      context,
                      'Please complete payment to access calendar',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static bool _canAccessFeatures(dynamic profile) {
    if (profile == null) return false;
    
    final accessMethod = profile.accessMethod;
    final paymentVerified = profile.paymentVerified ?? false;
    final isActive = profile.isActive ?? false;
    
    // Independent students need payment verification
    if (accessMethod == 'independent' && !paymentVerified) {
      return false;
    }
    
    // School-linked students need to be active
    if (accessMethod == 'school_linked' && !isActive) {
      return false;
    }
    
    return true;
  }

  static Widget _buildAccessStatusBanner(BuildContext context, dynamic profile) {
    // If profile doesn't exist, show nothing
    if (profile == null) {
      return const SizedBox.shrink();
    }

    final onboardingComplete = profile.onboardingComplete ?? false;
    final accessMethod = profile.accessMethod;
    final schoolApprovalStatus = profile.schoolApprovalStatus;
    final paymentVerified = profile.paymentVerified ?? false;
    final isActive = profile.isActive ?? false;
    final accessLevel = profile.accessLevel ?? 'none';

    // If onboarding not complete, don't show banner (onboarding screen will show)
    if (!onboardingComplete) {
      return const SizedBox.shrink();
    }

    // If student is active with full access, no banner needed
    if (isActive && accessLevel == 'full') {
      return const SizedBox.shrink();
    }

    // Determine banner content based on access method
    IconData icon;
    Color backgroundColor;
    String title;
    String message;

    if (accessMethod == 'independent') {
      // Independent learner - needs payment
      if (!paymentVerified) {
        icon = Icons.payment;
        backgroundColor = Colors.orange;
        title = '💳 Payment Required';
        message = 'Please complete your subscription payment to access all content.';
      } else {
        // Payment verified, full access
        return const SizedBox.shrink();
      }
    } else if (accessMethod == 'school_linked') {
      // School-linked learner - check if truly pending (not active or limited access)
      if (schoolApprovalStatus == 'pending' && (!isActive || accessLevel == 'limited')) {
        icon = Icons.pending;
        backgroundColor = Colors.blue;
        title = '⏳ Awaiting School Approval';
        message = 'Your school will review your request within 24-48 hours. You\'ll be notified once approved.';
      } else if (schoolApprovalStatus == 'rejected') {
        icon = Icons.cancel;
        backgroundColor = Colors.red;
        title = '❌ Request Rejected';
        message = 'Your school request was rejected. Please contact your school administrator.';
      } else if (schoolApprovalStatus == 'approved' || (isActive && accessLevel == 'full')) {
        // Approved or active with full access
        return const SizedBox.shrink();
      } else {
        // No status yet
        icon = Icons.info;
        backgroundColor = Colors.grey;
        title = 'ℹ️ Limited Access';
        message = 'You have limited access. Please complete your onboarding.';
      }
    } else {
      // Unknown access method
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.1),
        border: Border.all(color: backgroundColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: backgroundColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: backgroundColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

