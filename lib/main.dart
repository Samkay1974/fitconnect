import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'config/app_theme.dart';
import 'config/app_constants.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/ui_provider.dart';
import 'providers/notification_provider.dart';
import 'routing/app_router.dart';
import 'services/auth_service.dart';
import 'services/activity_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final authService = AuthService();
    final activityService = ActivityService();
    final notificationService = NotificationService();

    return MultiProvider(
      providers: [
        // State management
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(activityService),
        ),
        ChangeNotifierProvider(create: (_) => UiProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationService),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,

        // Initial route
        initialRoute: AppConstants.routeOnboarding,

        // Named routes
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
