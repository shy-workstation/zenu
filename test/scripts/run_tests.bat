@echo off
REM Windows Batch Script for Running Zenu Tests
REM Usage: run_tests.bat [options]

setlocal EnableDelayedExpansion

REM Configuration
set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR%..\..
set TEST_RESULTS_DIR=%PROJECT_ROOT%\test_results
set COVERAGE_DIR=%PROJECT_ROOT%\coverage

REM Default configuration
set PLATFORM=all
set BUILD_TYPE=debug
set RUN_TESTS=true
set RUN_INTEGRATION_TESTS=false
set GENERATE_COVERAGE=false
set VERBOSE=false
set CLEAN_BUILD=false
set SKIP_BUILD=false
set OUTPUT_FORMAT=expanded

REM Colors (if supported)
set GREEN=[32m
set RED=[31m
set YELLOW=[33m
set BLUE=[34m
set NC=[0m

:parse_args
if "%~1"=="" goto :args_parsed
if "%~1"=="--help" goto :show_help
if "%~1"=="-h" goto :show_help
if "%~1"=="--platform" (
    set PLATFORM=%~2
    shift
    shift
    goto :parse_args
)
if "%~1"=="--release" (
    set BUILD_TYPE=release
    shift
    goto :parse_args
)
if "%~1"=="--profile" (
    set BUILD_TYPE=profile
    shift
    goto :parse_args
)
if "%~1"=="--clean" (
    set CLEAN_BUILD=true
    shift
    goto :parse_args
)
if "%~1"=="--skip-build" (
    set SKIP_BUILD=true
    shift
    goto :parse_args
)
if "%~1"=="--no-tests" (
    set RUN_TESTS=false
    shift
    goto :parse_args
)
if "%~1"=="--integration" (
    set RUN_INTEGRATION_TESTS=true
    shift
    goto :parse_args
)
if "%~1"=="--coverage" (
    set GENERATE_COVERAGE=true
    shift
    goto :parse_args
)
if "%~1"=="--verbose" (
    set VERBOSE=true
    shift
    goto :parse_args
)
if "%~1"=="--format" (
    set OUTPUT_FORMAT=%~2
    shift
    shift
    goto :parse_args
)
shift
goto :parse_args

:args_parsed

echo.
echo ========================================
echo Zenu Windows Test Runner
echo ========================================
echo Platform: %PLATFORM%
echo Build Type: %BUILD_TYPE%
echo Run Tests: %RUN_TESTS%
echo Integration Tests: %RUN_INTEGRATION_TESTS%
echo Coverage: %GENERATE_COVERAGE%
echo.

REM Change to project directory
cd /d "%PROJECT_ROOT%"

REM Check requirements
call :check_requirements
if errorlevel 1 goto :error

REM Setup environment
call :setup_environment
if errorlevel 1 goto :error

REM Run static analysis
if "%RUN_TESTS%"=="true" (
    call :run_static_analysis
    if errorlevel 1 goto :error
)

REM Run tests
if "%RUN_TESTS%"=="true" (
    call :run_tests
    if errorlevel 1 goto :error
)

REM Build if not skipped
if not "%SKIP_BUILD%"=="true" (
    if "%PLATFORM%"=="all" (
        call :build_windows
        call :build_web
    ) else if "%PLATFORM%"=="windows" (
        call :build_windows
        call :run_platform_tests windows
    ) else if "%PLATFORM%"=="web" (
        call :build_web
    ) else if "%PLATFORM%"=="android" (
        echo Android builds not supported on Windows without WSL
        goto :error
    )
)

echo.
echo %GREEN%Build and test completed successfully!%NC%
goto :end

:check_requirements
echo Checking requirements...

REM Check Flutter
flutter --version >nul 2>&1
if errorlevel 1 (
    echo %RED%ERROR: Flutter is not installed or not in PATH%NC%
    exit /b 1
)

REM Check Dart
dart --version >nul 2>&1
if errorlevel 1 (
    echo %RED%ERROR: Dart is not installed or not in PATH%NC%
    exit /b 1
)

echo %GREEN%Requirements check passed%NC%
exit /b 0

:setup_environment
echo Setting up environment...

REM Create directories
if not exist "%TEST_RESULTS_DIR%" mkdir "%TEST_RESULTS_DIR%"
if not exist "%COVERAGE_DIR%" mkdir "%COVERAGE_DIR%"

REM Clean build if requested
if "%CLEAN_BUILD%"=="true" (
    echo Cleaning build directory...
    if exist "build" rmdir /s /q "build"
    flutter clean
)

REM Get dependencies
echo Getting Flutter dependencies...
flutter pub get
if errorlevel 1 (
    echo %RED%ERROR: Failed to get dependencies%NC%
    exit /b 1
)

REM Generate code if needed
findstr /c:"build_runner" pubspec.yaml >nul 2>&1
if not errorlevel 1 (
    echo Generating code...
    flutter packages pub run build_runner build --delete-conflicting-outputs
)

echo %GREEN%Environment setup complete%NC%
exit /b 0

:run_static_analysis
echo Running static analysis...

REM Dart analysis
echo Running dart analyze...
dart analyze --fatal-infos --fatal-warnings
if errorlevel 1 (
    echo %RED%ERROR: Static analysis failed%NC%
    exit /b 1
)

REM Code formatting check
echo Checking code formatting...
dart format --output=none --set-exit-if-changed .
if errorlevel 1 (
    echo %RED%ERROR: Code formatting issues found%NC%
    echo Run 'dart format .' to fix formatting
    exit /b 1
)

echo %GREEN%Static analysis passed%NC%
exit /b 0

:run_tests
echo Running tests...

set TEST_ARGS=--reporter %OUTPUT_FORMAT%

if "%VERBOSE%"=="true" (
    set TEST_ARGS=%TEST_ARGS% --verbose-skips
)

if "%GENERATE_COVERAGE%"=="true" (
    set TEST_ARGS=%TEST_ARGS% --coverage
)

REM Run unit and widget tests
echo Running unit and widget tests...
flutter test %TEST_ARGS% test\
if errorlevel 1 (
    echo %RED%ERROR: Unit and widget tests failed%NC%
    exit /b 1
)

REM Run integration tests if requested
if "%RUN_INTEGRATION_TESTS%"=="true" (
    echo Running integration tests...
    flutter test integration_test\ --verbose
    if errorlevel 1 (
        echo %RED%ERROR: Integration tests failed%NC%
        exit /b 1
    )
)

REM Generate coverage report
if "%GENERATE_COVERAGE%"=="true" (
    call :generate_coverage_report
)

echo %GREEN%Tests completed successfully%NC%
exit /b 0

:generate_coverage_report
echo Generating coverage report...

if exist "coverage\lcov.info" (
    echo Coverage data generated: coverage\lcov.info
    echo Install lcov to generate HTML reports
) else (
    echo %YELLOW%Warning: Coverage file not found%NC%
)

exit /b 0

:build_windows
echo Building Windows application...

set BUILD_ARGS=
if "%BUILD_TYPE%"=="release" (
    set BUILD_ARGS=--release
) else if "%BUILD_TYPE%"=="profile" (
    set BUILD_ARGS=--profile
) else (
    set BUILD_ARGS=--debug
)

flutter build windows %BUILD_ARGS%
if errorlevel 1 (
    echo %RED%ERROR: Windows build failed%NC%
    exit /b 1
)

REM Build MSIX for release
if "%BUILD_TYPE%"=="release" (
    echo Building MSIX package...
    flutter pub run msix:create
    if errorlevel 1 (
        echo %YELLOW%Warning: MSIX build failed%NC%
    ) else (
        echo %GREEN%MSIX package built successfully%NC%
    )
)

echo %GREEN%Windows build completed%NC%
exit /b 0

:build_web
echo Building Web application...

set BUILD_ARGS=
if "%BUILD_TYPE%"=="release" (
    set BUILD_ARGS=--release
) else if "%BUILD_TYPE%"=="profile" (
    set BUILD_ARGS=--profile
) else (
    set BUILD_ARGS=--debug
)

flutter build web %BUILD_ARGS%
if errorlevel 1 (
    echo %RED%ERROR: Web build failed%NC%
    exit /b 1
)

echo %GREEN%Web build completed%NC%
exit /b 0

:run_platform_tests
set PLATFORM_NAME=%~1
echo Running platform-specific tests for %PLATFORM_NAME%...

flutter test test\unit\platform\%PLATFORM_NAME%\
if errorlevel 1 (
    echo %RED%ERROR: %PLATFORM_NAME% platform tests failed%NC%
    exit /b 1
)

echo %GREEN%%PLATFORM_NAME% platform tests passed%NC%
exit /b 0

:show_help
echo Zenu Windows Test Runner
echo.
echo USAGE:
echo     run_tests.bat [OPTIONS]
echo.
echo PLATFORMS:
echo     --platform PLATFORM    Platform to build/test (windows, web, all)
echo.
echo BUILD OPTIONS:
echo     --release              Build release version
echo     --profile              Build profile version
echo     --clean                Clean build directory before building
echo     --skip-build           Skip build step, only run tests
echo.
echo TEST OPTIONS:
echo     --no-tests             Skip unit and widget tests
echo     --integration          Run integration tests
echo     --coverage             Generate test coverage report
echo     --verbose              Verbose test output
echo     --format FORMAT        Test output format (expanded, compact, json)
echo.
echo EXAMPLES:
echo     # Run all tests and build
echo     run_tests.bat
echo.
echo     # Build Windows release with coverage
echo     run_tests.bat --platform windows --release --coverage
echo.
echo     # Run only tests without building
echo     run_tests.bat --skip-build --integration
echo.
echo     # Clean build and run verbose tests
echo     run_tests.bat --clean --verbose
echo.
goto :end

:error
echo.
echo %RED%Build and test failed!%NC%
exit /b 1

:end
endlocal