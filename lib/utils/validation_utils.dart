import '../config/app_config.dart';

/// Input validation utilities
class ValidationUtils {
  /// Validates reminder title
  static ValidationResult validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return ValidationResult.error('Title is required');
    }

    if (title.trim().length > AppConfig.maxReminderTitleLength) {
      return ValidationResult.error(
        'Title must be ${AppConfig.maxReminderTitleLength} characters or less',
      );
    }

    return ValidationResult.valid();
  }

  /// Validates reminder description
  static ValidationResult validateDescription(String? description) {
    if (description != null &&
        description.length > AppConfig.maxReminderDescriptionLength) {
      return ValidationResult.error(
        'Description must be ${AppConfig.maxReminderDescriptionLength} characters or less',
      );
    }

    return ValidationResult.valid();
  }

  /// Validates reminder interval
  static ValidationResult validateInterval(Duration interval) {
    if (interval < AppConfig.minReminderInterval) {
      return ValidationResult.error(
        'Interval must be at least ${AppConfig.minReminderInterval.inMinutes} minutes',
      );
    }

    if (interval > AppConfig.maxReminderInterval) {
      return ValidationResult.error(
        'Interval cannot exceed ${AppConfig.maxReminderInterval.inDays} days',
      );
    }

    return ValidationResult.valid();
  }

  /// Validates quantity range
  static ValidationResult validateQuantityRange(int min, int max) {
    if (min < 1) {
      return ValidationResult.error('Minimum quantity must be at least 1');
    }

    if (max < min) {
      return ValidationResult.error(
        'Maximum quantity must be greater than minimum',
      );
    }

    if (max > AppConfig.maxSliderValue) {
      return ValidationResult.error(
        'Maximum quantity cannot exceed ${AppConfig.maxSliderValue.toInt()}',
      );
    }

    return ValidationResult.valid();
  }

  /// Validates step size
  static ValidationResult validateStepSize(int stepSize, int min, int max) {
    if (stepSize < 1) {
      return ValidationResult.error('Step size must be at least 1');
    }

    if (stepSize > (max - min)) {
      return ValidationResult.error(
        'Step size cannot be larger than the range',
      );
    }

    return ValidationResult.valid();
  }

  /// Validates reminder count limit
  static ValidationResult validateReminderCount(int currentCount) {
    if (currentCount >= AppConfig.maxReminders) {
      return ValidationResult.error(
        'Cannot exceed ${AppConfig.maxReminders} reminders',
      );
    }

    return ValidationResult.valid();
  }

  /// Sanitizes text input
  static String sanitizeText(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Validates email format (for future features)
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult.error('Email is required');
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.error('Please enter a valid email address');
    }

    return ValidationResult.valid();
  }

  /// Validates numeric input
  static ValidationResult validateNumeric(
    String? input, {
    double? min,
    double? max,
  }) {
    if (input == null || input.isEmpty) {
      return ValidationResult.error('Value is required');
    }

    final value = double.tryParse(input);
    if (value == null) {
      return ValidationResult.error('Please enter a valid number');
    }

    if (min != null && value < min) {
      return ValidationResult.error('Value must be at least $min');
    }

    if (max != null && value > max) {
      return ValidationResult.error('Value cannot exceed $max');
    }

    return ValidationResult.valid();
  }
}

/// Validation result model
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult._(this.isValid, this.error);

  factory ValidationResult.valid() => const ValidationResult._(true, null);
  factory ValidationResult.error(String message) =>
      ValidationResult._(false, message);

  @override
  String toString() => isValid ? 'Valid' : 'Error: $error';
}
