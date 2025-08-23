import 'dart:math';

/// Utility class for consistent duration formatting throughout the app
class DurationFormatter {
  /// Format a duration for display in German with consistent format
  /// Examples: "10 Min", "1 Min", "30 Sek", "1 Std 30 Min"
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      if (hours == 0) {
        return '${days} ${days == 1 ? 'Tag' : 'Tage'}';
      }
      return '${days} ${days == 1 ? 'Tag' : 'Tage'} ${hours} Std';
    }
    
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes == 0) {
        return '${hours} ${hours == 1 ? 'Std' : 'Std'}';
      }
      return '${hours} Std ${minutes} Min';
    }
    
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes} Min';
    }
    
    return '${max(duration.inSeconds, 0)} Sek';
  }

  /// Format duration for compact display (e.g., in KPI chips)
  /// Examples: "10m", "1m", "30s", "1h"
  static String formatDurationCompact(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h';
    }
    
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    
    return '${max(duration.inSeconds, 0)}s';
  }

  /// Format duration for settings/configuration (always in minutes)
  /// Examples: "10 Min", "1 Min", "120 Min"
  static String formatDurationSettings(Duration duration) {
    final minutes = duration.inMinutes;
    return '${minutes} Min';
  }

  /// Format interval for user-friendly display
  /// Examples: "Alle 10 Min", "Alle 30 Min", "Alle 2 Std"
  static String formatInterval(Duration interval) {
    if (interval.inHours > 0) {
      final hours = interval.inHours;
      return 'Alle ${hours} ${hours == 1 ? 'Std' : 'Std'}';
    }
    
    return 'Alle ${interval.inMinutes} Min';
  }

  /// Format time remaining with appropriate precision
  /// Examples: "In 5 Min", "In 30 Sek", "Überfällig"
  static String formatTimeRemaining(Duration duration) {
    if (duration.isNegative) {
      return 'Überfällig';
    }
    
    if (duration.inMinutes > 0) {
      return 'In ${duration.inMinutes} Min';
    }
    
    return 'In ${max(duration.inSeconds, 0)} Sek';
  }

  /// Format duration for accessibility announcements
  static String formatDurationA11y(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes == 0) {
        return '${hours} ${hours == 1 ? 'Stunde' : 'Stunden'}';
      }
      return '${hours} ${hours == 1 ? 'Stunde' : 'Stunden'} und ${minutes} ${minutes == 1 ? 'Minute' : 'Minuten'}';
    }
    
    if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      return '${minutes} ${minutes == 1 ? 'Minute' : 'Minuten'}';
    }
    
    final seconds = max(duration.inSeconds, 0);
    return '${seconds} ${seconds == 1 ? 'Sekunde' : 'Sekunden'}';
  }
}