import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/environment.dart';
import '../../data/repositories/onboarding_repository.dart';
import '../../state/session/session_controller.dart';
import '../../shared/ui/snackbar_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _repo = OnboardingRepository(baseUrl: Environment.baseUrl);
  bool _isLoading = false;

  Future<void> _chooseIndependent() async {
    setState(() => _isLoading = true);

    try {
      final token = context.read<SessionController>().token;
      if (token == null) throw Exception('Not authenticated');

      await _repo.chooseAccessMethod(
        token: token,
        accessMethod: 'independent',
      );

      if (mounted) {
        // For now, show success message and reload dashboard
        SnackBarHelper.showSuccess(
          context, 
          'Great! Please proceed with payment to activate your subscription.'
        );
        
        // Navigate back to dashboard - it will show limited access
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/student',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _chooseSchoolLinked() async {
    // First, show dialog to get school name
    final schoolName = await _showSchoolNameDialog();
    
    if (schoolName == null || schoolName.trim().isEmpty) {
      return; // User cancelled or entered empty name
    }

    setState(() => _isLoading = true);

    try {
      final token = context.read<SessionController>().token;
      if (token == null) throw Exception('Not authenticated');

      await _repo.chooseAccessMethod(
        token: token,
        accessMethod: 'school_linked',
      );

      // Link to school (using a dummy school_id for now - in production, 
      // you'd search for the school by name first)
      await _repo.linkSchool(
        token: token,
        schoolId: '00000000-0000-0000-0000-000000000000', // Placeholder
        schoolName: schoolName,
      );

      if (mounted) {
        // Show success message
        SnackBarHelper.showInfo(
          context,
          'Request sent to "$schoolName"! You\'ll get access once they approve (24-48h).'
        );
        
        // Navigate back to dashboard - it will show pending status
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/student',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _showSchoolNameDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Enter School Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter the name of your school or institution:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'School Name',
                hintText: 'e.g., Springfield High School',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(context, name);
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Header
                Text(
                  'Welcome! 👋',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose how you want to access the platform',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // Option 1: Independent Learning
                _AccessMethodCard(
                  icon: Icons.school,
                  title: '🎓 Independent Learning',
                  subtitle: 'Full access with subscription',
                  benefits: const [
                    '✓ Full access with subscription',
                    '✓ Flexible payment options',
                    '✓ Instant activation',
                  ],
                  buttonLabel: 'Choose This Option',
                  onPressed: _isLoading ? null : _chooseIndependent,
                  color: colorScheme.primary,
                ),
                
                const SizedBox(height: 24),
                
                // Option 2: School Linked
                _AccessMethodCard(
                  icon: Icons.business,
                  title: '🏫 Linked to School',
                  subtitle: 'Free access pending approval',
                  benefits: const [
                    '✓ Free access (pending approval)',
                    '✓ Managed by your institution',
                    '✓ May take 24-48 hours',
                  ],
                  buttonLabel: 'Choose This Option',
                  onPressed: _isLoading ? null : _chooseSchoolLinked,
                  color: colorScheme.secondary,
                ),
                
                const Spacer(),
                
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccessMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> benefits;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final Color color;

  const _AccessMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.benefits,
    required this.buttonLabel,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Benefits
            ...benefits.map((benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                benefit,
                style: theme.textTheme.bodyMedium,
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
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
          ],
        ),
      ),
    );
  }
}
