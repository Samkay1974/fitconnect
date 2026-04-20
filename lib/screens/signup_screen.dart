import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (input.length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }
    if (input.length > AppConstants.maxNameLength) {
      return AppConstants.errorInputTooLong;
    }
    if (!RegExp(r"^[a-zA-Z\s'\-]+$").hasMatch(input)) {
      return AppConstants.errorInvalidName;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final digitsOnly = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (digitsOnly.length != 10) {
      return AppConstants.errorInvalidPhoneNumber;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (input.length > AppConstants.maxEmailLength) {
      return AppConstants.errorInputTooLong;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input)) {
      return AppConstants.errorInvalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final input = value ?? '';
    if (input.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (input.length < AppConstants.minPasswordLength) {
      return AppConstants.errorWeakPassword;
    }
    if (input.length > AppConstants.maxPasswordLength) {
      return AppConstants.errorInputTooLong;
    }
    final hasUpper = RegExp(r'[A-Z]').hasMatch(input);
    final hasLower = RegExp(r'[a-z]').hasMatch(input);
    final hasNumber = RegExp(r'\d').hasMatch(input);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(input);
    if (!(hasUpper && hasLower && hasNumber && hasSpecial)) {
      return AppConstants.errorPasswordComplexity;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (value != _passwordController.text) {
      return AppConstants.errorPasswordMismatch;
    }
    return null;
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signup(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        phone: _phoneController.text.replaceAll(RegExp(r'\D'), ''),
        password: _passwordController.text,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pushReplacementNamed(AppConstants.routeHome);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Sign up failed'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingXLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                Text(
                  'Join FitConnect and start your fitness journey',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.paddingXXLarge),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        validator: _validateName,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppTheme.paddingXLarge),
                      CustomTextField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: AppTheme.paddingXLarge),
                      CustomTextField(
                        label: 'Phone Number',
                        hint: 'Enter a 10-digit phone number',
                        controller: _phoneController,
                        validator: _validatePhone,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: AppTheme.paddingXLarge),
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        validator: _validatePassword,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),
                      const SizedBox(height: AppTheme.paddingXLarge),
                      CustomTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        controller: _confirmPasswordController,
                        validator: _validateConfirmPassword,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),
                      const SizedBox(height: AppTheme.paddingXXLarge),
                      PrimaryButton(
                        label: 'Sign Up',
                        width: double.infinity,
                        isLoading: authProvider.isLoading,
                        onPressed: _handleSignup,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.paddingXLarge),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.paddingLarge),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.termsAndPoliciesTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Text(
                        AppConstants.termsAndPoliciesDisclaimer,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.paddingXLarge),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushReplacementNamed(AppConstants.routeLogin);
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
