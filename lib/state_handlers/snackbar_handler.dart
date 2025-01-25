import 'package:flutter/material.dart';

class SnackBarHandler {
  static final SnackBarHandler _instance = SnackBarHandler._internal();
  late BuildContext _context;

  SnackBarHandler._internal();

  // Singleton instance
  factory SnackBarHandler() {
    return _instance;
  }

  // Initialize the service with the app's context
  void setContext(BuildContext context) {
    _context = context;
  }

  // Show a SnackBar
  void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 6),
  }) {
    if (_context == null) {
      throw Exception('SnackBarHandler context is not set. Call setContext() first.');
    }

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
