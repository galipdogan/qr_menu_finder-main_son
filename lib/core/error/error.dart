/// Central error handling exports for Clean Architecture
///
/// This file provides a single import point for all error-related classes.
///
/// Usage:
/// ```dart
/// import 'package:qr_menu_finder/core/error/error.dart';
/// ```
library;

// Exceptions (Data Layer)
export 'exceptions.dart';

// Failures (Domain Layer)
export 'failures.dart';

// User-friendly messages
export 'error_messages.dart';

// Error handling utilities
export 'error_handler.dart';
