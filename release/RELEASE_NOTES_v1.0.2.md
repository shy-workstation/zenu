# Zenu v1.0.2 Release Notes

**Release Date:** August 21, 2025  
**Build Number:** 3  
**Platform:** Windows x64

---

## 🎨 **Zenu v1.0.2 - Rebranding Release**

This release introduces a fresh new identity for the app with updated branding and visual improvements.

---

## 🔄 **Major Changes**

### **App Rebranding**

- ✅ **New App Name** - Changed from "Zenyu" to "Zenu" for better branding
- ✅ **Updated App Icon** - New icon design using `app_icon_zenu.png`  
- ✅ **Executable Rename** - Application now launches as `Zenu.exe`
- ✅ **Launch Script Update** - Updated `Launch Zenu.bat` with new branding
- ✅ **Complete UI Update** - Fixed all remaining "Zenyu" references in the interface

### **Technical Updates**

- ✅ **Flutter Launcher Icons** - Generated new icon sets for all platforms from PNG source
- ✅ **Windows Resources** - Updated .rc files with new app information
- ✅ **Localization Files** - Manually fixed and updated all localization strings
- ✅ **Code References** - Updated all "Zenyu" references to "Zenu" throughout codebase
- ✅ **Version Bump** - Updated to version 1.0.2+3

### **Bug Fixes**

- ✅ **Fixed Localization Generation** - Resolved issues with auto-generated translation files
- ✅ **Added Missing Strings** - Added `noRemindersTitle`, `noRemindersSubtitle`, `getStarted` strings
- ✅ **Corrected App Title** - Fixed window title and all UI text to show "Zenu"

---

## 🛠 **Technical Details**

### **Icon Generation Process**
- Used `flutter_launcher_icons` package for automatic icon generation
- PNG source file provides better quality than SVG conversion
- Generated icons for Windows, macOS, iOS, and Android platforms

### **Build Information**
- **Flutter Version:** 3.35.1+
- **Dart Version:** 3.9.0
- **Build Configuration:** Release (optimized)
- **Target Platform:** Windows x64

---

## 📦 **Installation**

1. Extract the release files to your desired directory
2. Run `Launch Zenu.bat` or double-click `Zenu.exe` directly
3. Allow Windows permissions for notifications when prompted

---

## 🔄 **Upgrade from Previous Version**

If upgrading from Zenyu v1.0.1:
- Your existing reminder data will be preserved
- Launch script has been updated - use the new `Launch Zenu.bat`
- The app will appear with the new Zenu branding and icon

---

## 🐛 **Bug Fixes & Stability**

This release maintains all the stability improvements from v1.0.1:
- Fixed deprecated API calls
- Enhanced type safety
- Improved null safety and type annotations
- Optimized performance

---

## 📈 **What's Next**

Future releases will focus on:
- New reminder types and customization options
- Enhanced statistics and analytics
- Dark mode improvements
- Additional notification options

---

## 💬 **Feedback**

We value your feedback! The rebranding to "Zenu" reflects our commitment to a cleaner, more focused wellness experience.

---

*Built with ❤️ for your wellness journey with Zenu*
