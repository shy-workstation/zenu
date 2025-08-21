# Zenyu Health Reminder App - TODOs

## High Priority Tasks

### 🎨 Icon Generation

- [ ] **Create PNG versions of app icons from SVG files**
  - **Issue**: `flutter_launcher_icons` doesn't support SVG files directly
  - **Files needed**:
    - `assets/icon/app_icon.svg` → `app_icon.png` (512x512)
    - `assets/icon/app_icon_clean.svg` → `app_icon_clean.png` (512x512)
  - **Solutions to try**:
    1. Install Inkscape: <https://inkscape.org/>
    2. Install ImageMagick: <https://imagemagick.org/>
    3. Use online converter: <https://cloudconvert.com/svg-to-png>
    4. Use Python packages: `pip install cairosvg pillow`
  - **Commands after conversion**:

    ```bash
    flutter pub run flutter_launcher_icons
    flutter clean
    flutter build windows --release
    ```

## Medium Priority Tasks

### 🐛 Bug Fixes

- [ ] Fix any remaining animation issues with morph blob
- [ ] Test reminder timer pause/resume functionality
- [ ] Verify energy glow animation performance

### 🔧 Code Quality

- [ ] Run `flutter analyze` and fix any warnings
- [ ] Update documentation if needed
- [ ] Test app on different screen sizes

## Low Priority Tasks

### ✨ Enhancements

- [ ] Consider adding more animation effects
- [ ] Optimize app performance
- [ ] Add more reminder types if needed

---

**Last Updated**: August 20, 2025
**Version**: 1.0.1
