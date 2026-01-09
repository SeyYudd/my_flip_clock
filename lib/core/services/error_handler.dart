import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global error handler for the application
/// Handles API errors, permission errors, and native errors
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final _errorController = StreamController<AppError>.broadcast();
  Stream<AppError> get errorStream => _errorController.stream;

  /// Initialize global error handling
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _instance.handleError(
        AppError(
          type: ErrorType.flutter,
          message: details.exceptionAsString(),
          stackTrace: details.stack,
        ),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _instance.handleError(
        AppError(
          type: ErrorType.platform,
          message: error.toString(),
          stackTrace: stack,
        ),
      );
      return true;
    };
  }

  /// Handle any error in the app
  void handleError(AppError error) {
    debugPrint('🔴 ERROR [${error.type.name}]: ${error.message}');
    if (error.stackTrace != null) {
      debugPrint('Stack trace:\n${error.stackTrace}');
    }

    _errorController.add(error);

    // TODO: Send to Crashlytics when implemented
    // FirebaseCrashlytics.instance.recordError(error, error.stackTrace);
  }

  /// Handle API errors specifically
  void handleApiError(String apiName, dynamic error, {StackTrace? stackTrace}) {
    handleError(
      AppError(
        type: ErrorType.api,
        message: 'API Error ($apiName): ${error.toString()}',
        stackTrace: stackTrace,
      ),
    );
  }

  /// Handle permission errors
  void handlePermissionError(String permission, String reason) {
    handleError(
      AppError(
        type: ErrorType.permission,
        message: 'Permission Error ($permission): $reason',
      ),
    );
  }

  /// Handle native (Kotlin/Swift) errors
  void handleNativeError(String nativeMethod, dynamic error) {
    handleError(
      AppError(
        type: ErrorType.native,
        message: 'Native Error ($nativeMethod): ${error.toString()}',
      ),
    );
  }

  /// Show user-friendly error message
  static void showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
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

  void dispose() {
    _errorController.close();
  }
}

/// Error types in the application
enum ErrorType { flutter, platform, api, permission, native, unknown }

/// Structured error model
class AppError {
  final ErrorType type;
  final String message;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  AppError({required this.type, required this.message, this.stackTrace})
    : timestamp = DateTime.now();

  @override
  String toString() => '[$type] $message';
}
