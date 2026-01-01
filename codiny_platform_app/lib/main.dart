import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app_entry.dart';
import 'app/app_theme.dart';
import 'app/app_router.dart';
import 'state/session/session_controller.dart';
import 'state/subscriptions/subscription_service.dart';
import 'state/theme/theme_controller.dart';
import 'data/repositories/course_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = SessionController();
  await session.restoreSession();

  runApp(MyApp(session: session));
}

class MyApp extends StatelessWidget {
  final SessionController session;

  const MyApp({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: session),
        Provider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        Provider(create: (_) => CourseRepository()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
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




