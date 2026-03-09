# Zenu Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-03-09

### New Features

- **FloatingPill Notifications**: Redesigned notification system with elegant inline card-based notifications
- **Swipeable Reminder Cards**: Enhanced reminder cards with improved swipe gestures and state management
- **Cross-Platform Optimizations**: Added platform-specific optimizations for web, mobile, and desktop
- **Batched Data Service**: New data service with retry logic and exponential backoff for reliable data persistence
- **Platform Adapter Pattern**: Implemented clean architecture with platform-specific adapters

### Improvements

- **Windows Notifications**: Fixed notification action handling for Windows - proper parsing of notification body clicks
- **Notification Deduplication**: Prevents duplicate notifications and improves action handling
- **Better Localization**: Added missing translations and replaced hardcoded strings with localization
- **Performance**: Major performance optimization and feature enhancements
- **Memory Management**: Fixed critical bugs and memory leaks across multiple components
- **Code Quality**: Resolved all analyzer issues with improved code structure

### Technical Improvements

- Added comprehensive test infrastructure and test suites
- Improved logging with debugPrint for better debugging
- Refactored UI feedback mechanism for cleaner notifications
- Enhanced build and test documentation
- Unified stats and controls with consistent SpeedDial pattern
- Bottom controls redesigned with aligned buttons and stats drawer

### Bug Fixes

- Fixed merge conflict issues in swipeable_reminder_card.dart
- Resolved notification method references
- Fixed triggered notification flag clearing on action click
- Code formatting improvements for better readability

---

## [1.0.1] - 2025-08-20

### 🐛 Fixed

- Fixed all deprecated API usage (`withOpacity` → `withValues`)
- Resolved Provider package dependency issues
- Fixed compilation errors and warnings
- Removed unused code and imports
- Fixed color serialization issues
- Improved code quality and maintainability

### 🔧 Technical Improvements

- Updated to use modern Flutter APIs
- Fixed 54 analysis issues (reduced from 56 to 2)
- Improved performance with SizedBox optimization
- Enhanced future compatibility
- Added missing provider package dependency

### 📦 Dependencies

- Added `provider: ^6.1.2` for state management

---

## [1.0.0] - 2025-08-20

### 🎉 Initial Release

- Initial version of Zenyu - Personal Wellness Reminder Assistant
- Dynamic reminder system with customizable intervals
- Multi-platform support (Windows, macOS, Linux)
- Accessibility features and screen reader support
- Local notifications system
- Statistics and analytics dashboard
- Modern Material Design 3 UI
- Multiple reminder types (Water, Exercise, Medication, etc.)
- Swipe gestures and keyboard shortcuts
- Persistent data storage
- Theme support (Light/Dark mode)
- Localization support (English, German)

### ✨ Features

- **Smart Reminders**: Dynamic intervals based on user behavior
- **Accessibility**: Full screen reader and keyboard navigation support
- **Statistics**: Comprehensive analytics and progress tracking
- **Customization**: Personalized reminder types, colors, and icons
- **Performance**: Optimized memory usage and fast startup
- **Cross-platform**: Native performance on Windows, macOS, and Linux
