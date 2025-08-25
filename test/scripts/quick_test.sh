#!/bin/bash

# Quick Test Script for Zenu - Fast development testing
# Usage: ./test/scripts/quick_test.sh [unit|widget|integration|platform] [--coverage]

set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default settings
TEST_TYPE="unit"
COVERAGE=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        unit|widget|integration|platform|all)
            TEST_TYPE="$1"
            shift
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Quick Test Script for Zenu"
            echo ""
            echo "Usage: $0 [TYPE] [OPTIONS]"
            echo ""
            echo "Types:"
            echo "  unit           Run unit tests only (default)"
            echo "  widget         Run widget tests only"
            echo "  integration    Run integration tests only"
            echo "  platform       Run platform-specific tests"
            echo "  all            Run all tests"
            echo ""
            echo "Options:"
            echo "  --coverage     Generate coverage report"
            echo "  --verbose      Verbose output"
            echo "  --help, -h     Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 unit --coverage"
            echo "  $0 widget"
            echo "  $0 all --verbose"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

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

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

run_quick_checks() {
    print_header "Quick Environment Check"
    
    # Change to project root
    cd "$PROJECT_ROOT"
    
    # Quick Flutter check
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter not found"
        exit 1
    fi
    
    # Get dependencies if needed
    if [ ! -d ".dart_tool" ] || [ ! -f ".packages" ]; then
        print_info "Getting dependencies..."
        flutter pub get
    fi
    
    print_success "Environment ready"
}

run_unit_tests() {
    print_header "Running Unit Tests"
    
    local test_args=("--reporter" "expanded")
    
    if [[ "$COVERAGE" == true ]]; then
        test_args+=("--coverage")
    fi
    
    if [[ "$VERBOSE" == true ]]; then
        test_args+=("--verbose-skips")
    fi
    
    # Run unit tests
    if flutter test "${test_args[@]}" test/unit/; then
        print_success "Unit tests passed"
        return 0
    else
        print_error "Unit tests failed"
        return 1
    fi
}

run_widget_tests() {
    print_header "Running Widget Tests"
    
    local test_args=("--reporter" "expanded")
    
    if [[ "$VERBOSE" == true ]]; then
        test_args+=("--verbose-skips")
    fi
    
    # Run widget tests  
    if flutter test "${test_args[@]}" test/widgets/; then
        print_success "Widget tests passed"
        return 0
    else
        print_error "Widget tests failed"
        return 1
    fi
}

run_integration_tests() {
    print_header "Running Integration Tests"
    
    if flutter test integration_test/ --verbose; then
        print_success "Integration tests passed"
        return 0
    else
        print_error "Integration tests failed"
        return 1
    fi
}

run_platform_tests() {
    print_header "Running Platform Tests"
    
    local test_args=("--reporter" "expanded")
    
    if [[ "$VERBOSE" == true ]]; then
        test_args+=("--verbose-skips")
    fi
    
    # Determine current platform
    local platform=""
    case "$(uname -s)" in
        Darwin*)
            platform="macos"
            ;;
        Linux*)
            platform="linux"
            ;;
        MINGW*|CYGWIN*|MSYS*)
            platform="windows"
            ;;
        *)
            platform="linux"
            ;;
    esac
    
    # Run platform-specific tests
    if [ -d "test/unit/platform/$platform" ]; then
        if flutter test "${test_args[@]}" test/unit/platform/$platform/; then
            print_success "$platform platform tests passed"
            return 0
        else
            print_error "$platform platform tests failed"
            return 1
        fi
    else
        print_info "No platform tests found for $platform"
        return 0
    fi
}

run_all_tests() {
    print_header "Running All Tests"
    
    local failed=0
    
    # Run unit tests
    if ! run_unit_tests; then
        failed=1
    fi
    
    # Run widget tests
    if ! run_widget_tests; then
        failed=1
    fi
    
    # Run platform tests
    if ! run_platform_tests; then
        failed=1
    fi
    
    # Run integration tests (optional, can be slow)
    if [[ "${RUN_INTEGRATION:-false}" == "true" ]]; then
        if ! run_integration_tests; then
            failed=1
        fi
    fi
    
    return $failed
}

generate_coverage() {
    if [[ "$COVERAGE" != true ]]; then
        return 0
    fi
    
    print_header "Generating Coverage Report"
    
    if [ -f "coverage/lcov.info" ]; then
        # Check if genhtml is available
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html --title "Zenu Quick Test Coverage"
            print_success "Coverage HTML report: coverage/html/index.html"
        else
            print_info "Coverage data: coverage/lcov.info"
            print_info "Install lcov for HTML reports: brew install lcov (macOS) or apt-get install lcov (Linux)"
        fi
        
        # Show coverage summary if lcov is available
        if command -v lcov &> /dev/null; then
            echo ""
            lcov --summary coverage/lcov.info 2>/dev/null || true
        fi
    else
        print_info "No coverage data found"
    fi
}

main() {
    local start_time=$(date +%s)
    
    print_header "Zenu Quick Test Runner"
    print_info "Test Type: $TEST_TYPE"
    print_info "Coverage: $COVERAGE"
    print_info "Verbose: $VERBOSE"
    echo ""
    
    # Quick environment check
    run_quick_checks
    
    # Run selected tests
    local test_result=0
    case $TEST_TYPE in
        unit)
            run_unit_tests || test_result=1
            ;;
        widget)
            run_widget_tests || test_result=1
            ;;
        integration)
            run_integration_tests || test_result=1
            ;;
        platform)
            run_platform_tests || test_result=1
            ;;
        all)
            run_all_tests || test_result=1
            ;;
        *)
            print_error "Unknown test type: $TEST_TYPE"
            exit 1
            ;;
    esac
    
    # Generate coverage if requested
    generate_coverage
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    print_header "Test Results"
    if [ $test_result -eq 0 ]; then
        print_success "All tests completed successfully!"
    else
        print_error "Some tests failed!"
    fi
    print_info "Duration: ${duration}s"
    
    exit $test_result
}

# Run main function
main