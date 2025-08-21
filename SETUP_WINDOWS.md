# Windows Setup Guide for Health Reminder App

## 🔧 Fixing Visual Studio Toolchain Issues

The error you're seeing indicates that Flutter can't find the required Visual Studio tools for Windows desktop development.

### Quick Fix Steps:

1. **Install Visual Studio 2022 Community** (Free)
   - Download from: https://visualstudio.microsoft.com/downloads/
   - During installation, make sure to select:
     - ✅ **Desktop development with C++** workload
     - ✅ **CMake tools for C++**
     - ✅ **Windows 11 SDK** (latest version)

2. **Alternative: Install Build Tools Only**
   If you don't want the full Visual Studio IDE:
   - Download **Visual Studio Build Tools 2022**
   - Install with the same C++ components listed above

3. **Verify Installation**
   ```powershell
   flutter doctor -v
   ```
   Look for the Windows toolchain section - it should show ✅ instead of ❌

4. **Enable Developer Mode** (Already done)
   ```powershell
   start ms-settings:developers
   ```
   Turn on "Developer Mode" in Windows Settings.

### Running the App:

```powershell
# Clean and get dependencies
flutter clean
flutter pub get

# Run on Windows desktop
flutter run -d windows

# Or run on web (no toolchain needed)
flutter run -d chrome
```

### Alternative: Run on Web Instead

If you don't want to install Visual Studio, you can run the app in a web browser:

```powershell
flutter run -d chrome
```

This requires no additional setup and will work immediately.

### Troubleshooting:

**If you still get toolchain errors:**

1. **Restart your terminal** after installing Visual Studio
2. **Check Flutter doctor:**
   ```powershell
   flutter doctor -v
   ```
3. **Update Flutter:**
   ```powershell
   flutter upgrade
   ```
4. **Clean and rebuild:**
   ```powershell
   flutter clean
   flutter pub get
   ```

### Expected Output After Fix:

When `flutter doctor` works correctly, you should see:
```
✓ Flutter (Channel stable, 3.x.x, on Microsoft Windows...)
✓ Windows Version (Installed version of Windows is version 10 or higher)
✓ Android toolchain - develop for Android devices
✓ Visual Studio - develop for Windows (Visual Studio Community 2022 17.x.x)
✓ VS Code (version x.x.x)
```

### Quick Start Commands:

```powershell
# Full setup sequence
flutter clean
flutter pub get
flutter run -d windows

# If Windows doesn't work, use web:
flutter run -d chrome
```

The app will work perfectly on both Windows desktop and web!