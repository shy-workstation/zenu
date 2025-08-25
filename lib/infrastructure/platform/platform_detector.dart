import 'dart:io';
import 'package:flutter/foundation.dart';

/// Platform detection service for conditional feature loading
class PlatformDetector {
  static PlatformDetector? _instance;
  
  factory PlatformDetector() {
    _instance ??= PlatformDetector._internal();
    return _instance!;
  }
  
  PlatformDetector._internal();

  /// Platform checks
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  bool get isLinux => !kIsWeb && Platform.isLinux;
  bool get isWeb => kIsWeb;

  /// Platform categories
  bool get isMobile => isAndroid || isIOS;
  bool get isDesktop => isWindows || isMacOS || isLinux;

  /// Feature capabilities
  bool get supportsNotifications => !isWeb;
  bool get supportsSystemTray => isDesktop && !isWeb;
  bool get supportsWindowManagement => isDesktop && !isWeb;
  bool get supportsBackgroundTasks => isMobile || isDesktop;
  bool get supportsBatteryOptimization => isAndroid;
  bool get supportsAppDelegate => isIOS;
  bool get supportsFileSystem => !isWeb;
  bool get supportsDeepLinking => !isWeb;
  bool get supportsBiometricAuth => isMobile;
  bool get supportsDeviceInfo => !isWeb;

  /// Get platform name
  String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (isWindows) return 'Windows';
    if (isMacOS) return 'macOS';
    if (isLinux) return 'Linux';
    if (isWeb) return 'Web';
    return 'Unknown';
  }

  /// Get platform version (requires additional platform-specific code)
  Future<String> getPlatformVersion() async {
    if (isWeb) return 'Web';
    
    try {
      return Platform.operatingSystemVersion;
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Check if specific version requirements are met
  Future<bool> meetsMinimumVersion({
    String? androidApiLevel,
    String? iOSVersion,
    String? windowsVersion,
  }) async {
    // This would typically integrate with platform-specific version checking
    // For now, return true as we don't have detailed version checking
    return true;
  }

  /// Debug information
  Map<String, dynamic> getPlatformInfo() {
    return {
      'platform': platformName,
      'isWeb': isWeb,
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'capabilities': {
        'notifications': supportsNotifications,
        'systemTray': supportsSystemTray,
        'windowManagement': supportsWindowManagement,
        'backgroundTasks': supportsBackgroundTasks,
        'batteryOptimization': supportsBatteryOptimization,
        'biometricAuth': supportsBiometricAuth,
      },
    };
  }
}