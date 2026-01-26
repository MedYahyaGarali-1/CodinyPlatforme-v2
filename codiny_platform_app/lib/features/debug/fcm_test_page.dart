import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// FCM Token Test Page
/// For testing push notifications during development
class FCMTestPage extends StatefulWidget {
  const FCMTestPage({super.key});

  @override
  State<FCMTestPage> createState() => _FCMTestPageState();
}

class _FCMTestPageState extends State<FCMTestPage> {
  String? _fcmToken;
  bool _isLoading = true;
  String _status = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    setState(() {
      _isLoading = true;
      _status = 'Requesting FCM token...';
    });

    try {
      final token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _fcmToken = token;
        _isLoading = false;
        _status = token != null
            ? 'Token loaded successfully!'
            : 'No token available';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error: $e';
      });
    }
  }

  void _copyToken() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FCM Token copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FCM Token Test'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isLoading
                              ? Icons.hourglass_empty
                              : _fcmToken != null
                              ? Icons.check_circle
                              : Icons.error,
                          color: _isLoading
                              ? Colors.orange
                              : _fcmToken != null
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _status,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Token Display
            if (_fcmToken != null) ...[
              const Text(
                'Your FCM Token:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  _fcmToken!,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 16),

              // Copy Button
              ElevatedButton.icon(
                onPressed: _copyToken,
                icon: const Icon(Icons.copy),
                label: const Text('Copy Token'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 32),

              // Instructions
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'How to Test:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildInstruction('1', 'Copy the FCM token above'),
              _buildInstruction(
                '2',
                'Go to Firebase Console → Cloud Messaging',
              ),
              _buildInstruction('3', 'Click "Send your first message"'),
              _buildInstruction('4', 'Paste your token in the test field'),
              _buildInstruction('5', 'Send and check if notification appears!'),
            ],

            // Refresh Button
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _loadFCMToken,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Token'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(text, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
