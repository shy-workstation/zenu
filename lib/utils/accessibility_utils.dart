import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for screen readers and assistive technologies
class AccessibilityUtils {
  /// Announces text to screen readers with proper direction
  static void announce(String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announces focus changes after navigation or state updates
  static void announceFocusChange(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);

    // Move focus to first focusable element after frame builds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        final focusScope = FocusScope.of(context);
        if (focusScope.focusedChild == null) {
          focusScope.requestFocus(FocusNode());
        }
      }
    });
  }

  /// Creates accessible semantics for interactive elements
  static Semantics createAccessibleAction({
    required Widget child,
    required String label,
    String? hint,
    VoidCallback? onTap,
    bool isButton = false,
    bool isEnabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      enabled: isEnabled,
      onTap: onTap,
      child: child,
    );
  }

  /// Creates accessible form field semantics
  static Semantics createAccessibleFormField({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool isRequired = false,
    bool hasError = false,
    String? errorMessage,
  }) {
    String fullLabel = label;
    if (isRequired) fullLabel += ', required';
    if (value != null) fullLabel += ', current value $value';
    if (hasError && errorMessage != null) fullLabel += ', error: $errorMessage';

    return Semantics(
      label: fullLabel,
      hint: hint,
      textField: true,
      child: child,
    );
  }

  /// Creates accessible live region for dynamic content
  static Semantics createLiveRegion({
    required Widget child,
    required String label,
    bool isPolite = true,
  }) {
    return Semantics(label: label, liveRegion: true, child: child);
  }

  /// Focus management for keyboard navigation
  static Widget createKeyboardNavigable({
    required Widget child,
    required VoidCallback? onActivate,
    VoidCallback? onSpace,
    VoidCallback? onEnter,
    String? focusLabel,
  }) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space && onSpace != null) {
            onSpace();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter && onEnter != null) {
            onEnter();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(label: focusLabel, focusable: true, child: child),
    );
  }

  /// Ensures minimum touch target size
  static Widget ensureTouchTarget({
    required Widget child,
    double minSize = 44.0,
  }) {
    return Container(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      child: child,
    );
  }

  /// Creates accessible timer/countdown display
  static Widget createAccessibleTimer({
    required String timeValue,
    required String label,
    Color? color,
  }) {
    return Semantics(
      label: '$label, $timeValue remaining',
      liveRegion: true,
      child: Text(
        timeValue,
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Provides haptic feedback for actions
  static void provideFeedback(VoidCallback? customFeedback) {
    HapticFeedback.lightImpact();
    customFeedback?.call();
  }

  /// Format duration for screen readers
  static String formatDurationForA11y(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} hours and ${duration.inMinutes.remainder(60)} minutes';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutes and ${duration.inSeconds.remainder(60)} seconds';
    } else {
      return '${duration.inSeconds} seconds';
    }
  }

  /// Check if user prefers reduced motion
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
}
