import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700]),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Avertissement Important'),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '⚠️ Application Éducative PRIVÉE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Cette application est un outil d\'apprentissage PRIVÉ et INDÉPENDANT.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '❌ NON affiliée au gouvernement\n'
              '❌ NON officielle\n'
              '❌ Ne fournit PAS de services gouvernementaux',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              '✅ Contenu éducatif créé par des instructeurs indépendants\n'
              '✅ Questions d\'entraînement originales\n'
              '✅ Outil d\'apprentissage UNIQUEMENT',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[300]!, width: 2),
              ),
              child: const Row(
                children: [
                  Icon(Icons.school, color: Colors.blue, size: 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Application éducative privée - comme Duolingo pour la conduite',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final uri = Uri.parse(
              'https://htmlpreview.github.io/?https://gist.githubusercontent.com/MedYahyaGarali-1/3f5c7b3b64f72e6e8e5d234604e7169e/raw/e57f274fd51d13990b53f11236ab72df9835fa07/private-policy.html',
            );
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: const Text('Politique de confidentialité'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('J\'ai compris'),
        ),
      ],
    );
  }

  /// Show disclaimer dialog - call this on first app launch
  static Future<void> showIfNeeded(BuildContext context) async {
    // Check if user has seen disclaimer
    final prefs = await SharedPreferences.getInstance();
    final hasSeenDisclaimer = prefs.getBool('has_seen_disclaimer') ?? false;
    
    if (!hasSeenDisclaimer && context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const DisclaimerDialog(),
      );
      await prefs.setBool('has_seen_disclaimer', true);
    }
  }
}
