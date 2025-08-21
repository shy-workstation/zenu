@echo off
setlocal enabledelayedexpansion

echo ============================================
echo     Building Zenu for Windows Production
echo ============================================
echo.

REM Check if Flutter is available
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    exit /b 1
)

REM Get current directory
set PROJECT_DIR=%CD%
set RELEASE_DIR=%PROJECT_DIR%\release
set BUILD_DIR=%PROJECT_DIR%\build\windows\x64\runner\Release

echo 📁 Project Directory: %PROJECT_DIR%
echo 📁 Release Directory: %RELEASE_DIR%
echo.

REM Clean previous builds
echo 🧹 Cleaning previous builds...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%RELEASE_DIR%\*.exe" del /q "%RELEASE_DIR%\*.exe"
if exist "%RELEASE_DIR%\*.dll" del /q "%RELEASE_DIR%\*.dll"

echo.

REM Get dependencies
echo 📦 Getting Flutter dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies
    exit /b 1
)

echo.

REM Generate build files
echo ⚙️ Generating build files...
flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo WARNING: Build runner failed, continuing...
)

echo.

REM Run tests
echo 🧪 Running tests...
flutter test
if %errorlevel% neq 0 (
    echo WARNING: Some tests failed, but continuing build...
)

echo.

REM Build for Windows
echo 🏗️ Building Windows release...
flutter build windows --release --verbose
if %errorlevel% neq 0 (
    echo ERROR: Flutter build failed
    exit /b 1
)

echo.

REM Create release directory
if not exist "%RELEASE_DIR%" mkdir "%RELEASE_DIR%"

REM Copy built files
echo 📋 Copying build artifacts...
if exist "%BUILD_DIR%\zenu.exe" (
    copy "%BUILD_DIR%\zenu.exe" "%RELEASE_DIR%\Zenu.exe"
    echo ✅ Executable copied
) else (
    echo ERROR: Built executable not found at %BUILD_DIR%\zenu.exe
    exit /b 1
)

REM Copy required DLLs
echo 📋 Copying required libraries...
for %%f in ("%BUILD_DIR%\*.dll") do (
    copy "%%f" "%RELEASE_DIR%\"
    echo   - %%~nxf
)

REM Copy data directory
if exist "%BUILD_DIR%\data" (
    echo 📋 Copying data directory...
    xcopy /E /I /H /Y "%BUILD_DIR%\data" "%RELEASE_DIR%\data"
    echo ✅ Data directory copied
)

echo.

REM Build MSIX package if msix tool is available
echo 📦 Building MSIX package...
flutter pub run msix:create
if %errorlevel% equ 0 (
    echo ✅ MSIX package created successfully
    REM Copy MSIX to release directory
    if exist "%PROJECT_DIR%\build\windows\x64\runner\Release\*.msix" (
        copy "%PROJECT_DIR%\build\windows\x64\runner\Release\*.msix" "%RELEASE_DIR%\"
    )
) else (
    echo ⚠️ MSIX package creation failed, continuing without it...
)

echo.

REM Generate checksums
echo 🔐 Generating checksums...
if exist "%RELEASE_DIR%\Zenu.exe" (
    certutil -hashfile "%RELEASE_DIR%\Zenu.exe" SHA256 > "%RELEASE_DIR%\Zenu.exe.sha256"
    echo ✅ SHA256 checksum generated
)

echo.

REM Create version info file
echo 📄 Creating version info...
echo Version: 1.0.2 > "%RELEASE_DIR%\version.txt"
echo Build Date: %date% %time% >> "%RELEASE_DIR%\version.txt"
echo Platform: Windows x64 >> "%RELEASE_DIR%\version.txt"
echo Flutter Version: >> "%RELEASE_DIR%\version.txt"
flutter --version >> "%RELEASE_DIR%\version.txt"

echo.

REM List release contents
echo 📋 Release contents:
dir "%RELEASE_DIR%" /b
echo.

REM Calculate total size
for /f %%i in ('dir "%RELEASE_DIR%" /s /-c ^| find "File(s)"') do set SIZE=%%i
echo 💾 Total release size: %SIZE%

echo.
echo ✅ Build completed successfully!
echo 📁 Release files are in: %RELEASE_DIR%
echo.

REM Ask if user wants to test the build
set /p TEST_BUILD="Would you like to test the build? (y/n): "
if /i "%TEST_BUILD%"=="y" (
    echo.
    echo 🚀 Starting Zenu...
    start "" "%RELEASE_DIR%\Zenu.exe"
)

echo.
echo 🎉 Build process complete!
pause