import 'dart:async';

import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../models/activity_type.dart';
import '../services/activity_service.dart';
import '../utils/error_mapper.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _activityService;

  List<Activity> _activities = [];
  List<Activity> _filteredActivities = [];
  Activity? _selectedActivity;
  List<Activity> _userJoinedActivities = [];
  List<Activity> _userCreatedActivities = [];

  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<Activity>>? _activitiesSubscription;
  String? _currentUserId;

  // Filters
  String? _searchQuery;
  ActivityType? _selectedType;

  ActivityProvider(this._activityService);

  // Getters
  List<Activity> get activities {
    final hasActiveFilters =
        (_selectedType != null) || (_searchQuery != null && _searchQuery!.isNotEmpty);
    return hasActiveFilters ? _filteredActivities : _activities;
  }
  Activity? get selectedActivity => _selectedActivity;
  List<Activity> get userJoinedActivities => _userJoinedActivities;
  List<Activity> get userCreatedActivities => _userCreatedActivities;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ActivityType? get selectedType => _selectedType;

  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
    _syncUserActivityLists();
    notifyListeners();
  }

  // Get all activities
  Future<void> fetchActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _activitiesSubscription?.cancel();
    _activitiesSubscription = _activityService.streamActivities().listen(
      (activities) {
        _activities = activities;
        _applyFilters();
        _syncUserActivityLists();
        _isLoading = false;
        notifyListeners();
        if (_currentUserId != null) {
          _activityService.createUpcomingEventReminders(_currentUserId!);
        }
      },
      onError: (Object e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Get activity by ID
  Future<void> getActivityById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedActivity = await _activityService.getActivityById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search activities
  Future<void> searchActivities(String query) async {
    _searchQuery = query.trim();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter by type
  Future<void> filterByType(ActivityType? type) async {
    _selectedType = type;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _applyFilters();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Apply current filters
  void _applyFilters() {
    _filteredActivities = _activities;

    if (_selectedType != null) {
      _filteredActivities = _filteredActivities
          .where((activity) => activity.type == _selectedType)
          .toList();
    }

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      _filteredActivities = _filteredActivities
          .where((activity) =>
              activity.title.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
              activity.location.toLowerCase().contains(_searchQuery!.toLowerCase()))
          .toList();
    }
  }

  // Create activity
  Future<bool> createActivity({
    required String title,
    required String description,
    String? imageFilePath,
    String? imageUrl,
    required ActivityType type,
    required String location,
    required DateTime dateTime,
    required int maxParticipants,
    required String userId,
    String? createdByName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newActivity = await _activityService.createActivity(
        title: title,
        description: description,
        imageFilePath: imageFilePath,
        imageUrl: imageUrl,
        type: type,
        location: location,
        dateTime: dateTime,
        maxParticipants: maxParticipants,
        userId: userId,
        createdByName: createdByName,
      );
      _activities.add(newActivity);
      _applyFilters();
      _syncUserActivityLists();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Join activity
  Future<bool> joinActivity(String activityId, String userId) async {
    try {
      final updatedActivity = await _activityService.joinActivity(
        activityId: activityId,
        userId: userId,
      );

      // Update in list
      final index = _activities.indexWhere((a) => a.id == activityId);
      if (index != -1) {
        _activities[index] = updatedActivity;
      }

      // Update selected activity
      if (_selectedActivity?.id == activityId) {
        _selectedActivity = updatedActivity;
      }

      _applyFilters();
      _syncUserActivityLists();
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Leave activity
  Future<bool> leaveActivity(String activityId, String userId) async {
    try {
      final updatedActivity = await _activityService.leaveActivity(
        activityId: activityId,
        userId: userId,
      );

      // Update in list
      final index = _activities.indexWhere((a) => a.id == activityId);
      if (index != -1) {
        _activities[index] = updatedActivity;
      }

      // Update selected activity
      if (_selectedActivity?.id == activityId) {
        _selectedActivity = updatedActivity;
      }

      _applyFilters();
      _syncUserActivityLists();
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Get user joined activities
  Future<void> fetchUserJoinedActivities(String userId) async {
    _currentUserId = userId;
    _syncUserActivityLists();
    notifyListeners();
  }

  // Get user created activities
  Future<void> fetchUserCreatedActivities(String userId) async {
    _currentUserId = userId;
    _syncUserActivityLists();
    notifyListeners();
  }

  Future<bool> updateActivity(Activity activity, {String? imageFilePath}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _activityService.updateActivity(
        activity,
        imageFilePath: imageFilePath,
      );
      final index = _activities.indexWhere((a) => a.id == updated.id);
      if (index != -1) {
        _activities[index] = updated;
      }
      if (_selectedActivity?.id == updated.id) {
        _selectedActivity = updated;
      }
      _applyFilters();
      _syncUserActivityLists();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteActivity(String activityId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _activityService.deleteActivity(activityId);
      _activities.removeWhere((a) => a.id == activityId);
      _userJoinedActivities.removeWhere((a) => a.id == activityId);
      _userCreatedActivities.removeWhere((a) => a.id == activityId);
      if (_selectedActivity?.id == activityId) {
        _selectedActivity = null;
      }
      _applyFilters();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMapper.toMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear search
  void clearSearch() {
    clearFilters();
  }

  void clearFilters() {
    _searchQuery = null;
    _selectedType = null;
    _applyFilters();
    notifyListeners();
  }

  void _syncUserActivityLists() {
    if (_currentUserId == null) {
      _userJoinedActivities = [];
      _userCreatedActivities = [];
      return;
    }

    _userCreatedActivities = _activities
        .where((a) => a.createdBy == _currentUserId)
        .toList();
    _userJoinedActivities = _activities
        .where((a) => a.participantIds.contains(_currentUserId))
        .map((a) => a.copyWith(isJoined: true))
        .toList();
  }

  @override
  void dispose() {
    _activitiesSubscription?.cancel();
    super.dispose();
  }
}
