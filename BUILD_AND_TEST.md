# Zenu Build and Test Instructions

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (latest stable)
- Platform-specific toolchains:
  - **Android**: Android Studio, SDK 21-34
  - **iOS**: Xcode 12+, iOS 12+
  - **Desktop**: Platform-specific build tools

### Local Development Setup

```bash
# 1. Get dependencies
flutter pub get

# 2. Generate code (if needed)
dart run build_runner build

# 3. Run tests
flutter test

# 4. Check code quality
flutter analyze
dart format . --dry-run
```

## 📱 Platform-Specific Builds

### Android

```bash
# Debug build
flutter build apk --debug

# Release build (requires signing)
flutter build apk --release

# Install on connected device
flutter install

# Run on emulator/device
flutter run --target lib/main.dart
```

### iOS

```bash
# Debug build for simulator
flutter build ios --simulator --debug

# Release build (requires certificates)
flutter build ios --release

# Run on simulator
flutter run -d "iPhone Simulator"

# Run on device
flutter run -d "Your iPhone"
```

### Desktop (Windows/macOS/Linux)

```bash
# Windows
flutter build windows --release
flutter run -d windows

# macOS
flutter build macos --release
flutter run -d macos

# Linux
flutter build linux --release
flutter run -d linux
```

## 🧪 Testing Strategy

### Unit Tests

```bash
# Run all unit tests
flutter test test/unit/

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Run specific test file
flutter test test/unit/core/domain/entities/reminder_entity_test.dart
```

### Integration Tests

```bash
# Run integration tests
flutter test integration_test/

# Run on specific device
flutter test integration_test/ -d "device_id"
```

### Widget Tests

```bash
# Run widget tests
flutter test test/widget/

# Run with verbose output
flutter test test/widget/ --verbose
```

## 🏗️ Architecture Validation

### Clean Architecture Compliance

```bash
# Check dependency direction
flutter pub deps --style=compact

# Analyze import dependencies
dart pub global activate dependency_validator
dependency_validator
```

### Platform Abstraction Verification

```bash
# Ensure no direct platform imports in core domain
grep -r "dart:io" lib/core/domain/ || echo "✅ Domain layer is platform-agnostic"

# Check adapter pattern usage
grep -r "Platform\." lib/core/ || echo "✅ No direct platform checks in core"
```

## 📊 Performance Testing

### App Performance

```bash
# Profile build
flutter run --profile --target lib/main.dart

# Memory profiling
flutter run --profile --trace-skia

# Performance overlay
flutter run --target lib/main.dart --enable-software-rendering
```

### Build Size Analysis

```bash
# Analyze APK size
flutter build apk --analyze-size

# Bundle analysis
flutter build appbundle --analyze-size
```

## 🔍 Quality Assurance

### Code Analysis

```bash
# Static analysis
flutter analyze

# Custom linting rules
dart analyze --fatal-infos

# Format check
dart format . --dry-run --set-exit-if-changed
```

### Security Audit

```bash
# Dependency audit
flutter pub deps --json | jq '.packages[].version'

# Check for hardcoded secrets (requires git-secrets)
git secrets --scan
```

## 🚀 CI/CD Pipeline

### GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - run: flutter build apk --debug
```

### Local CI Simulation

```bash
# Run the same checks as CI
./scripts/ci_local.sh
```

## 🐛 Debugging

### Debug Builds

```bash
# Debug mode with hot reload
flutter run --debug

# Debug with specific device
flutter run -d "device_name" --debug

# Debug web version
flutter run -d chrome --debug
```

### Logging

```bash
# View logs during development
flutter logs

# Filter logs by tag
flutter logs | grep "ZENU"
```

## 📦 Release Process

### Version Management

```bash
# Update version in pubspec.yaml
# Then create build
flutter build apk --release --build-name=1.0.5 --build-number=7
```

### Platform-Specific Releases

#### Android Release

```bash
# 1. Create release APK
flutter build apk --release

# 2. Create App Bundle for Play Store
flutter build appbundle --release

# 3. Sign and align (if not using automatic signing)
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 -keystore key.jks app-release-unsigned.apk alias_name
zipalign -v 4 app-release-unsigned.apk app-release.apk
```

#### iOS Release

```bash
# 1. Build for App Store
flutter build ios --release

# 2. Archive in Xcode or use command line
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner archive -archivePath build/Runner.xcarchive

# 3. Export IPA
xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportPath build/ -exportOptionsPlist ios/ExportOptions.plist
```

#### Desktop Release

```bash
# Windows
flutter build windows --release
# Output: build/windows/runner/Release/

# macOS
flutter build macos --release
# Output: build/macos/Build/Products/Release/

# Linux
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

## 🔧 Troubleshooting

### Common Issues

#### Build Failures

```bash
# Clean build cache
flutter clean
flutter pub get

# Reset pods (iOS/macOS)
cd ios && pod repo update && pod install
```

#### Platform-Specific Issues

```bash
# Android - Clear gradle cache
cd android && ./gradlew clean

# iOS - Clear derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Desktop - Clear CMake cache
rm -rf build/
```

### Performance Issues

```bash
# Profile the app
flutter run --profile

# Check for memory leaks
flutter run --profile --trace-skia
```

## 📚 Documentation

### Architecture Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Current architecture overview
- [ARCHITECTURE_PLAN.md](ARCHITECTURE_PLAN.md) - New clean architecture plan
- [API Documentation](docs/api/) - Generated API docs

### Generate Documentation

```bash
# Generate API documentation
dart doc .
```

## 🤝 Contributing

### Development Workflow

1. Create feature branch from `develop`
2. Implement changes following clean architecture
3. Write tests for new functionality
4. Run full test suite locally
5. Create pull request with tests passing

### Code Standards

- Follow clean architecture principles
- Use platform adapters for platform-specific code
- Maintain 80%+ test coverage
- Follow Flutter/Dart style guide
- Use meaningful commit messages

---

For questions or issues, please refer to the project documentation or create an issue in the repository.
