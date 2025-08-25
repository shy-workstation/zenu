import 'package:get_it/get_it.dart';
import '../core/domain/repositories/reminder_repository.dart';
import '../core/domain/use_cases/create_reminder_use_case.dart';
import '../core/data/repositories/reminder_repository_impl.dart';
import '../infrastructure/adapters/storage_adapter.dart';
import '../infrastructure/platform/shared_preferences_storage_adapter.dart';
import '../infrastructure/platform/platform_detector.dart';

/// Dependency injection setup using GetIt service locator
class DependencyInjection {
  static final GetIt _getIt = GetIt.instance;
  static GetIt get instance => _getIt;

  /// Initialize all dependencies
  static Future<void> init() async {
    // Platform services
    _getIt.registerSingleton<PlatformDetector>(PlatformDetector());

    // Storage adapters - register based on platform
    await _registerStorageAdapter();

    // Repositories
    _getIt.registerLazySingleton<ReminderRepository>(
      () => ReminderRepositoryImpl(_getIt<StorageAdapter>()),
    );

    // Use cases
    _getIt.registerFactory(() => CreateReminderUseCase(_getIt<ReminderRepository>()));

    // Future: Presentation layer dependencies will be added here
    // _getIt.registerFactory(() => ReminderProvider(_getIt<CreateReminderUseCase>()));
  }

  /// Register storage adapter based on platform capabilities
  static Future<void> _registerStorageAdapter() async {
    // For now, use SharedPreferences for all platforms
    // In future iterations, we can add SQLite, secure storage, etc.
    // final platformDetector = _getIt<PlatformDetector>();
    final storageAdapter = SharedPreferencesStorageAdapter();
    await storageAdapter.initialize();
    
    _getIt.registerSingleton<StorageAdapter>(storageAdapter);
  }

  /// Register test dependencies (for testing)
  static void registerTestDependencies() {
    // This will be used in tests to register mock implementations
    _getIt.allowReassignment = true;
  }

  /// Reset dependencies (for testing)
  static void reset() {
    _getIt.reset();
  }
}