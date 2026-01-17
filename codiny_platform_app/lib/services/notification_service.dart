import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/config/environment.dart';
import '../state/session/session_controller.dart';

/// Push Notification Service
/// Handles Firebase Cloud Messaging for push notifications
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  /// Initialize push notifications
  static Future<void> initialize(SessionController session) async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Push notifications authorized');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('⚠️  Push notifications provisional');
      } else {
        debugPrint('❌ Push notifications denied');
        return;
      }

      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        debugPrint('📱 FCM Token: $token');
        
        // Send token to backend
        await _saveFCMTokenToBackend(token, session);
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('🔄 FCM Token refreshed: $newToken');
          _saveFCMTokenToBackend(newToken, session);
        });
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📬 Foreground notification: ${message.notification?.title}');
        
        if (message.notification != null) {
          // Show local notification or in-app alert
          _showLocalNotification(message);
        }
      });

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📭 Notification opened: ${message.data}');
        _handleNotificationTap(message);
      });

      // Handle notification tap when app was terminated
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 App opened from notification: ${initialMessage.data}');
        _handleNotificationTap(initialMessage);
      }

    } catch (e) {
      debugPrint('❌ Failed to initialize notifications: $e');
    }
  }

  /// Save FCM token to backend
  static Future<void> _saveFCMTokenToBackend(String token, SessionController session) async {
    try {
      if (session.token == null) {
        debugPrint('⚠️  Cannot save FCM token: No auth token');
        return;
      }

      final response = await http.post(
        Uri.parse('${Environment.baseUrl}/students/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${session.token}',
        },
        body: json.encode({
          'fcm_token': token,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ FCM token saved to backend');
      } else {
        debugPrint('❌ Failed to save FCM token: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Show local notification (foreground)
  static void _showLocalNotification(RemoteMessage message) {
    // TODO: Implement local notification display
    // For now, just log it - you can add flutter_local_notifications package for this
    debugPrint('💬 ${message.notification?.title}: ${message.notification?.body}');
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    
    if (data['type'] == 'event_created') {
      // Navigate to calendar/events screen
      debugPrint('Navigate to events screen');
      // TODO: Implement navigation to events screen
    }
  }

  /// Request notification permissions again
  static Future<bool> requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Get current FCM token
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }
}
