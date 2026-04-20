# FitConnect

FitConnect is a Flutter mobile app for discovering, creating, and joining fitness events.

## How to use the application

1. Open the app and create an account (name, email, phone number, password).
2. Browse events on the Home screen.
3. Tap an event card to view full details.
4. Use `Join Activity` to participate in an event.
5. Use `Find location` to open directions in Google Maps.
6. Use `Call organizer` if you need more information from the event creator.
7. Use `Create Activity` to add your own event.
8. Open `Profile` to edit your details (including phone number) and log out.

## Project setup (quick)

1. Install Flutter SDK and Firebase/Android/iOS prerequisites.
2. Run `flutter pub get`.
3. Configure Firebase for your platforms.
4. Configure Cloudinary credentials in [lib/config/app_constants.dart](lib/config/app_constants.dart) for image uploads.
5. Run the app with `flutter run`.

## AI declaration

This project used AI as a coding assistant for drafting, refactoring, debugging, and accelerating implementation. Final review, decisions, testing, and acceptance were done by me.

| Contribution Type | Files (Examples) | Reasoning |
| --- | --- | --- |
| AI Only | [lib/screens/activity_details_screen.dart](lib/screens/activity_details_screen.dart), [lib/widgets/activity_card.dart](lib/widgets/activity_card.dart), [lib/services/activity_service.dart](lib/services/activity_service.dart), [lib/services/firestore_service.dart](lib/services/firestore_service.dart) | These files contain more complex logic (GPS directions, geocoding/maps launch, event flow orchestration, and service-layer data handling). |
| AI + ME | [lib/providers/activity_provider.dart](lib/providers/activity_provider.dart), [lib/providers/auth_provider.dart](lib/providers/auth_provider.dart), [lib/services/auth_service.dart](lib/services/auth_service.dart), [lib/screens/create_activity_screen.dart](lib/screens/create_activity_screen.dart), [lib/screens/profile_screen.dart](lib/screens/profile_screen.dart), [lib/models/activity.dart](lib/models/activity.dart), [lib/models/user.dart](lib/models/user.dart) | These areas required collaboration: AI generated/adjusted code while I guided behavior, made edits, and validated outcomes. |
| ME Only | [lib/screens/login_screen.dart](lib/screens/login_screen.dart), [lib/screens/signup_screen.dart](lib/screens/signup_screen.dart), [lib/screens/onboarding_screen.dart](lib/screens/onboarding_screen.dart), [lib/screens/home_screen.dart](lib/screens/home_screen.dart), [lib/screens/my_activities_screen.dart](lib/screens/my_activities_screen.dart), [lib/screens/notifications_screen.dart](lib/screens/notifications_screen.dart) | These are simpler UI-driven screens and straightforward flows implemented and finalized directly by me. |

## Brief note on how AI was used

AI was used to speed up repetitive coding tasks, suggest code structure, and help troubleshoot compile/runtime issues. I then reviewed the suggestions, adjusted business rules where needed, and verified app behavior through local testing.
