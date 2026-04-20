import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../config/app_constants.dart';
import '../widgets/primary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white,
                AppTheme.accentColor.withValues(alpha: 0.38),
                AppTheme.primaryLight.withValues(alpha: 0.14),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.paddingXLarge,
              vertical: AppTheme.paddingXLarge,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: AppTheme.paddingLarge),
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.35),
                            blurRadius: 28,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: const [
                          Icon(Icons.sports_soccer, color: Colors.white, size: 50),
                          Positioned(
                            right: 20,
                            bottom: 20,
                            child: Icon(Icons.fitness_center, color: Colors.white, size: 24),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingXXLarge),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      AppConstants.appTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    Text(
                      AppConstants.appDescription,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Column(
                  children: [
                    _buildFeatureItem(
                      context,
                      icon: Icons.explore,
                      title: 'Discover Activities',
                      description: 'Football, aerobics, jogging and more near you',
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildFeatureItem(
                      context,
                      icon: Icons.groups_rounded,
                      title: 'Build Your Team',
                      description: 'Meet active people and join events in Ghana',
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),
                    _buildFeatureItem(
                      context,
                      icon: Icons.emoji_events_rounded,
                      title: 'Level Up Fitness',
                      description: 'Track joined sessions and stay motivated',
                    ),
                  ],
                ),
                Column(
                  children: [
                    PrimaryButton(
                      label: 'Start Exploring',
                      width: double.infinity,
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(
                          AppConstants.routeSignup,
                        );
                      },
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(
                              AppConstants.routeLogin,
                            );
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    {
    required IconData icon,
    required String title,
    required String description,
    }
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryDark),
          ),
          const SizedBox(width: AppTheme.paddingLarge),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppTheme.paddingXSmall),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
        ),
    );
  }
}
