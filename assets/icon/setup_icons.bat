@echo off
echo ====================================
echo     Zenyu App - Icon Setup
echo ====================================
echo.

echo Step 1: Make sure you have downloaded app_icon.png from the browser
echo Step 2: Place it in the assets/icon/ folder
echo.

if not exist "app_icon.png" (
    echo ❌ ERROR: app_icon.png not found!
    echo Please download it from the HTML converter first.
    echo.
    pause
    exit /b 1
)

echo ✅ Found app_icon.png

echo.
echo Step 3: Installing flutter_launcher_icons...
flutter pub get

echo.
echo Step 4: Generating app icons for all platforms...
flutter pub run flutter_launcher_icons:main

if %errorlevel% equ 0 (
    echo.
    echo ✅ SUCCESS! App icons have been generated for all platforms.
    echo.
    echo The following icons were created:
    echo - Android: android/app/src/main/res/mipmap-*/launcher_icon.png
    echo - iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/
    echo - Windows: windows/runner/resources/app_icon.ico
    echo - macOS: macos/Runner/Assets.xcassets/AppIcon.appiconset/
    echo.
    echo You can now build your app with the new "Zenyu" branding!
    echo.
    echo Next steps:
    echo 1. flutter clean
    echo 2. flutter build windows --release
    echo.
) else (
    echo ❌ ERROR: Failed to generate icons
    echo Make sure flutter_launcher_icons is properly installed
)

pause
