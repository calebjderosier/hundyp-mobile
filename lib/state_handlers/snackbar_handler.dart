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
    Duration? providedDuration,
  }) {
    if (_context == null) {
      throw Exception(
          'SnackBarHandler context is not set. Call setContext() first.');
    }

    // Rule of thumb for showing a snackbar is 1 second for every
    // ~10-12 characters, with a minimum of 2 seconds and a maximum of 10 seconds.
    final defaultDuration = providedDuration ??
        Duration(
          seconds: (message.length / 10).ceil().clamp(2, 10),
        );

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 24, // Larger font size for the text
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: defaultDuration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
