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

  Future<void> _choosePermit(String permitType) async {
    setState(() => _isLoading = true);

    try {
      final token = context.read<SessionController>().token;
      if (token == null) throw Exception('Not authenticated');

      final result = await _repo.choosePermitType(
        token: token,
        permitType: permitType,
      );

      if (mounted) {
        final info = result['info'] as String?;
        
        if (permitType == 'B') {
          SnackBarHelper.showSuccess(
            context,
            info ?? 'Permit B selected! Full content available once school approves.'
          );
        } else {
          SnackBarHelper.showInfo(
            context,
            info ?? 'Permit $permitType selected! Content coming soon.'
          );
        }
        
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                Text(
                  'Choose Your Permit 🚗',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select the type of driving permit you want to learn',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                _PermitCard(
                  icon: '🏍️',
                  title: 'Permit A',
                  subtitle: 'Motorcycle license',
                  badge: 'Coming Soon',
                  isAvailable: false,
                  onPressed: _isLoading ? null : () => _choosePermit('A'),
                ),
                
                const SizedBox(height: 16),
                
                _PermitCard(
                  icon: '🚗',
                  title: 'Permit B',
                  subtitle: 'Car license',
                  badge: 'Available Now',
                  isAvailable: true,
                  onPressed: _isLoading ? null : () => _choosePermit('B'),
                ),
                
                const SizedBox(height: 16),
                
                _PermitCard(
                  icon: '🚛',
                  title: 'Permit C',
                  subtitle: 'Truck license',
                  badge: 'Coming Soon',
                  isAvailable: false,
                  onPressed: _isLoading ? null : () => _choosePermit('C'),
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

class _PermitCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final String badge;
  final bool isAvailable;
  final VoidCallback? onPressed;

  const _PermitCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.isAvailable,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isAvailable ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isAvailable 
              ? colorScheme.primary.withOpacity(0.5)
              : colorScheme.outlineVariant,
          width: isAvailable ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? null : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.withOpacity(0.2)
                                : Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isAvailable ? Colors.green.shade700 : Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color: isAvailable ? colorScheme.primary : colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
