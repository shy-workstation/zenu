import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

/// Mock notification adapter for testing platform-specific notifications
class MockNotificationAdapter extends Mock {
  // Mock methods for different platforms
  Future<bool> initialize() async => true;
  
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {}
  
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {}
  
  Future<void> cancelNotification(int id) async {}
  Future<void> cancelAllNotifications() async {}
  
  // Platform-specific methods
  Future<bool> requestPermissions() async => true;
  Future<bool> areNotificationsEnabled() async => true;
}

/// Mock system tray adapter for desktop platforms
class MockSystemTrayAdapter extends Mock {
  Future<void> initialize() async {}
  Future<void> setIcon(String iconPath) async {}
  Future<void> setTooltip(String tooltip) async {}
  Future<void> showContextMenu(List<MenuItem> items) async {}
  Future<void> dispose() async {}
}

/// Mock window manager adapter for desktop platforms
class MockWindowManagerAdapter extends Mock {
  Future<void> initialize() async {}
  Future<void> setTitle(String title) async {}
  Future<void> setMinimumSize(double width, double height) async {}
  Future<void> setMaximumSize(double width, double height) async {}
  Future<void> center() async {}
  Future<void> show() async {}
  Future<void> hide() async {}
  Future<bool> isVisible() async => true;
  Future<void> setAlwaysOnTop(bool alwaysOnTop) async {}
}

/// Mock shared preferences adapter
class MockSharedPreferencesAdapter extends Mock {
  final Map<String, dynamic> _storage = {};
  
  Future<bool> setString(String key, String value) async {
    _storage[key] = value;
    return true;
  }
  
  Future<bool> setBool(String key, bool value) async {
    _storage[key] = value;
    return true;
  }
  
  Future<bool> setInt(String key, int value) async {
    _storage[key] = value;
    return true;
  }
  
  Future<bool> setDouble(String key, double value) async {
    _storage[key] = value;
    return true;
  }
  
  Future<bool> setStringList(String key, List<String> value) async {
    _storage[key] = value;
    return true;
  }
  
  String? getString(String key) => _storage[key] as String?;
  bool? getBool(String key) => _storage[key] as bool?;
  int? getInt(String key) => _storage[key] as int?;
  double? getDouble(String key) => _storage[key] as double?;
  List<String>? getStringList(String key) => _storage[key] as List<String>?;
  
  Future<bool> remove(String key) async {
    _storage.remove(key);
    return true;
  }
  
  Future<bool> clear() async {
    _storage.clear();
    return true;
  }
  
  Set<String> getKeys() => _storage.keys.toSet();
  bool containsKey(String key) => _storage.containsKey(key);
  
  void reset() => _storage.clear();
}

/// Mock platform channel for testing platform-specific functionality
class MockPlatformChannel {
  static const MethodChannel _channel = MethodChannel('test/platform');
  
  static void setMockMethodCallHandler(Future<dynamic> Function(MethodCall call)? handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, handler);
  }
  
  static Future<T?> invokeMethod<T>(String method, [dynamic arguments]) {
    return _channel.invokeMethod<T>(method, arguments);
  }
  
  static void reset() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null);
  }
}

/// Mock file system adapter for testing file operations
class MockFileSystemAdapter extends Mock {
  final Map<String, String> _files = {};
  
  Future<String> readFile(String path) async {
    if (!_files.containsKey(path)) {
      throw Exception('File not found: $path');
    }
    return _files[path]!;
  }
  
  Future<void> writeFile(String path, String content) async {
    _files[path] = content;
  }
  
  Future<bool> fileExists(String path) async {
    return _files.containsKey(path);
  }
  
  Future<void> deleteFile(String path) async {
    _files.remove(path);
  }
  
  Future<List<String>> listFiles(String directory) async {
    return _files.keys
        .where((path) => path.startsWith(directory))
        .toList();
  }
  
  void reset() => _files.clear();
}

/// Test data generators for different platforms
class TestDataGenerator {
  static Map<String, dynamic> generateAndroidConfig() {
    return {
      'platform': 'android',
      'minSdkVersion': 21,
      'targetSdkVersion': 34,
      'compileSdkVersion': 34,
      'notifications': {
        'enabled': true,
        'channelId': 'zenu_reminders',
        'channelName': 'Zenu Reminders',
      },
    };
  }
  
  static Map<String, dynamic> generateiOSConfig() {
    return {
      'platform': 'ios',
      'minVersion': '12.0',
      'targetVersion': '17.0',
      'notifications': {
        'enabled': true,
        'permissions': ['alert', 'badge', 'sound'],
      },
    };
  }
  
  static Map<String, dynamic> generateWindowsConfig() {
    return {
      'platform': 'windows',
      'minVersion': '10.0.17763.0',
      'systemTray': {
        'enabled': true,
        'iconPath': 'assets/icon/app_icon.ico',
      },
      'notifications': {
        'enabled': true,
        'provider': 'winrt',
      },
    };
  }
  
  static Map<String, dynamic> generateMacOSConfig() {
    return {
      'platform': 'macos',
      'minVersion': '10.14',
      'notifications': {
        'enabled': true,
        'permissions': ['alert', 'badge', 'sound'],
      },
    };
  }
  
  static Map<String, dynamic> generateLinuxConfig() {
    return {
      'platform': 'linux',
      'notifications': {
        'enabled': true,
        'provider': 'freedesktop',
      },
    };
  }
}

/// MenuItem for system tray context menu
class MenuItem {
  const MenuItem({
    required this.label,
    this.onTap,
    this.enabled = true,
    this.separator = false,
  });
  
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool separator;
}