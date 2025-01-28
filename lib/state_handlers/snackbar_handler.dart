import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info }

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
    ToastType toastType = ToastType.info,
    Duration? providedDuration,
  }) {
    if (_context == null) {
      throw Exception(
          'SnackBarHandler context is not set. Call setContext() first.');
    }

    // Define colors and icons based on the toast type, using the app's theme.
    final colorScheme = Theme.of(_context).colorScheme;
    late Color backgroundColor;
    late IconData icon;

    switch (toastType) {
      case ToastType.success:
        backgroundColor = colorScheme.primary; // Cream/light blue for success
        icon = Icons.check_circle;
        break;
      case ToastType.error:
        backgroundColor = colorScheme.error; // Soft red for error
        icon = Icons.error;
        break;
      case ToastType.warning:
        backgroundColor = colorScheme.secondary; // Soft yellow for warning
        icon = Icons.warning;
        break;
      case ToastType.info:
      default:
        backgroundColor = colorScheme.surface; // Light blue for info
        icon = Icons.info;
    }

    // Rule of thumb for showing a snackbar is 1 second for every ~10-12 characters,
    // with a minimum of 2 seconds and a maximum of 10 seconds.
    final defaultDuration = providedDuration ??
        Duration(
          seconds: (message.length / 10).ceil().clamp(2, 10),
        );

    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: colorScheme.onPrimary, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary, // Text color based on theme
                ),
              ),
            ),
          ],
        ),
        duration: defaultDuration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }}
