import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../state/session/session_controller.dart';
import '../../../state/subscriptions/subscription_service.dart';
import '../../../shared/layout/base_scaffold.dart';
import '../../../shared/layout/dashboard_shell.dart';
import '../../../shared/ui/snackbar_helper.dart';
import 'my_calendar_screen.dart';

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
      showBackButton: false, // Dashboard screen - no back button
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔒 Access Status Banner
            _buildAccessStatusBanner(context, profile),

            const SizedBox(height: 16),

            // 👋 Welcome Header with enhanced design
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back! 👋',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          session.user?.name ?? 'Student',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.waving_hand_rounded,
                      color: Colors.white,
                      size: 32,
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
                        builder: (_) => const MyCalendarScreen(),
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
      // School-linked learner - waiting for school to activate
      if (!isActive || accessLevel == 'limited') {
        icon = Icons.school;
        backgroundColor = Colors.blue;
        title = '🏫 Waiting for School Activation';
        message = 'Give your Student ID to your school. Once they activate your account, you\'ll have full access!';
      } else if (isActive && accessLevel == 'full') {
        // Active with full access
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

class _ActionCard extends StatefulWidget {
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
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: widget.gradient.map((c) => 
                _isPressed ? c.withOpacity(0.9) : c.withOpacity(0.1)
              ).toList(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: widget.gradient.first.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'action_${widget.label}',
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: widget.gradient.first.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.icon,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: gradient.first.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

