# Zenu 🏥

A comprehensive Flutter app that helps you maintain healthy habits throughout your workday with customizable reminders for eye rest, exercise, hydration, and more.

## ✨ Features

- **🏋️ Exercise Reminders**: Pull-ups (4 reps) and push-ups (5 reps) every 10 minutes
- **👁️ Eye Rest**: 20-second eye breaks every 20 minutes  
- **🚶 Movement**: Stand and move reminders every 40 minutes
- **💧 Hydration**: Water intake reminders every 30 minutes
- **🤸 Stretching**: Body stretch reminders every 45 minutes
- **📊 Statistics**: Daily, weekly, and all-time progress tracking
- **⚙️ Customizable**: Adjust intervals (1-120 min) and exercise counts (1-50 reps)
- **🔔 Smart Notifications**: System notifications with sound and vibration
- **💾 Data Persistence**: All settings and stats saved locally

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
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
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

## 🛠️ Technologies Used

- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **SharedPreferences** - Local data persistence
- **Flutter Local Notifications** - System notifications
- **Material 3** - Modern UI design system

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

## 📞 Support

If you have any questions or need help, please [open an issue](../../issues) on GitHub.

---

**Stay healthy and productive! 💪**
