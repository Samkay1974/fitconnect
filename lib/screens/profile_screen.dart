import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentUser != null) {
      _nameController.text = authProvider.currentUser!.name;
      _bioController.text = authProvider.currentUser!.bio ?? '';
    }
  }

  Future<void> _handleSaveProfile() async {
    final authProvider = context.read<AuthProvider>();
    final uiProvider = context.read<UiProvider>();

    final success = await authProvider.updateProfile(
      name: _nameController.text,
      bio: _bioController.text,
    );

    if (mounted) {
      if (success) {
        uiProvider.showSuccessMessage(AppConstants.successProfileUpdated);
        setState(() {
          _isEditMode = false;
        });
      } else {
        uiProvider.showErrorMessage(
          authProvider.error ?? 'Failed to update profile',
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        AppConstants.routeOnboarding,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.currentUser;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    'Not logged in',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed(
                        AppConstants.routeLogin,
                      );
                    },
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingXLarge),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(50),
                          image: user.avatar != null
                              ? DecorationImage(
                                  image: NetworkImage(user.avatar!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: user.avatar == null
                            ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Name
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      // Email
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppTheme.paddingMedium),
                      // Joined date
                      Text(
                        'Joined ${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.paddingXXLarge),

                // Edit Mode
                if (_isEditMode) ...[
                  CustomTextField(
                    label: 'Name',
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),
                  CustomTextField(
                    label: 'Bio',
                    hint: 'Tell us about yourself',
                    controller: _bioController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    minLines: 2,
                    prefixIcon: Icons.info_outline,
                  ),
                  const SizedBox(height: AppTheme.paddingXXLarge),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Save',
                          onPressed: _handleSaveProfile,
                          isLoading: authProvider.isLoading,
                        ),
                      ),
                      const SizedBox(width: AppTheme.paddingMedium),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Cancel',
                          isOutlined: true,
                          onPressed: () {
                            _loadUserData();
                            setState(() {
                              _isEditMode = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // View Mode
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.paddingLarge),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Text(
                        user.bio!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingXXLarge),
                  ],
                  // Edit Button
                  PrimaryButton(
                    label: 'Edit Profile',
                    width: double.infinity,
                    onPressed: () {
                      setState(() {
                        _isEditMode = true;
                      });
                    },
                  ),
                ],

                const SizedBox(height: AppTheme.paddingXXLarge),

                // Logout Button
                PrimaryButton(
                  label: 'Logout',
                  width: double.infinity,
                  isOutlined: true,
                  onPressed: _handleLogout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
