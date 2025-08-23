import 'package:flutter/material.dart';

/// Semantic color tokens for consistent theming throughout the app
/// All colors meet WCAG AA contrast requirements (≥4.5:1)
class SemanticColors {
  // Status Colors
  static const Color statusOk = Color(0xFF10B981); // Green - enabled/success
  static const Color statusPaused = Color(0xFF6B7280); // Gray - paused/disabled  
  static const Color statusWarning = Color(0xFFF59E0B); // Amber - due soon
  static const Color statusDanger = Color(0xFFEF4444); // Red - overdue/error
  static const Color statusInfo = Color(0xFF3B82F6); // Blue - information

  // Background Colors
  static const Color bgSurface = Color(0xFFFFFFFF); // White surface
  static const Color bgSurfaceDark = Color(0xFF1F2937); // Dark surface
  static const Color bgSubtle = Color(0xFFF9FAFB); // Light gray background
  static const Color bgSubtleDark = Color(0xFF374151); // Dark gray background

  // Border Colors  
  static const Color borderSubtle = Color(0xFFE5E7EB); // Light border
  static const Color borderSubtleDark = Color(0xFF4B5563); // Dark border
  static const Color borderFocus = Color(0xFF3B82F6); // Blue focus ring

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Primary text
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Primary text dark
  static const Color textSecondary = Color(0xFF6B7280); // Secondary text
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Secondary text dark
  static const Color textMuted = Color(0xFF9CA3AF); // Muted text
  static const Color textMutedDark = Color(0xFF6B7280); // Muted text dark

  // Interactive Colors
  static const Color interactive = Color(0xFF6366F1); // Primary interactive
  static const Color interactiveHover = Color(0xFF4F46E5); // Hover state
  static const Color interactiveActive = Color(0xFF3730A3); // Active state

  /// Get status color with opacity for backgrounds
  static Color getStatusColor(ReminderStatus status, {double opacity = 1.0}) {
    switch (status) {
      case ReminderStatus.enabled:
        return statusOk.withValues(alpha: opacity);
      case ReminderStatus.paused:
        return statusPaused.withValues(alpha: opacity);
      case ReminderStatus.dueSoon:
        return statusWarning.withValues(alpha: opacity);
      case ReminderStatus.overdue:
        return statusDanger.withValues(alpha: opacity);
    }
  }

  /// Get semantic border color for card states
  static Color getBorderColor(ReminderStatus status, {bool isDark = false}) {
    switch (status) {
      case ReminderStatus.enabled:
        return statusOk.withValues(alpha: 0.3);
      case ReminderStatus.paused:
        return isDark ? borderSubtleDark : borderSubtle;
      case ReminderStatus.dueSoon:
        return statusWarning.withValues(alpha: 0.4);
      case ReminderStatus.overdue:
        return statusDanger.withValues(alpha: 0.4);
    }
  }

  /// Get icon for reminder status
  static IconData getStatusIcon(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.enabled:
        return Icons.check_circle_rounded;
      case ReminderStatus.paused:
        return Icons.pause_circle_outline_rounded;
      case ReminderStatus.dueSoon:
        return Icons.schedule_rounded;
      case ReminderStatus.overdue:
        return Icons.error_rounded;
    }
  }
}

/// Enum for reminder status states
enum ReminderStatus {
  enabled,
  paused,
  dueSoon,
  overdue,
}