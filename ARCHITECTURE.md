# Zenu Architecture Documentation

## Overview

Zenu follows Clean Architecture principles with clear separation of concerns, dependency injection, and testability at its core.

## Architecture Layers

### 1. Domain Layer (`lib/domain/`)

The innermost layer containing business logic and entities.

- **Entities**: Core business objects (Reminder, Statistics)
- **Use Cases**: Business logic operations (CreateReminder, CompleteReminder, etc.)
- **Repository Interfaces**: Contracts for data access
- **Value Objects**: Immutable value representations

### 2. Data Layer (`lib/data/`)

Implements repository interfaces and handles data operations.

- **Repositories**: Concrete implementations of domain repositories
- **Data Sources**: Local (SharedPreferences, SQLite) and Remote (API)
- **Models**: Data transfer objects with serialization
- **Mappers**: Convert between entities and models

### 3. Presentation Layer (`lib/presentation/`)

UI components and state management.

- **Pages**: Screen-level widgets
- **Widgets**: Reusable UI components
- **State**: Riverpod providers and state notifiers
- **View Models**: Presentation logic

### 4. Core Layer (`lib/core/`)

Shared utilities and constants.

- **Constants**: App-wide constants
- **Errors**: Exception and failure classes
- **Utils**: Helper functions and extensions
- **Theme**: Design system and theming

## Dependency Flow

``` bash
Presentation → Domain ← Data
     ↓           ↑        ↓
     └─────→ Core ←───────┘
```

## State Management (Riverpod)

### Provider Types

- **StateNotifierProvider**: For complex state with multiple operations
- **FutureProvider**: For async data fetching
- **StreamProvider**: For real-time data
- **Provider**: For computed values and dependencies

### State Classes

```dart
@freezed
class RemindersState with _$RemindersState {
  const factory RemindersState.initial() = _Initial;
  const factory RemindersState.loading() = _Loading;
  const factory RemindersState.loaded(List<Reminder> reminders) = _Loaded;
  const factory RemindersState.error(Failure failure) = _Error;
}
```

## Dependency Injection (get_it)

### Service Locator Setup

```dart
final sl = GetIt.instance;

Future<void> init() async {
  // Features
  sl.registerFactory(() => RemindersNotifier(sl()));
  
  // Use Cases
  sl.registerLazySingleton(() => GetReminders(sl()));
  sl.registerLazySingleton(() => CreateReminder(sl()));
  
  // Repositories
  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );
  
  // Data Sources
  sl.registerLazySingleton<ReminderLocalDataSource>(
    () => ReminderLocalDataSourceImpl(sl()),
  );
}
```

## Testing Strategy

### Unit Tests

- Test individual functions and classes
- Mock dependencies using mockito
- Coverage target: 80%

### Widget Tests

- Test UI components in isolation
- Use pump() and pumpAndSettle()
- Test user interactions

### Integration Tests

- Test complete user flows
- Use real implementations where possible
- Cover critical paths

### Test Structure

``` bash
test/
├── unit/
│   ├── domain/
│   ├── data/
│   └── presentation/
├── widget/
│   ├── pages/
│   └── widgets/
└── integration/
    └── flows/
```

## Error Handling

### Failure Types

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {}
class CacheFailure extends Failure {}
class NetworkFailure extends Failure {}
```

### Error Recovery

- Automatic retry with exponential backoff
- Offline mode with local caching
- User-friendly error messages
- Crash reporting integration

## Performance Optimizations

### Caching Strategy

- Memory cache for frequently accessed data
- Disk cache for persistence
- Cache invalidation policies
- Lazy loading for large datasets

### Code Splitting

- Feature-based module splitting
- Lazy loading of routes
- Tree shaking unused code

## Security Considerations

### Data Protection

- Encrypted local storage for sensitive data
- Secure key management
- No hardcoded secrets
- Input validation and sanitization

## Migration Plan

### Phase 1: Core Infrastructure (Week 1)

1. Set up clean architecture folders
2. Implement dependency injection
3. Create base classes and interfaces

### Phase 2: Domain Layer (Week 2)

1. Define entities and value objects
2. Create use cases
3. Define repository interfaces

### Phase 3: Data Layer (Week 3)

1. Implement repositories
2. Create data sources
3. Add caching layer

### Phase 4: Presentation Migration (Week 4)

1. Migrate to Riverpod
2. Create view models
3. Update UI components

### Phase 5: Testing (Week 5)

1. Add unit tests
2. Create widget tests
3. Implement integration tests

### Phase 6: Polish (Week 6)

1. Performance optimization
2. Error handling improvements
3. Documentation updates
