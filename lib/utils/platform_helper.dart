import 'dart:io';
import 'package:flutter/foundation.dart';

/// Simple platform detection utility
class PlatformHelper {
  static bool get isDesktop => 
    !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  
  static bool get isMobile => 
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  static bool get isWeb => kIsWeb;
  
  /// Features that work on desktop only
  static bool get supportsWindowManagement => isDesktop;
  static bool get supportsSystemTray => Platform.isWindows;
  
  /// Features that work on mobile only  
  static bool get supportsBackgroundTasks => isMobile;
  
  /// Features that work everywhere
  static bool get supportsNotifications => true;
}