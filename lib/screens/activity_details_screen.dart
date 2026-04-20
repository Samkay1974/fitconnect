import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../config/app_constants.dart';
import '../models/activity_type.dart';
import '../providers/activity_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/ui_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/primary_button.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final String activityId;

  const ActivityDetailsScreen({Key? key, required this.activityId})
    : super(key: key);

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().getActivityById(widget.activityId);
    });
  }

  Future<void> _handleJoinActivity() async {
    final authProvider = context.read<AuthProvider>();
    final activityProvider = context.read<ActivityProvider>();
    final uiProvider = context.read<UiProvider>();

    if (authProvider.currentUser == null) {
      uiProvider.showErrorMessage('Please login first');
      return;
    }

    final success = await activityProvider.joinActivity(
      widget.activityId,
      authProvider.currentUser!.id,
    );

    if (mounted) {
      if (success) {
        uiProvider.showSuccessMessage(AppConstants.successActivityJoined);
      } else {
        uiProvider.showErrorMessage(
          activityProvider.error ?? 'Failed to join activity',
        );
      }
    }
  }

  Future<void> _handleLeaveActivity() async {
    final authProvider = context.read<AuthProvider>();
    final activityProvider = context.read<ActivityProvider>();
    final uiProvider = context.read<UiProvider>();

    if (authProvider.currentUser == null) {
      uiProvider.showErrorMessage('Please login first');
      return;
    }

    final success = await activityProvider.leaveActivity(
      widget.activityId,
      authProvider.currentUser!.id,
    );

    if (mounted) {
      if (success) {
        uiProvider.showSuccessMessage(AppConstants.successActivityLeft);
      } else {
        uiProvider.showErrorMessage(
          activityProvider.error ?? 'Failed to leave activity',
        );
      }
    }
  }

  Future<void> _handleDeleteActivity() async {
    final activityProvider = context.read<ActivityProvider>();
    final uiProvider = context.read<UiProvider>();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete activity?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final success = await activityProvider.deleteActivity(widget.activityId);
    if (!mounted) {
      return;
    }

    if (success) {
      uiProvider.showSuccessMessage('Activity deleted successfully!');
      Navigator.pop(context);
      return;
    }

    uiProvider.showErrorMessage(
      activityProvider.error ?? 'Failed to delete activity',
    );
  }

  Future<void> _handleEditActivity() async {
    final activity = context.read<ActivityProvider>().selectedActivity;
    if (activity == null) {
      return;
    }

    await Navigator.of(
      context,
    ).pushNamed(AppConstants.routeCreateActivity, arguments: activity);

    if (mounted) {
      context.read<ActivityProvider>().getActivityById(widget.activityId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer2<ActivityProvider, AuthProvider>(
            builder: (context, activityProvider, authProvider, _) {
              final activity = activityProvider.selectedActivity;
              final isCreator =
                  activity != null &&
                  authProvider.currentUser != null &&
                  activity.createdBy == authProvider.currentUser!.id;
              if (!isCreator) {
                return const SizedBox.shrink();
              }

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: _handleEditActivity,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _handleDeleteActivity,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, activityProvider, _) {
          return Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Consumer<UiProvider>(
                builder: (context, uiProvider, _) {
                  if (activityProvider.isLoading) {
                    return const LoadingIndicator(
                      message: 'Loading activity...',
                    );
                  }

                  final activity = activityProvider.selectedActivity;
                  if (activity == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          const SizedBox(height: AppTheme.paddingMedium),
                          Text(
                            'Activity not found',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppTheme.paddingXLarge),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Go Back'),
                          ),
                        ],
                      ),
                    );
                  }

                  final dateFormatter = DateFormat('EEEE, MMM dd, yyyy HH:mm');
                  final dateStr = dateFormatter.format(activity.dateTime);
                  final isJoined = activity.participantIds.contains(
                    authProvider.currentUser?.id,
                  );

                  return Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.paddingLarge,
                          AppTheme.paddingLarge,
                          AppTheme.paddingLarge,
                          AppTheme.paddingXXXLarge,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (activity.imageUrl != null &&
                                activity.imageUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: _buildActivityImage(activity.imageUrl!),
                              ),
                            if (activity.imageUrl != null &&
                                activity.imageUrl!.isNotEmpty)
                              const SizedBox(height: AppTheme.paddingLarge),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(
                                AppTheme.paddingXLarge,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryDark,
                                    AppTheme.primaryColor,
                                    AppTheme.primaryLight.withValues(
                                      alpha: 0.95,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTheme.paddingMedium,
                                          vertical: AppTheme.paddingSmall,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppTheme.radiusSmall,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              _getTypeIcon(activity.type),
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              activity.type.displayName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isJoined)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppTheme.paddingMedium,
                                            vertical: AppTheme.paddingSmall,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppTheme.radiusSmall,
                                            ),
                                          ),
                                          child: const Text(
                                            'Joined',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.paddingLarge),
                                  Text(
                                    activity.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(
                                    height: AppTheme.paddingMedium,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          activity.location,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.paddingXLarge),

                            // Description
                            Container(
                              padding: const EdgeInsets.all(
                                AppTheme.paddingLarge,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusLarge,
                                ),
                                border: Border.all(
                                  color: AppTheme.primaryLight.withValues(
                                    alpha: 0.22,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'About this activity',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppTheme.paddingSmall),
                                  Text(
                                    activity.description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppTheme.paddingXXLarge),

                            // Details
                            _buildDetailRow(
                              context,
                              Icons.location_on_outlined,
                              'Location',
                              activity.location,
                            ),
                            const SizedBox(height: AppTheme.paddingMedium),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _openLocationDirections(activity.location),
                                icon: const Icon(
                                  Icons.location_searching_outlined,
                                ),
                                label: const Text('Find location'),
                              ),
                            ),
                            const SizedBox(height: AppTheme.paddingXLarge),
                            _buildDetailRow(
                              context,
                              Icons.access_time_outlined,
                              'Date & Time',
                              dateStr,
                            ),
                            const SizedBox(height: AppTheme.paddingXXLarge),

                            if (activity.creatorPhone != null &&
                                activity.creatorPhone!.trim().isNotEmpty) ...[
                              Text(
                                'Need more information?',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: AppTheme.paddingMedium),
                              Container(
                                padding: const EdgeInsets.all(
                                  AppTheme.paddingLarge,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.primaryLight.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      color: AppTheme.primaryDark,
                                    ),
                                    const SizedBox(
                                      width: AppTheme.paddingMedium,
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Call the organizer directly from your phone.',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: AppTheme.paddingMedium,
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _callCreator(activity.creatorPhone!),
                                      icon: const Icon(Icons.call_outlined),
                                      label: const Text('Call'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppTheme.paddingXXLarge),
                            ],

                            // Participants section
                            Text(
                              'Participants',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppTheme.paddingMedium),
                            Container(
                              padding: const EdgeInsets.all(
                                AppTheme.paddingLarge,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium,
                                ),
                                border: Border.all(
                                  color: AppTheme.primaryLight.withValues(
                                    alpha: 0.22,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${activity.participantCount} of ${activity.maxParticipants} joined',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(
                                            height: AppTheme.paddingSmall,
                                          ),
                                          Text(
                                            '${activity.availableSpots} spot${activity.availableSpots != 1 ? 's' : ''} available',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.people_outline,
                                        color: AppTheme.textSecondary,
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: AppTheme.paddingMedium,
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusSmall,
                                    ),
                                    child: LinearProgressIndicator(
                                      value:
                                          activity.participantCount /
                                          activity.maxParticipants,
                                      minHeight: 6,
                                      backgroundColor: AppTheme.borderColor,
                                      valueColor: const AlwaysStoppedAnimation(
                                        AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: AppTheme.paddingXXXLarge),
                          ],
                        ),
                      ),
                      // Floating message notification
                      if (uiProvider.successMessage != null)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Material(
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppTheme.paddingMedium,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium,
                                ),
                              ),
                              child: Text(
                                uiProvider.successMessage!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (uiProvider.errorMessage != null)
                        Positioned(
                          top: 16,
                          left: 16,
                          right: 16,
                          child: Material(
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppTheme.paddingMedium,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium,
                                ),
                              ),
                              child: Text(
                                uiProvider.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppTheme.primaryLight.withValues(alpha: 0.2),
            ),
          ),
        ),
        child: Consumer2<ActivityProvider, AuthProvider>(
          builder: (context, activityProvider, authProvider, _) {
            final activity = activityProvider.selectedActivity;
            if (activity == null) return const SizedBox.shrink();

            final isJoined = activity.participantIds.contains(
              authProvider.currentUser?.id,
            );
            final isFull = activity.isFull && !isJoined;

            return PrimaryButton(
              label: isJoined ? 'Leave Activity' : 'Join Activity',
              width: double.infinity,
              onPressed: isFull
                  ? null
                  : (isJoined ? _handleLeaveActivity : _handleJoinActivity),
            );
          },
        ),
      ),
    );
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.football:
        return Icons.sports_soccer;
      case ActivityType.aerobics:
        return Icons.directions_run;
      case ActivityType.jogging:
        return Icons.directions_run;
      case ActivityType.yoga:
        return Icons.self_improvement;
      case ActivityType.gym:
        return Icons.fitness_center;
      case ActivityType.swimming:
        return Icons.pool;
      case ActivityType.basketball:
        return Icons.sports_basketball;
      case ActivityType.tennis:
        return Icons.sports_tennis;
      case ActivityType.hiking:
        return Icons.terrain;
      case ActivityType.cycling:
        return Icons.pedal_bike;
    }
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: AppTheme.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: AppTheme.paddingSmall),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _callCreator(String phoneNumber) async {
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(scheme: 'tel', path: normalizedPhone);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openLocationDirections(String locationText) async {
    final destination = locationText.trim();
    if (destination.isEmpty) {
      _showLocationError(AppConstants.errorLocationNotFound);
      return;
    }

    try {
      final mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/${Uri.encodeComponent(destination)}',
      );
      final launched = await launchUrl(
        mapsUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showLocationError(AppConstants.errorLocationNotFound);
      }
    } catch (_) {
      _showLocationError(AppConstants.errorLocationNotFound);
    }
  }

  void _showLocationError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
      );
  }

  Widget _buildActivityImage(String imageUrl) {
    final isNetworkImage =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (isNetworkImage || kIsWeb) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildBrokenImagePlaceholder(),
      );
    }

    return Image.file(
      File(imageUrl),
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildBrokenImagePlaceholder(),
    );
  }

  Widget _buildBrokenImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 200,
      color: AppTheme.backgroundColor,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 36,
        color: AppTheme.textTertiary,
      ),
    );
  }
}
