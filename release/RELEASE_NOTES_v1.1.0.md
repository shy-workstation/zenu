# Zenu v1.1.0 Release Notes

**Release Date:** March 9, 2026
**Store ID:** 9PHV0W6NVW2S

## What's New

### FloatingPill Notifications

We've completely redesigned the notification system with elegant, non-intrusive FloatingPill notifications that appear inline with your workflow. No more disruptive popups - just gentle reminders that blend seamlessly with your work.

### Swipeable Reminder Cards

Reminder cards now support intuitive swipe gestures for quick actions:
- Swipe right to mark complete
- Swipe left to snooze
- Improved state management for smoother animations

### Windows Notification Fixes

- Fixed notification action handling on Windows
- Proper parsing of notification body clicks
- Eliminated duplicate notifications
- Better integration with Windows notification center

### Performance Improvements

- **Batched Data Service**: More reliable data persistence with automatic retry logic
- **Memory Optimization**: Fixed memory leaks across multiple components
- **Cross-Platform**: Platform-specific optimizations for web, mobile, and desktop

### Better Localization

- Added missing translations
- Replaced all hardcoded strings with localized versions
- Improved support for German language

### Code Quality

- Resolved all static analyzer issues
- Improved code structure and maintainability
- Comprehensive test infrastructure added

## Upgrade Notes

This update is fully backward compatible. Your existing reminders and settings will be preserved.

## Bug Fixes

- Fixed merge conflict issues in swipeable reminder cards
- Resolved notification method references
- Fixed triggered notification flag clearing
- Improved code formatting throughout

## Technical Details

- Flutter 3.35.1+
- Dart 3.9.0+
- MSIX 3.16.12
- 78 commits since v1.0.2

## Feedback

We'd love to hear from you! Please rate us on the Microsoft Store or report issues through the store's feedback system.

---

Thank you for using Zenu - Your Personal Wellness Reminder Assistant!
