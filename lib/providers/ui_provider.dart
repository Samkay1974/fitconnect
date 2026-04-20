import 'package:flutter/material.dart';

class UiProvider extends ChangeNotifier {
  int _selectedBottomNavIndex = 0;
  String? _successMessage;
  String? _errorMessage;

  // Getters
  int get selectedBottomNavIndex => _selectedBottomNavIndex;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;

  // Set bottom nav index
  void setSelectedBottomNavIndex(int index) {
    _selectedBottomNavIndex = index;
    notifyListeners();
  }

  // Show success message
  void showSuccessMessage(String message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
    
    // Auto-clear after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_successMessage == message) {
        _successMessage = null;
        notifyListeners();
      }
    });
  }

  // Show error message
  void showErrorMessage(String message) {
    _errorMessage = message;
    _successMessage = null;
    notifyListeners();
    
    // Auto-clear after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_errorMessage == message) {
        _errorMessage = null;
        notifyListeners();
      }
    });
  }

  // Clear all messages
  void clearMessages() {
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }
}
