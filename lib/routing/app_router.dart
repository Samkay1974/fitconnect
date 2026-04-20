import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../models/activity.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/home_screen.dart';
import '../screens/activity_details_screen.dart';
import '../screens/create_activity_screen.dart';
import '../screens/my_activities_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/notifications_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppConstants.routeOnboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case AppConstants.routeLogin:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppConstants.routeSignup:
        return MaterialPageRoute(
          builder: (_) => const SignupScreen(),
          settings: settings,
        );

      case AppConstants.routeHome:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case AppConstants.routeActivityDetails:
        final activityId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ActivityDetailsScreen(activityId: activityId ?? ''),
          settings: settings,
        );

      case AppConstants.routeCreateActivity:
        final activity = settings.arguments as Activity?;
        return MaterialPageRoute(
          builder: (_) => CreateActivityScreen(existingActivity: activity),
          settings: settings,
        );

      case AppConstants.routeMyActivities:
        return MaterialPageRoute(
          builder: (_) => const MyActivitiesScreen(),
          settings: settings,
        );

      case AppConstants.routeProfile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );

      case AppConstants.routeNotifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
    }
  }
}
