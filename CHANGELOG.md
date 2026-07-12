# Zenu Changelog

All notable changes to this project will be documented in this file.

## [1.1.1] - 2026-07-12

First **Android** release, alongside a Windows / Microsoft Store update. Builds on
the 1.1.0 store release with background reminders, a reworked bubble layout, and
numerous fixes.

### New

- **Android support**: signed App Bundle for Google Play, adaptive launcher icon,
  and a proper monochrome status-bar notification icon.
- **Orbital interface**: reminders live as bubbles orbiting a central start/pause
  control, with per-reminder countdown rings and an inactive shelf.
- **Background reminders on Android**: reminders are handed to the OS scheduler so
  they still fire when the app is backgrounded or closed (inexact alarms — no
  exact-alarm permission required).

### Improvements

- **Battery**: the 1-second UI timer now pauses while the app is backgrounded or
  minimised and catches up instantly on resume.
- **Rendering**: the animated orbital field is isolated in repaint boundaries so it
  no longer forces the whole screen to redraw every frame.
- **Bubble layout**: reminders are now placed on evenly-spaced concentric rings that
  scale with the reminder count and fill the screen's height, so they no longer
  overlap or crowd into a narrow band — especially in portrait. Adding or removing a
  reminder animates the others into their new positions.
- **Localization**: added German for the remaining reminder confirmations, unit
  labels, and accessibility descriptions.
- **Accessibility**: semantic labels and tooltips on the start/pause, add, reset,
  statistics, and reminder controls.

### Fixes

- Reminder notifications now show the Zenu icon instead of the default Flutter logo.
- Notifications are cancelled when a reminder is completed, disabled, or deleted.
- Closing the reminder overlay now sticks instead of reopening a second later.
- Typed intervals above the slider maximum are no longer silently reduced on save.
- Fixed a crash in split-screen / very small windows (orbital radius clamp).
- The triggered overlay scrolls so the Done button stays reachable in landscape
  and at large text sizes.

---

## [1.1.0] - 2026-03-09

Initial 1.1.0 store release (Microsoft Store).

### New Features

- **FloatingPill Notifications**: inline card-based notification system
- **Batched Data Service**: persistence with retry and exponential backoff
- **Platform Adapter Pattern**: platform-specific adapters
- Cross-platform optimizations for desktop, mobile, and web

### Improvements

- Windows notification action handling (notification body clicks)
- Notification deduplication and better localization
- Performance optimizations and memory-leak fixes

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
