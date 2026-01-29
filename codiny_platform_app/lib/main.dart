import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app_entry.dart';
import 'app/app_theme.dart';
import 'app/app_router.dart';
import 'state/session/session_controller.dart';
import 'state/subscriptions/subscription_service.dart';
import 'state/theme/theme_controller.dart';
import 'data/repositories/course_repository.dart';
import 'services/notification_service.dart';

// Global navigator key for navigation from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  // Catch ALL errors to prevent crashes
  try {
    print('🚀 App starting...');
    WidgetsFlutterBinding.ensureInitialized();
    print('✅ Flutter binding initialized');

    // Initialize Firebase
    try {
      await Firebase.initializeApp();
      print('✅ Firebase initialized');
    } catch (e) {
      print('⚠️  Firebase initialization failed: $e (continuing without push notifications)');
    }

    final session = SessionController();
    print('✅ SessionController created');
    
    try {
      print('⏳ Restoring session...');
      // Add timeout to prevent infinite loading
      await session.restoreSession().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⚠️  Session restore timed out - continuing with fresh session');
        },
      );
      print('✅ Session restored');

      // Initialize push notifications if logged in
      if (session.token != null) {
        try {
          await NotificationService.initialize(session);
          print('✅ Push notifications initialized');
        } catch (e) {
          print('⚠️  Failed to initialize push notifications: $e');
        }
      }
    } catch (e) {
      print('❌ Error restoring session: $e');
      // Continue with fresh session
    }

    print('🎨 Starting MyApp...');
    runApp(MyApp(session: session));
  } catch (e, stackTrace) {
    print('💥 FATAL ERROR IN MAIN: $e');
    print('Stack trace: $stackTrace');
    // Show error screen instead of crashing
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text('App Failed to Start', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Error: $e', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatefulWidget {
  final SessionController session;

  const MyApp({super.key, required this.session});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    // Load saved theme preference
    _themeController.loadTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.session),
        Provider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider.value(value: _themeController),
        Provider(create: (_) => CourseRepository()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'Driving Exam Platform',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.mode,
            home: const AppEntry(),
            routes: AppRouter.routes,
          );
        },
      ),
    );
  }
}




