import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/error_handler.dart';

/// Service for managing window state and preferences
class WindowService {
  static WindowService? _instance;
  static SharedPreferences? _prefs;

  static const String _windowWidthKey = 'window_width';
  static const String _windowHeightKey = 'window_height';
  static const String _windowXKey = 'window_x';
  static const String _windowYKey = 'window_y';
  static const String _windowMaximizedKey = 'window_maximized';
  static const String _windowFullscreenKey = 'window_fullscreen';

  // Default window settings
  static const double _defaultWidth = 1280;
  static const double _defaultHeight = 720;
  static const double _minWidth = 400;
  static const double _minHeight = 300;

  WindowService._();

  static Future<WindowService> getInstance() async {
    if (_instance == null) {
      _instance = WindowService._();
      _prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  /// Get saved window size or defaults
  WindowSize getWindowSize() {
    final width = _prefs?.getDouble(_windowWidthKey) ?? _defaultWidth;
    final height = _prefs?.getDouble(_windowHeightKey) ?? _defaultHeight;

    return WindowSize(
      width: width.clamp(_minWidth, double.infinity),
      height: height.clamp(_minHeight, double.infinity),
    );
  }

  /// Get saved window position or defaults
  WindowPosition getWindowPosition() {
    final x = _prefs?.getDouble(_windowXKey) ?? 100.0;
    final y = _prefs?.getDouble(_windowYKey) ?? 100.0;

    return WindowPosition(x: x, y: y);
  }

  /// Get window state
  WindowState getWindowState() {
    final isMaximized = _prefs?.getBool(_windowMaximizedKey) ?? false;
    final isFullscreen = _prefs?.getBool(_windowFullscreenKey) ?? false;

    return WindowState(isMaximized: isMaximized, isFullscreen: isFullscreen);
  }

  /// Save window size
  Future<void> saveWindowSize(double width, double height) async {
    try {
      await _prefs?.setDouble(_windowWidthKey, width);
      await _prefs?.setDouble(_windowHeightKey, height);

      if (kDebugMode) {
        debugPrint('💾 Window size saved: ${width}x$height');
      }
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'WindowService.saveWindowSize',
        severity: ErrorSeverity.warning,
      );
    }
  }

  /// Save window position
  Future<void> saveWindowPosition(double x, double y) async {
    try {
      await _prefs?.setDouble(_windowXKey, x);
      await _prefs?.setDouble(_windowYKey, y);

      if (kDebugMode) {
        debugPrint('💾 Window position saved: ($x, $y)');
      }
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'WindowService.saveWindowPosition',
        severity: ErrorSeverity.warning,
      );
    }
  }

  /// Save window state
  Future<void> saveWindowState({bool? isMaximized, bool? isFullscreen}) async {
    try {
      if (isMaximized != null) {
        await _prefs?.setBool(_windowMaximizedKey, isMaximized);
      }
      if (isFullscreen != null) {
        await _prefs?.setBool(_windowFullscreenKey, isFullscreen);
      }

      if (kDebugMode) {
        debugPrint(
          '💾 Window state saved: max=$isMaximized, full=$isFullscreen',
        );
      }
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'WindowService.saveWindowState',
        severity: ErrorSeverity.warning,
      );
    }
  }

  /// Reset window settings to defaults
  Future<void> resetToDefaults() async {
    try {
      await _prefs?.remove(_windowWidthKey);
      await _prefs?.remove(_windowHeightKey);
      await _prefs?.remove(_windowXKey);
      await _prefs?.remove(_windowYKey);
      await _prefs?.remove(_windowMaximizedKey);
      await _prefs?.remove(_windowFullscreenKey);

      ErrorHandler.logInfo('Window settings reset to defaults');
    } catch (e, stackTrace) {
      await ErrorHandler.handleError(
        e,
        stackTrace,
        context: 'WindowService.resetToDefaults',
        severity: ErrorSeverity.warning,
      );
    }
  }

  /// Get all window settings
  WindowSettings getAllSettings() {
    return WindowSettings(
      size: getWindowSize(),
      position: getWindowPosition(),
      state: getWindowState(),
    );
  }

  /// Check if current settings are defaults
  bool isUsingDefaults() {
    return !(_prefs?.containsKey(_windowWidthKey) ?? false) &&
        !(_prefs?.containsKey(_windowHeightKey) ?? false) &&
        !(_prefs?.containsKey(_windowXKey) ?? false) &&
        !(_prefs?.containsKey(_windowYKey) ?? false);
  }

  /// Validate and constrain window size
  WindowSize constrainWindowSize(double width, double height) {
    final constrainedWidth = width.clamp(_minWidth, double.infinity);
    final constrainedHeight = height.clamp(_minHeight, double.infinity);

    return WindowSize(width: constrainedWidth, height: constrainedHeight);
  }

  /// Get minimum window size
  WindowSize get minWindowSize =>
      const WindowSize(width: _minWidth, height: _minHeight);

  /// Get default window size
  WindowSize get defaultWindowSize =>
      const WindowSize(width: _defaultWidth, height: _defaultHeight);
}

/// Window size data class
class WindowSize {
  final double width;
  final double height;

  const WindowSize({required this.width, required this.height});

  @override
  String toString() => '${width}x$height';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowSize &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}

/// Window position data class
class WindowPosition {
  final double x;
  final double y;

  const WindowPosition({required this.x, required this.y});

  @override
  String toString() => '($x, $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowPosition &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

/// Window state data class
class WindowState {
  final bool isMaximized;
  final bool isFullscreen;

  const WindowState({required this.isMaximized, required this.isFullscreen});

  @override
  String toString() => 'maximized=$isMaximized, fullscreen=$isFullscreen';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowState &&
          runtimeType == other.runtimeType &&
          isMaximized == other.isMaximized &&
          isFullscreen == other.isFullscreen;

  @override
  int get hashCode => isMaximized.hashCode ^ isFullscreen.hashCode;
}

/// Complete window settings
class WindowSettings {
  final WindowSize size;
  final WindowPosition position;
  final WindowState state;

  const WindowSettings({
    required this.size,
    required this.position,
    required this.state,
  });

  @override
  String toString() => 'size=$size, position=$position, state=$state';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowSettings &&
          runtimeType == other.runtimeType &&
          size == other.size &&
          position == other.position &&
          state == other.state;

  @override
  int get hashCode => size.hashCode ^ position.hashCode ^ state.hashCode;
}
