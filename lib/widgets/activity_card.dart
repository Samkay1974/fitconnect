import 'dart:io';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' hide ActivityType;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_constants.dart';
import '../models/activity.dart';
import '../models/activity_type.dart';
import '../config/app_theme.dart';
import 'package:intl/intl.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final bool showCreator;

  const ActivityCard({
    Key? key,
    required this.activity,
    this.onTap,
    this.showCreator = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM dd, HH:mm');
    final dateStr = dateFormatter.format(activity.dateTime);
    final progress = (activity.participantCount / activity.maxParticipants)
        .clamp(0.0, 1.0);
    final typeIcon = _getTypeIcon(activity.type);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: _buildActivityImage(activity.imageUrl!),
                  ),
                ),
              if (activity.imageUrl != null && activity.imageUrl!.isNotEmpty)
                const SizedBox(height: AppTheme.paddingMedium),
              Container(
                height: 5,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              // Header with type and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(typeIcon, color: AppTheme.primaryDark),
                        ),
                        const SizedBox(width: AppTheme.paddingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Activity Title
                              Text(
                                activity.title,
                                style: Theme.of(context).textTheme.titleLarge,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppTheme.paddingXSmall),
                              // Activity Type
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.paddingSmall,
                                  vertical: AppTheme.paddingXSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSmall,
                                  ),
                                ),
                                child: Text(
                                  '${activity.type.emoji} ${activity.type.displayName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  if (activity.isFull)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: AppTheme.paddingXSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: const Text(
                        'Full',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.errorColor,
                        ),
                      ),
                    )
                  else if (activity.isUpcoming)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingSmall,
                        vertical: AppTheme.paddingXSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: const Text(
                        'Upcoming',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              // Location and Date
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Expanded(
                    child: Text(
                      activity.location,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              if (activity.location.trim().isNotEmpty) ...[
                const SizedBox(height: AppTheme.paddingMedium),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _openLocationDirections(context, activity.location),
                    icon: const Icon(Icons.location_searching_outlined),
                    label: const Text('Find location'),
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.paddingMedium),
              // Participants info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.paddingSmall),
                      Text(
                        '${activity.participantCount}/${activity.maxParticipants} joined',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  if (activity.isJoined)
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                ],
              ),
              if (activity.creatorPhone != null &&
                  activity.creatorPhone!.trim().isNotEmpty) ...[
                const SizedBox(height: AppTheme.paddingMedium),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _callCreator(activity.creatorPhone!),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Call organizer'),
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.paddingSmall),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _callCreator(String phoneNumber) async {
    final normalizedPhone = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri(scheme: 'tel', path: normalizedPhone);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openLocationDirections(
    BuildContext context,
    String locationText,
  ) async {
    try {
      final destination = locationText.trim();
      if (destination.isEmpty) {
        _showLocationError(context, AppConstants.errorLocationNotFound);
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError(
          context,
          'Please enable location services to get directions.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationError(
          context,
          'Location permission is required to get directions.',
        );
        return;
      }

      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Location> results;
      try {
        results = await locationFromAddress(destination);
      } catch (_) {
        _showLocationError(context, AppConstants.errorLocationNotFound);
        return;
      }

      if (results.isEmpty) {
        _showLocationError(context, AppConstants.errorLocationNotFound);
        return;
      }

      final target = results.first;
      final directionsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${currentPosition.latitude},${currentPosition.longitude}&destination=${target.latitude},${target.longitude}&travelmode=driving',
      );

      final launched = await launchUrl(
        directionsUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        _showLocationError(context, AppConstants.errorLocationNotFound);
      }
    } catch (_) {
      _showLocationError(context, AppConstants.errorLocationNotFound);
    }
  }

  void _showLocationError(BuildContext context, String message) {
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
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildBrokenImagePlaceholder(),
      );
    }

    return Image.file(
      File(imageUrl),
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildBrokenImagePlaceholder(),
    );
  }

  Widget _buildBrokenImagePlaceholder() {
    return Container(
      color: AppTheme.backgroundColor,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppTheme.textTertiary,
        size: 32,
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
}
