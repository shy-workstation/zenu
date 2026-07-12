# Zenu - Personal Wellness Reminder Assistant

Your personal wellness companion that helps you maintain healthy habits throughout your workday with customizable reminders for eye rest, exercise, hydration, and more.

[![Microsoft Store](https://img.shields.io/badge/Microsoft%20Store-Download-blue?logo=microsoft)](https://apps.microsoft.com/detail/9PHV0W6NVW2S)
[![Version](https://img.shields.io/badge/version-1.1.0-green)](CHANGELOG.md)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20Windows-lightgrey)](https://flutter.dev)

## Download

**Android**: Google Play (coming with the 1.1.0 launch)

**Windows**: [Get it from the Microsoft Store](https://apps.microsoft.com/detail/9PHV0W6NVW2S)

## Features

- **Exercise Reminders**: Customizable pull-ups, push-ups, and workout reminders
- **Eye Rest**: 20-20-20 rule reminders for eye health
- **Movement Breaks**: Stand and move reminders to combat sedentary behavior
- **Hydration Tracking**: Water intake reminders throughout the day
- **Stretching**: Body stretch reminders to improve flexibility
- **Statistics Dashboard**: Daily, weekly, and all-time progress tracking
- **Fully Customizable**: Adjust intervals (slider up to 240 min, or type any value) and quantities per reminder
- **Orbital Interface**: Reminders orbit a central start/pause control with live countdown rings
- **Smart Notifications**: Native system notifications; on Android they fire even when the app is closed
- **Cross-Platform**: Android and Windows from a single Flutter codebase
- **Privacy-First**: All data stored locally, no cloud required
- **Dark/Light Theme**: Automatic theme support

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.7.0 or higher)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- For Windows desktop: [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/) with C++ development tools
- Android device/emulator or iOS device/simulator

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd zenu
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   ```bash
   # On connected device/emulator
   flutter run
   
   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

### Build for Release

```bash
# Windows (MSIX for Microsoft Store)
flutter pub run msix:create

# Windows (standalone)
flutter build windows --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# macOS
flutter build macos --release
```

## 📱 How to Use

1. **Start Reminders**: Tap the green "Start" floating action button
2. **Toggle Reminders**: Use switches on reminder cards to enable/disable
3. **Adjust Settings**: Tap the gear icon on any reminder card to customize:
   - Reminder intervals (1-120 minutes)
   - Exercise counts (1-50 reps)
4. **Complete Activities**: Use "Mark Complete" button when you finish an activity
5. **Track Progress**: Tap the chart icon in the app bar to view statistics
6. **Stop Reminders**: Tap the red "Stop" button when needed

## 🏗️ Project Structure

```
lib/
├── models/
│   ├── reminder.dart          # Reminder data model
│   └── statistics.dart        # Statistics tracking model
├── services/
│   ├── data_service.dart      # Local data storage
│   ├── notification_service.dart  # Push notifications
│   └── reminder_service.dart  # Core reminder logic
├── screens/
│   ├── home_screen.dart       # Main app interface
│   └── statistics_screen.dart # Progress dashboard
├── widgets/
│   └── reminder_card.dart     # Individual reminder cards
└── main.dart                  # App entry point
```

## 📋 Default Reminder Settings

| Reminder Type | Default Interval | Default Count | Color |
|---------------|------------------|---------------|-------|
| Eye Rest | 20 minutes | - | Blue |
| Stand Up | 40 minutes | - | Green |
| Pull-ups | 10 minutes | 4 reps | Red |
| Push-ups | 10 minutes | 5 reps | Orange |
| Water | 30 minutes | - | Cyan |
| Stretch | 45 minutes | - | Purple |

## Technologies Used

- **Flutter 3.35+** - Cross-platform framework
- **Dart 3.9+** - Programming language
- **SharedPreferences** - Local data persistence
- **Flutter Local Notifications** - Native system notifications
- **Material Design 3** - Modern UI design system
- **MSIX** - Windows Store packaging
- **Window Manager** - Desktop window control

## 📊 Statistics Features

- **Daily Progress**: Resets every day at midnight
- **Weekly Progress**: Resets every Monday
- **All-time Progress**: Cumulative totals since first use
- **Individual Tracking**: Separate counters for each reminder type
- **Visual Indicators**: Progress cards and charts

## 🔔 Notification Permissions

The app requires notification permissions to send health reminders. Grant permissions when prompted for the best experience.

## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Privacy

Zenu is designed with privacy-first principles. All data is stored locally on your device - no cloud sync, no tracking, no ads. See our [Privacy Policy](PRIVACY_POLICY.md) for details.

## Support

- **Windows Store**: [Microsoft Store Listing](https://apps.microsoft.com/detail/9PHV0W6NVW2S)
- **Issues**: [GitHub Issues](../../issues)
- **Changelog**: [View Changes](CHANGELOG.md)

## System Requirements

- Windows 10 (1903) or later / macOS 10.14+ / Linux
- 4 GB RAM minimum
- 200 MB free disk space

---

**Stay healthy and productive with Zenu!**
