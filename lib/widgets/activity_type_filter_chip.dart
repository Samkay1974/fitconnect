import 'package:flutter/material.dart';
import '../models/activity_type.dart';
import '../config/app_theme.dart';

class ActivityTypeFilterChip extends StatelessWidget {
  final ActivityType type;
  final bool isSelected;
  final VoidCallback onSelected;

  const ActivityTypeFilterChip({
    Key? key,
    required this.type,
    required this.isSelected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        '${type.emoji} ${type.displayName}',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textPrimary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: AppTheme.backgroundColor,
      selectedColor: AppTheme.primaryColor,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
    );
  }
}
