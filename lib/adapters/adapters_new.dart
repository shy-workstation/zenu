// Core adapter interfaces
export 'notification_adapter.dart';
export 'storage_adapter.dart';
export 'system_adapter.dart';

// Platform-specific implementations
export 'implementations/android_notification_adapter.dart';
export 'implementations/ios_notification_adapter.dart';
export 'implementations/desktop_notification_adapter.dart';
export 'implementations/shared_preferences_storage_adapter.dart';
export 'implementations/desktop_system_adapter.dart';

// Factory and service layer
export 'platform_adapter_factory.dart';
export 'adapter_service.dart';

// Usage examples and documentation
export 'example_usage.dart';
