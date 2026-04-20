# fitconnect

A new Flutter project.

## Cloudinary image uploads

Event images are uploaded to Cloudinary instead of Firebase Storage.

Setup steps:

1. Create a Cloudinary account.
2. In the Cloudinary console, create an unsigned upload preset.
3. Copy your Cloud name and upload preset into [lib/config/app_constants.dart](lib/config/app_constants.dart).
4. Keep the upload preset unsigned for the current Flutter client flow.

The app uploads event images through Cloudinary and stores the returned image URL in Firestore.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
