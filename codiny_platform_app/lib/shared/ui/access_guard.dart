import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/environment.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../../data/models/student/student_access.dart';
import '../../state/session/session_controller.dart';

/// Widget that checks access permissions and redirects if needed
class AccessGuard extends StatelessWidget {
  final Widget child;
  final bool requiresFullAccess;
  final String featureName;

  const AccessGuard({
    super.key,
    required this.child,
    this.requiresFullAccess = true,
    this.featureName = 'this content',
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AccessStatusResponse>(
      future: _checkAccess(context),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Error
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        final accessStatus = snapshot.data!;
        final access = accessStatus.access;
        final student = accessStatus.student;

        // Check onboarding
        if (!student.onboardingComplete) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/onboarding');
          });
          return const SizedBox.shrink();
        }

        // Check if requires full access
        if (requiresFullAccess && !access.isActive) {
          return _buildAccessDeniedScreen(context, access);
        }

        // All good, show content
        return child;
      },
    );
  }

  Future<AccessStatusResponse> _checkAccess(BuildContext context) async {
    final token = context.read<SessionController>().token;
    if (token == null) throw Exception('Not authenticated');

    final repo = OnboardingRepository(baseUrl: Environment.baseUrl);
    return await repo.getAccessStatus(token: token);
  }

  Widget _buildAccessDeniedScreen(BuildContext context, StudentAccess access) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData icon;
    String title;
    String subtitle;
    String buttonLabel;
    VoidCallback? onPressed;

    if (access.redirectTo == 'payment') {
      icon = Icons.payment;
      title = '🔒 Premium Content';
      subtitle = access.message ?? 'Subscribe to access $featureName';
      buttonLabel = 'View Plans & Subscribe';
      onPressed = () {
        Navigator.pushNamed(context, '/payment');
      };
    } else if (access.reason == 'school_pending' || access.reason == 'school_rejected') {
      icon = Icons.school;
      title = '🏫 School Activation Required';
      subtitle = access.message ?? 'Give your Student ID to your school to activate your account';
      buttonLabel = 'Go to Dashboard';
      onPressed = () {
        Navigator.pushNamed(context, '/student');
      };
    } else {
      icon = Icons.lock_outline;
      title = '🔒 Access Required';
      subtitle = access.message ?? 'You need access to view $featureName';
      buttonLabel = 'Setup Access';
      onPressed = () {
        Navigator.pushReplacementNamed(context, '/onboarding');
      };
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 100,
                color: colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 32),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                },
                child: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple access check for inline widgets
class AccessCheckWidget extends StatelessWidget {
  final Widget child;
  final Widget? blockedWidget;

  const AccessCheckWidget({
    super.key,
    required this.child,
    this.blockedWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AccessStatusResponse>(
      future: _checkAccess(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final access = snapshot.data!.access;

        if (!access.isActive) {
          return blockedWidget ?? const SizedBox.shrink();
        }

        return child;
      },
    );
  }

  Future<AccessStatusResponse> _checkAccess(BuildContext context) async {
    final token = context.read<SessionController>().token;
    if (token == null) throw Exception('Not authenticated');

    final repo = OnboardingRepository();
    return await repo.getAccessStatus(token: token);
  }
}
