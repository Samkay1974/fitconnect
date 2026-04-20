class AppConstants {
  // App Info
  static const String appName = 'FitConnect';
  static const String appTagline = 'Find. Join. Stay Active';
  static const String appDescription =
      'Discover fitness and recreational activities near you. Connect with people who share your interests and stay active together.';

  // Route Names
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeSignup = '/signup';
  static const String routeHome = '/home';
  static const String routeActivityDetails = '/activity-details';
  static const String routeCreateActivity = '/create-activity';
  static const String routeMyActivities = '/my-activities';
  static const String routeProfile = '/profile';
  static const String routeEditProfile = '/edit-profile';
  static const String routeNotifications = '/notifications';

  // API Endpoints
  static const String apiBaseUrl = 'https://api.fitconnect.local';
  static const String apiAuthSignup = '/auth/signup';
  static const String apiAuthLogin = '/auth/login';
  static const String apiAuthLogout = '/auth/logout';
  static const String apiActivities = '/activities';
  static const String apiUsers = '/users';

  // Cloudinary Image Upload
  static const String cloudinaryCloudName = 'ddpekuo90';
  static const String cloudinaryUploadPreset = 'fitconnect';
  static const String cloudinaryUploadFolder = 'fitconnect/activity-images';

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 254;
  static const int minTitleLength = 3;
  static const int maxTitleLength = 100;
  static const int minDescriptionLength = 10;
  static const int maxDescriptionLength = 1000;
  static const int maxParticipants = 100;
  static const int minParticipants = 2;

  // UI Values
  static const int splashScreenDuration = 3; // seconds
  static const int snackbarDuration = 3; // seconds

  // Assets
  static const String assetsImagesPath = 'assets/images/';
  static const String assetsIconsPath = 'assets/icons/';

  // Mock data
  static const String mockAvatarUrl = 'https://i.pravatar.cc/150?img=';

  // Error Messages
  static const String errorNetworkConnection =
      'Network connection failed. Please try again.';
  static const String errorServerError =
      'Server error. Please try again later.';
  static const String errorUnauthorized = 'Unauthorized. Please login again.';
  static const String errorNotFound = 'Resource not found.';
  static const String errorInvalidCredentials = 'Invalid email or password.';
  static const String errorEmailAlreadyExists = 'Email already registered.';
  static const String errorPasswordMismatch = 'Passwords do not match.';
  static const String errorEmptyField = 'This field cannot be empty.';
  static const String errorInvalidEmail = 'Please enter a valid email.';
  static const String errorInvalidPhoneNumber =
      'Phone number must be exactly 10 digits.';
  static const String errorWeakPassword =
      'Password must be at least 8 characters.';
  static const String errorPasswordComplexity =
      'Password must include upper, lower, number, and special character.';
  static const String errorInvalidName =
      'Name can only include letters, spaces, hyphens, and apostrophes.';
  static const String errorInputTooLong =
      'Input is too long. Please shorten it and try again.';
  static const String errorLocationNotFound =
      'Location not found,contact organizer';

  // Terms and Policies
  static const String termsAndPoliciesTitle = 'Terms & Policies';
  static const String termsAndPoliciesDisclaimer =
      'FitConnect assumes all events listed on the platform are free and does not require any payment to join or participate. Any payment made to another person on the platform is strictly between the users involved, and FitConnect is not responsible or liable for those payments or disputes.';

  // Success Messages
  static const String successLoginSuccess = 'Login successful!';
  static const String successSignupSuccess = 'Account created successfully!';
  static const String successLogoutSuccess = 'Logged out successfully!';
  static const String successActivityJoined = 'Activity joined successfully!';
  static const String successActivityLeft = 'Left activity successfully!';
  static const String successActivityCreated = 'Event created successfully!';
  static const String successProfileUpdated = 'Profile updated successfully!';

  // Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration transitionDuration = Duration(milliseconds: 500);
}
