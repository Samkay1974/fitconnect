import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_constants.dart';
import '../models/activity.dart';
import '../models/activity_type.dart';
import '../providers/activity_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class CreateActivityScreen extends StatefulWidget {
  final Activity? existingActivity;

  const CreateActivityScreen({Key? key, this.existingActivity})
    : super(key: key);

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _maxParticipantsController;
  final ImagePicker _imagePicker = ImagePicker();

  String? _selectedImagePath;

  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1));
  ActivityType _selectedType = ActivityType.gym;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _maxParticipantsController = TextEditingController(
      text: AppConstants.maxParticipants.toString(),
    );

    final activity = widget.existingActivity;
    if (activity != null) {
      _titleController.text = activity.title;
      _descriptionController.text = activity.description;
      _locationController.text = activity.location;
      _maxParticipantsController.text = activity.maxParticipants.toString();
      _selectedDateTime = activity.dateTime;
      _selectedType = activity.type;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (value.length < AppConstants.minTitleLength) {
      return 'Title must be at least ${AppConstants.minTitleLength} characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    if (value.length < AppConstants.minDescriptionLength) {
      return 'Description must be at least ${AppConstants.minDescriptionLength} characters';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    return null;
  }

  String? _validateMaxParticipants(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.errorEmptyField;
    }
    final num = int.tryParse(value);
    if (num == null ||
        num < AppConstants.minParticipants ||
        num > AppConstants.maxParticipants) {
      return 'Participants must be between ${AppConstants.minParticipants} and ${AppConstants.maxParticipants}';
    }
    return null;
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (image == null || !mounted) {
      return;
    }

    setState(() {
      _selectedImagePath = image.path;
    });
  }

  Future<void> _handleCreateActivity() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final activityProvider = context.read<ActivityProvider>();
      final notificationProvider = context.read<NotificationProvider>();

      if (authProvider.currentUser == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Please login first'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        return;
      }

      final maxParticipants = int.parse(_maxParticipantsController.text);

      final success = widget.existingActivity == null
          ? await activityProvider.createActivity(
              title: _titleController.text,
              description: _descriptionController.text,
              imageFilePath: _selectedImagePath,
              type: _selectedType,
              location: _locationController.text,
              dateTime: _selectedDateTime,
              maxParticipants: maxParticipants,
              userId: authProvider.currentUser!.id,
              creatorPhone: authProvider.currentUser!.phone,
              createdByName: authProvider.currentUser!.name,
            )
          : await activityProvider.updateActivity(
              widget.existingActivity!.copyWith(
                title: _titleController.text,
                description: _descriptionController.text,
                type: _selectedType,
                location: _locationController.text,
                dateTime: _selectedDateTime,
                maxParticipants: maxParticipants,
              ),
              imageFilePath: _selectedImagePath,
            );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  widget.existingActivity == null
                      ? AppConstants.successActivityCreated
                      : 'Activity updated successfully!',
                ),
                backgroundColor: AppTheme.successColor,
              ),
            );
          if (widget.existingActivity == null &&
              authProvider.currentUser != null) {
            notificationProvider.fetchNotifications(
              authProvider.currentUser!.id,
            );
          }
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context, true);
            }
          });
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  activityProvider.error ?? 'Failed to create activity',
                ),
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
        title: Text(
          widget.existingActivity == null ? 'Create Activity' : 'Edit Activity',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, activityProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  CustomTextField(
                    label: 'Activity Title',
                    hint: 'e.g., Morning Jogging',
                    controller: _titleController,
                    validator: _validateTitle,
                    prefixIcon: Icons.title,
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),

                  // Type
                  Text(
                    'Activity Type',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingMedium,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                    child: DropdownButton<ActivityType>(
                      value: _selectedType,
                      onChanged: (type) {
                        if (type != null) {
                          setState(() {
                            _selectedType = type;
                          });
                        }
                      },
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ActivityType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text('${type.emoji} ${type.displayName}'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),

                  // Description
                  CustomTextField(
                    label: 'Description',
                    hint: 'Describe your activity',
                    controller: _descriptionController,
                    validator: _validateDescription,
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    minLines: 3,
                    prefixIcon: Icons.description_outlined,
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),

                  Text(
                    'Event Image (optional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  InkWell(
                    onTap: _pickImageFromGallery,
                    child: Container(
                      width: double.infinity,
                      height: 170,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        color: AppTheme.backgroundColor,
                      ),
                      child: _selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                              child: Image.file(
                                File(_selectedImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : (widget.existingActivity?.imageUrl != null &&
                                widget.existingActivity!.imageUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                              child: Image.network(
                                widget.existingActivity!.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: AppTheme.textTertiary,
                                    size: 36,
                                  ),
                                ),
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppTheme.textSecondary,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text('Tap to pick image from gallery'),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),

                  // Location
                  CustomTextField(
                    label: 'Location',
                    hint: 'e.g., Accra Sports Stadium',
                    controller: _locationController,
                    validator: _validateLocation,
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),

                  // Date & Time
                  Text(
                    'Date & Time',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  InkWell(
                    onTap: _selectDateTime,
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderColor),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: AppTheme.paddingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  '${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.textTertiary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingXLarge),

                  // Max Participants
                  CustomTextField(
                    label: 'Maximum Participants',
                    hint: 'e.g., 20',
                    controller: _maxParticipantsController,
                    validator: _validateMaxParticipants,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.people_outline,
                  ),
                  const SizedBox(height: AppTheme.paddingXXXLarge),

                  // Create Button
                  PrimaryButton(
                    label: widget.existingActivity == null
                        ? 'Create Activity'
                        : 'Save Changes',
                    width: double.infinity,
                    isLoading: activityProvider.isLoading,
                    onPressed: _handleCreateActivity,
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
