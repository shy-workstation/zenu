#!/bin/bash

# Build and Test Script for Zenu (All Platforms)
# Usage: ./test/scripts/build_and_test.sh [platform] [options]

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
TEST_RESULTS_DIR="$PROJECT_ROOT/test_results"
COVERAGE_DIR="$PROJECT_ROOT/coverage"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Default configuration
PLATFORM="all"
BUILD_TYPE="debug"
RUN_TESTS=true
RUN_INTEGRATION_TESTS=false
GENERATE_COVERAGE=false
VERBOSE=false
CLEAN_BUILD=false
SKIP_BUILD=false
OUTPUT_FORMAT="expanded"

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

show_help() {
    cat << EOF
Zenu Build and Test Script

USAGE:
    ./test/scripts/build_and_test.sh [PLATFORM] [OPTIONS]

PLATFORMS:
    all         Build and test all platforms (default)
    android     Android APK/AAB
    ios         iOS IPA (requires macOS)
    windows     Windows MSIX
    macos       macOS DMG (requires macOS)
    linux       Linux AppImage
    web         Web build

BUILD OPTIONS:
    --release              Build release version
    --profile              Build profile version
    --clean                Clean build directory before building
    --skip-build           Skip build step, only run tests

TEST OPTIONS:
    --no-tests             Skip unit and widget tests
    --integration          Run integration tests
    --coverage             Generate test coverage report
    --verbose              Verbose test output
    --format FORMAT        Test output format (expanded, compact, json)

ANDROID SPECIFIC:
    --api-level LEVEL      Target API level (21-34, default: 34)
    --arch ARCH            Target architecture (arm64-v8a, armeabi-v7a, x86_64)
    --signed               Build signed APK/AAB (requires keystore setup)

iOS SPECIFIC:
    --ios-version VERSION  Minimum iOS version (12.0-17.0, default: 12.0)
    --device               Build for device (requires provisioning)
    --simulator            Build for simulator only

EXAMPLES:
    # Build and test all platforms
    ./test/scripts/build_and_test.sh

    # Build Android release with coverage
    ./test/scripts/build_and_test.sh android --release --coverage

    # Run only tests without building
    ./test/scripts/build_and_test.sh --skip-build --integration

    # Build iOS for simulator with verbose output
    ./test/scripts/build_and_test.sh ios --simulator --verbose

    # Clean build Windows MSIX
    ./test/scripts/build_and_test.sh windows --clean --release
EOF
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            android|ios|windows|macos|linux|web|all)
                PLATFORM="$1"
                shift
                ;;
            --release)
                BUILD_TYPE="release"
                shift
                ;;
            --profile)
                BUILD_TYPE="profile"
                shift
                ;;
            --clean)
                CLEAN_BUILD=true
                shift
                ;;
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --no-tests)
                RUN_TESTS=false
                shift
                ;;
            --integration)
                RUN_INTEGRATION_TESTS=true
                shift
                ;;
            --coverage)
                GENERATE_COVERAGE=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            --api-level)
                ANDROID_API_LEVEL="$2"
                shift 2
                ;;
            --arch)
                ANDROID_ARCH="$2"
                shift 2
                ;;
            --signed)
                ANDROID_SIGNED=true
                shift
                ;;
            --ios-version)
                IOS_VERSION="$2"
                shift 2
                ;;
            --device)
                IOS_DEVICE=true
                shift
                ;;
            --simulator)
                IOS_SIMULATOR=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

check_requirements() {
    print_header "Checking Requirements"
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    local flutter_version=$(flutter --version | head -n 1)
    print_success "Flutter found: $flutter_version"
    
    # Check Dart
    if ! command -v dart &> /dev/null; then
        print_error "Dart is not installed or not in PATH"
        exit 1
    fi
    
    local dart_version=$(dart --version)
    print_success "Dart found: $dart_version"
    
    # Platform-specific checks
    case $PLATFORM in
        android|all)
            check_android_requirements
            ;;
        ios|all)
            check_ios_requirements
            ;;
        windows|all)
            check_windows_requirements
            ;;
        macos|all)
            check_macos_requirements
            ;;
        linux|all)
            check_linux_requirements
            ;;
    esac
    
    print_success "All requirements satisfied"
}

check_android_requirements() {
    if [[ "$PLATFORM" == "android" || "$PLATFORM" == "all" ]]; then
        # Check if Android toolchain is available
        flutter doctor --verbose | grep -q "Android toolchain" || {
            print_warning "Android toolchain not properly configured"
            return 1
        }
        
        # Check for Android SDK
        if [[ -z "${ANDROID_SDK_ROOT:-}" && -z "${ANDROID_HOME:-}" ]]; then
            print_warning "Android SDK not found (ANDROID_SDK_ROOT or ANDROID_HOME not set)"
        fi
    fi
}

check_ios_requirements() {
    if [[ "$PLATFORM" == "ios" || "$PLATFORM" == "all" ]]; then
        if [[ "$OSTYPE" != "darwin"* ]]; then
            if [[ "$PLATFORM" == "ios" ]]; then
                print_error "iOS builds require macOS"
                exit 1
            else
                print_warning "Skipping iOS (requires macOS)"
                return 0
            fi
        fi
        
        # Check Xcode
        if ! command -v xcodebuild &> /dev/null; then
            print_warning "Xcode command line tools not installed"
        fi
    fi
}

check_windows_requirements() {
    if [[ "$PLATFORM" == "windows" || "$PLATFORM" == "all" ]]; then
        # For cross-compilation, just check Flutter Windows support
        flutter doctor --verbose | grep -q "Windows" || {
            print_warning "Windows platform not enabled in Flutter"
        }
    fi
}

check_macos_requirements() {
    if [[ "$PLATFORM" == "macos" || "$PLATFORM" == "all" ]]; then
        if [[ "$OSTYPE" != "darwin"* ]]; then
            if [[ "$PLATFORM" == "macos" ]]; then
                print_error "macOS builds require macOS"
                exit 1
            else
                print_warning "Skipping macOS (requires macOS)"
                return 0
            fi
        fi
    fi
}

check_linux_requirements() {
    if [[ "$PLATFORM" == "linux" || "$PLATFORM" == "all" ]]; then
        # Check for Linux desktop development
        flutter doctor --verbose | grep -q "Linux" || {
            print_warning "Linux platform not enabled in Flutter"
        }
    fi
}

setup_environment() {
    print_header "Setting Up Environment"
    
    cd "$PROJECT_ROOT"
    
    # Clean build directory if requested
    if [[ "$CLEAN_BUILD" == true ]]; then
        print_info "Cleaning build directory..."
        rm -rf "$BUILD_DIR"
        flutter clean
    fi
    
    # Create directories
    mkdir -p "$TEST_RESULTS_DIR"
    mkdir -p "$COVERAGE_DIR"
    
    # Get dependencies
    print_info "Getting Flutter dependencies..."
    flutter pub get
    
    # Generate code if needed
    if [[ -f "pubspec.yaml" ]] && grep -q "build_runner" pubspec.yaml; then
        print_info "Generating code..."
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
    
    print_success "Environment setup complete"
}

run_static_analysis() {
    print_header "Running Static Analysis"
    
    # Dart analysis
    print_info "Running dart analyze..."
    if dart analyze --fatal-infos --fatal-warnings; then
        print_success "Static analysis passed"
    else
        print_error "Static analysis failed"
        return 1
    fi
    
    # Code formatting check
    print_info "Checking code formatting..."
    if dart format --output=none --set-exit-if-changed .; then
        print_success "Code formatting is correct"
    else
        print_error "Code formatting issues found"
        print_info "Run 'dart format .' to fix formatting"
        return 1
    fi
}

run_tests() {
    if [[ "$RUN_TESTS" != true ]]; then
        print_info "Skipping tests"
        return 0
    fi
    
    print_header "Running Tests"
    
    local test_args=()
    test_args+=("--reporter" "$OUTPUT_FORMAT")
    
    if [[ "$VERBOSE" == true ]]; then
        test_args+=("--verbose-skips")
    fi
    
    if [[ "$GENERATE_COVERAGE" == true ]]; then
        test_args+=("--coverage")
    fi
    
    # Run unit and widget tests
    print_info "Running unit and widget tests..."
    if flutter test "${test_args[@]}" test/; then
        print_success "Unit and widget tests passed"
    else
        print_error "Unit and widget tests failed"
        return 1
    fi
    
    # Run integration tests if requested
    if [[ "$RUN_INTEGRATION_TESTS" == true ]]; then
        print_info "Running integration tests..."
        if flutter test integration_test/ --verbose; then
            print_success "Integration tests passed"
        else
            print_error "Integration tests failed"
            return 1
        fi
    fi
    
    # Generate coverage report
    if [[ "$GENERATE_COVERAGE" == true ]]; then
        generate_coverage_report
    fi
}

generate_coverage_report() {
    print_info "Generating coverage report..."
    
    # Convert to LCOV format
    if [[ -f "coverage/lcov.info" ]]; then
        # Generate HTML report if genhtml is available
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info \
                -o coverage/html \
                --title "Zenu Test Coverage" \
                --show-details \
                --legend
            print_success "Coverage HTML report generated: coverage/html/index.html"
        else
            print_info "Install lcov to generate HTML coverage reports"
            print_info "macOS: brew install lcov"
            print_info "Ubuntu: sudo apt-get install lcov"
        fi
        
        # Show coverage summary
        lcov --summary coverage/lcov.info
        print_success "Coverage report generated: coverage/lcov.info"
    else
        print_warning "Coverage file not found"
    fi
}

build_android() {
    print_header "Building Android"
    
    local build_args=()
    
    # Add build type
    case $BUILD_TYPE in
        release)
            build_args+=("--release")
            ;;
        profile)
            build_args+=("--profile")
            ;;
        debug)
            build_args+=("--debug")
            ;;
    esac
    
    # Add architecture if specified
    if [[ -n "${ANDROID_ARCH:-}" ]]; then
        build_args+=("--target-platform" "android-${ANDROID_ARCH}")
    fi
    
    # Build APK
    print_info "Building Android APK..."
    if flutter build apk "${build_args[@]}"; then
        print_success "Android APK built successfully"
        
        local apk_path="build/app/outputs/flutter-apk/app-${BUILD_TYPE}.apk"
        if [[ -f "$apk_path" ]]; then
            local apk_size=$(du -h "$apk_path" | cut -f1)
            print_info "APK size: $apk_size"
            print_info "APK location: $apk_path"
        fi
    else
        print_error "Android APK build failed"
        return 1
    fi
    
    # Build AAB for release
    if [[ "$BUILD_TYPE" == "release" ]]; then
        print_info "Building Android App Bundle..."
        if flutter build appbundle "${build_args[@]}"; then
            print_success "Android App Bundle built successfully"
            
            local aab_path="build/app/outputs/bundle/${BUILD_TYPE}/app-${BUILD_TYPE}.aab"
            if [[ -f "$aab_path" ]]; then
                local aab_size=$(du -h "$aab_path" | cut -f1)
                print_info "AAB size: $aab_size"
                print_info "AAB location: $aab_path"
            fi
        else
            print_warning "Android App Bundle build failed"
        fi
    fi
}

build_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_warning "Skipping iOS build (requires macOS)"
        return 0
    fi
    
    print_header "Building iOS"
    
    local build_args=()
    
    # Add build type
    case $BUILD_TYPE in
        release)
            build_args+=("--release")
            ;;
        profile)
            build_args+=("--profile")
            ;;
        debug)
            build_args+=("--debug")
            ;;
    esac
    
    # Determine target
    if [[ "${IOS_SIMULATOR:-false}" == true ]]; then
        print_info "Building iOS for simulator..."
        build_args+=("--simulator")
    else
        print_info "Building iOS for device..."
    fi
    
    # Build iOS
    if flutter build ios "${build_args[@]}" --no-codesign; then
        print_success "iOS build completed successfully"
        
        local ios_path="build/ios/iphoneos/Runner.app"
        if [[ -d "$ios_path" ]]; then
            local ios_size=$(du -sh "$ios_path" | cut -f1)
            print_info "iOS app size: $ios_size"
            print_info "iOS app location: $ios_path"
        fi
    else
        print_error "iOS build failed"
        return 1
    fi
}

build_windows() {
    print_header "Building Windows"
    
    local build_args=()
    
    # Add build type
    case $BUILD_TYPE in
        release)
            build_args+=("--release")
            ;;
        profile)
            build_args+=("--profile")
            ;;
        debug)
            build_args+=("--debug")
            ;;
    esac
    
    # Build Windows executable
    print_info "Building Windows executable..."
    if flutter build windows "${build_args[@]}"; then
        print_success "Windows executable built successfully"
        
        local exe_path="build/windows/runner/${BUILD_TYPE}/zenu.exe"
        if [[ -f "$exe_path" ]]; then
            local exe_size=$(du -h "$exe_path" | cut -f1)
            print_info "Executable size: $exe_size"
            print_info "Executable location: $exe_path"
        fi
        
        # Build MSIX package for release
        if [[ "$BUILD_TYPE" == "release" ]]; then
            print_info "Building MSIX package..."
            if flutter pub run msix:create; then
                print_success "MSIX package built successfully"
                
                local msix_path=$(find build -name "*.msix" | head -n 1)
                if [[ -n "$msix_path" ]]; then
                    local msix_size=$(du -h "$msix_path" | cut -f1)
                    print_info "MSIX size: $msix_size"
                    print_info "MSIX location: $msix_path"
                fi
            else
                print_warning "MSIX package build failed"
            fi
        fi
    else
        print_error "Windows build failed"
        return 1
    fi
}

build_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_warning "Skipping macOS build (requires macOS)"
        return 0
    fi
    
    print_header "Building macOS"
    
    local build_args=()
    
    # Add build type
    case $BUILD_TYPE in
        release)
            build_args+=("--release")
            ;;
        profile)
            build_args+=("--profile")
            ;;
        debug)
            build_args+=("--debug")
            ;;
    esac
    
    # Build macOS app
    print_info "Building macOS application..."
    if flutter build macos "${build_args[@]}"; then
        print_success "macOS application built successfully"
        
        local app_path="build/macos/Build/Products/${BUILD_TYPE^}/zenu.app"
        if [[ -d "$app_path" ]]; then
            local app_size=$(du -sh "$app_path" | cut -f1)
            print_info "App size: $app_size"
            print_info "App location: $app_path"
        fi
    else
        print_error "macOS build failed"
        return 1
    fi
}

build_linux() {
    print_header "Building Linux"
    
    local build_args=()
    
    # Add build type
    case $BUILD_TYPE in
        release)
            build_args+=("--release")
            ;;
        profile)
            build_args+=("--profile")
            ;;
        debug)
            build_args+=("--debug")
            ;;
    esac
    
    # Build Linux executable
    print_info "Building Linux executable..."
    if flutter build linux "${build_args[@]}"; then
        print_success "Linux executable built successfully"
        
        local exe_path="build/linux/${ARCH:-x64}/${BUILD_TYPE}/bundle/zenu"
        if [[ -f "$exe_path" ]]; then
            local exe_size=$(du -h "$exe_path" | cut -f1)
            print_info "Executable size: $exe_size"
            print_info "Executable location: $exe_path"
        fi
    else
        print_error "Linux build failed"
        return 1
    fi
}

build_web() {
    print_header "Building Web"
    
    local build_args=()
    
    # Add build type
    case $BUILD_TYPE in
        release)
            build_args+=("--release")
            ;;
        profile)
            build_args+=("--profile")
            ;;
        debug)
            build_args+=("--debug")
            ;;
    esac
    
    # Build web app
    print_info "Building web application..."
    if flutter build web "${build_args[@]}"; then
        print_success "Web application built successfully"
        
        local web_path="build/web"
        if [[ -d "$web_path" ]]; then
            local web_size=$(du -sh "$web_path" | cut -f1)
            print_info "Web app size: $web_size"
            print_info "Web app location: $web_path"
        fi
    else
        print_error "Web build failed"
        return 1
    fi
}

run_platform_tests() {
    local platform=$1
    
    print_info "Running platform-specific tests for $platform..."
    
    case $platform in
        android)
            if flutter test test/unit/platform/android/; then
                print_success "Android platform tests passed"
            else
                print_error "Android platform tests failed"
                return 1
            fi
            ;;
        ios)
            if flutter test test/unit/platform/ios/; then
                print_success "iOS platform tests passed"
            else
                print_error "iOS platform tests failed"
                return 1
            fi
            ;;
        windows)
            if flutter test test/unit/platform/windows/; then
                print_success "Windows platform tests passed"
            else
                print_error "Windows platform tests failed"
                return 1
            fi
            ;;
        macos)
            if flutter test test/unit/platform/macos/; then
                print_success "macOS platform tests passed"
            else
                print_error "macOS platform tests failed"
                return 1
            fi
            ;;
        linux)
            if flutter test test/unit/platform/linux/; then
                print_success "Linux platform tests passed"
            else
                print_error "Linux platform tests failed"
                return 1
            fi
            ;;
    esac
}

main() {
    local start_time=$(date +%s)
    
    print_header "Zenu Build and Test Script"
    print_info "Platform: $PLATFORM"
    print_info "Build Type: $BUILD_TYPE"
    print_info "Run Tests: $RUN_TESTS"
    print_info "Integration Tests: $RUN_INTEGRATION_TESTS"
    print_info "Coverage: $GENERATE_COVERAGE"
    echo
    
    # Check requirements
    check_requirements
    
    # Setup environment
    setup_environment
    
    # Run static analysis
    if ! run_static_analysis; then
        exit 1
    fi
    
    # Run tests
    if ! run_tests; then
        exit 1
    fi
    
    # Build platforms
    if [[ "$SKIP_BUILD" != true ]]; then
        case $PLATFORM in
            all)
                build_android || true
                build_ios || true
                build_windows || true
                build_macos || true
                build_linux || true
                build_web || true
                ;;
            android)
                build_android
                run_platform_tests android
                ;;
            ios)
                build_ios
                run_platform_tests ios
                ;;
            windows)
                build_windows
                run_platform_tests windows
                ;;
            macos)
                build_macos
                run_platform_tests macos
                ;;
            linux)
                build_linux
                run_platform_tests linux
                ;;
            web)
                build_web
                ;;
        esac
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    print_header "Build and Test Complete"
    print_success "Total time: ${duration}s"
    print_success "All tasks completed successfully!"
}

# Parse arguments and run main function
parse_arguments "$@"
main