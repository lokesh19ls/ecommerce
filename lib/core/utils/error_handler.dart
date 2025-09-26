import 'package:flutter/material.dart';
import '../errors/failures.dart';

class ErrorHandler {
  static void handleError(BuildContext context, Failure failure) {
    String message;
    IconData icon;
    Color? backgroundColor;

    switch (failure.runtimeType) {
      case NetworkFailure:
        message = failure.message;
        icon = Icons.wifi_off;
        backgroundColor = Colors.orange;
        break;
      case ServerFailure:
        message = failure.message;
        icon = Icons.error_outline;
        backgroundColor = Colors.red;
        break;
      case AuthFailure:
        message = failure.message;
        icon = Icons.lock_outline;
        backgroundColor = Colors.red;
        break;
      case CacheFailure:
        message = failure.message;
        icon = Icons.storage;
        backgroundColor = Colors.amber;
        break;
      case ValidationFailure:
        message = failure.message;
        icon = Icons.warning_outlined;
        backgroundColor = Colors.orange;
        break;
      default:
        message = 'An unexpected error occurred';
        icon = Icons.error_outline;
        backgroundColor = Colors.red;
    }

    _showErrorSnackBar(context, message, icon, backgroundColor);
  }

  static void _showErrorSnackBar(
    BuildContext context,
    String message,
    IconData icon,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfoMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}
