import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

void main(List<String> args) async {
  final runner = TestRunner();
  await runner.run(args);
}

class TestRunner {
  final List<TestSuite> _testSuites = [
    TestSuite(
      name: 'Unit Tests',
      path: 'test/unit',
      priority: 1,
      platforms: [TestPlatform.all],
      timeout: '30s',
    ),
    TestSuite(
      name: 'Widget Tests',
      path: 'test/widgets',
      priority: 2,
      platforms: [TestPlatform.all],
      timeout: '45s',
    ),
    TestSuite(
      name: 'Integration Tests',
      path: 'integration_test',
      priority: 3,
      platforms: [TestPlatform.all],
      timeout: '120s',
      requiresDevice: true,
    ),
    TestSuite(
      name: 'Android Platform Tests',
      path: 'test/unit/platform/android',
      priority: 2,
      platforms: [TestPlatform.android],
      timeout: '60s',
    ),
    TestSuite(
      name: 'iOS Platform Tests',
      path: 'test/unit/platform/ios',
      priority: 2,
      platforms: [TestPlatform.ios],
      timeout: '60s',
    ),
    TestSuite(
      name: 'Windows Platform Tests',
      path: 'test/unit/platform/windows',
      priority: 2,
      platforms: [TestPlatform.windows],
      timeout: '60s',
    ),
    TestSuite(
      name: 'macOS Platform Tests',
      path: 'test/unit/platform/macos',
      priority: 2,
      platforms: [TestPlatform.macos],
      timeout: '60s',
    ),
    TestSuite(
      name: 'Linux Platform Tests',
      path: 'test/unit/platform/linux',
      priority: 2,
      platforms: [TestPlatform.linux],
      timeout: '60s',
    ),
  ];

  Future<void> run(List<String> args) async {
    final config = TestConfig.fromArgs(args);
    
    debugPrint('🧪 Zenu Test Runner Starting...');
    debugPrint('Configuration: ${config.toString()}');
    debugPrint('');

    if (config.showHelp) {
      _printHelp();
      return;
    }

    if (config.listSuites) {
      _listTestSuites();
      return;
    }

    // Validate environment
    final validationResult = await _validateEnvironment(config);
    if (!validationResult.isValid) {
      debugPrint('❌ Environment validation failed:');
      for (final error in validationResult.errors) {
        debugPrint('   - $error');
      }
      exit(1);
    }

    final suitesToRun = _selectTestSuites(config);
    if (suitesToRun.isEmpty) {
      debugPrint('❌ No test suites match the specified criteria.');
      exit(1);
    }

    debugPrint('📋 Test Suites to run:');
    for (final suite in suitesToRun) {
      debugPrint('   - ${suite.name} (${suite.path})');
    }
    debugPrint('');

    // Run pre-test setup
    await _setupTests(config);

    // Run test suites
    final results = <TestResult>[];
    final stopwatch = Stopwatch()..start();

    if (config.parallel && suitesToRun.length > 1) {
      results.addAll(await _runTestSuitesParallel(suitesToRun, config));
    } else {
      results.addAll(await _runTestSuitesSequential(suitesToRun, config));
    }

    stopwatch.stop();

    // Generate reports
    await _generateReports(results, config, stopwatch.elapsed);

    // Cleanup
    await _cleanupTests(config);

    // Exit with appropriate code
    final hasFailures = results.any((r) => r.failed > 0);
    exit(hasFailures ? 1 : 0);
  }

  List<TestSuite> _selectTestSuites(TestConfig config) {
    var suites = _testSuites;

    // Filter by category
    if (config.categories.isNotEmpty) {
      suites = suites.where((suite) {
        return config.categories.any((category) => 
          suite.path.contains(category.toLowerCase()));
      }).toList();
    }

    // Filter by platform
    if (config.platform != null) {
      suites = suites.where((suite) {
        return suite.platforms.contains(config.platform) ||
               suite.platforms.contains(TestPlatform.all);
      }).toList();
    }

    // Filter by specific test files
    if (config.testFiles.isNotEmpty) {
      suites = suites.where((suite) {
        return config.testFiles.any((file) => suite.path.contains(file));
      }).toList();
    }

    // Sort by priority
    suites.sort((a, b) => a.priority.compareTo(b.priority));

    return suites;
  }

  Future<List<TestResult>> _runTestSuitesSequential(
    List<TestSuite> suites,
    TestConfig config,
  ) async {
    final results = <TestResult>[];
    
    for (final suite in suites) {
      debugPrint('🔄 Running ${suite.name}...');
      final result = await _runTestSuite(suite, config);
      results.add(result);
      
      _printTestResult(result);
      
      if (config.failFast && result.failed > 0) {
        debugPrint('💥 Fail-fast enabled. Stopping after first failure.');
        break;
      }
    }
    
    return results;
  }

  Future<List<TestResult>> _runTestSuitesParallel(
    List<TestSuite> suites,
    TestConfig config,
  ) async {
    debugPrint('🚀 Running test suites in parallel (concurrency: ${config.concurrency})...');
    
    final semaphore = Semaphore(config.concurrency);
    final futures = suites.map((suite) async {
      await semaphore.acquire();
      try {
        debugPrint('🔄 Running ${suite.name}...');
        final result = await _runTestSuite(suite, config);
        _printTestResult(result);
        return result;
      } finally {
        semaphore.release();
      }
    });
    
    return await Future.wait(futures);
  }

  Future<TestResult> _runTestSuite(TestSuite suite, TestConfig config) async {
    final stopwatch = Stopwatch()..start();
    
    // Check if test directory exists
    final testDir = Directory(suite.path);
    if (!testDir.existsSync()) {
      return TestResult(
        suiteName: suite.name,
        suitePath: suite.path,
        passed: 0,
        failed: 1,
        skipped: 0,
        duration: Duration.zero,
        errors: ['Test directory does not exist: ${suite.path}'],
      );
    }

    // Build flutter test command
    final command = _buildTestCommand(suite, config);
    
    try {
      final result = await Process.run(
        command.first,
        command.skip(1).toList(),
        workingDirectory: Directory.current.path,
      );
      
      stopwatch.stop();
      
      return _parseTestOutput(
        suite.name,
        suite.path,
        result.stdout.toString(),
        result.stderr.toString(),
        result.exitCode,
        stopwatch.elapsed,
      );
    } catch (e) {
      stopwatch.stop();
      return TestResult(
        suiteName: suite.name,
        suitePath: suite.path,
        passed: 0,
        failed: 1,
        skipped: 0,
        duration: stopwatch.elapsed,
        errors: ['Failed to run tests: $e'],
      );
    }
  }

  List<String> _buildTestCommand(TestSuite suite, TestConfig config) {
    final command = <String>['flutter', 'test'];
    
    // Add test path
    command.add(suite.path);
    
    // Add platform-specific flags
    if (config.platform != null) {
      switch (config.platform!) {
        case TestPlatform.android:
          command.addAll(['--platform', 'chrome']);
          break;
        case TestPlatform.ios:
          command.addAll(['--platform', 'chrome']);
          break;
        case TestPlatform.windows:
          command.addAll(['--platform', 'chrome']);
          break;
        case TestPlatform.macos:
          command.addAll(['--platform', 'chrome']);
          break;
        case TestPlatform.linux:
          command.addAll(['--platform', 'chrome']);
          break;
        case TestPlatform.web:
          command.addAll(['--platform', 'chrome']);
          break;
        case TestPlatform.all:
          // No specific platform
          break;
      }
    }
    
    // Add timeout
    command.addAll(['--timeout', suite.timeout]);
    
    // Add coverage if requested
    if (config.coverage) {
      command.add('--coverage');
    }
    
    // Add verbose output if requested
    if (config.verbose) {
      command.add('--verbose-skips');
    }
    
    // Add reporter
    if (config.reporter.isNotEmpty) {
      command.addAll(['--reporter', config.reporter]);
    }
    
    return command;
  }

  TestResult _parseTestOutput(
    String suiteName,
    String suitePath,
    String stdout,
    String stderr,
    int exitCode,
    Duration duration,
  ) {
    int passed = 0;
    int failed = 0;
    int skipped = 0;
    final errors = <String>[];
    
    // Parse stdout for test results
    final lines = stdout.split('\n');
    for (final line in lines) {
      if (line.contains('All tests passed!')) {
        // Extract numbers from summary
        final passedMatch = RegExp(r'(\d+) test.*passed').firstMatch(stdout);
        if (passedMatch != null) {
          passed = int.parse(passedMatch.group(1)!);
        }
      } else if (line.contains('tests failed')) {
        final failedMatch = RegExp(r'(\d+) test.*failed').firstMatch(stdout);
        if (failedMatch != null) {
          failed = int.parse(failedMatch.group(1)!);
        }
      } else if (line.contains('skipped')) {
        final skippedMatch = RegExp(r'(\d+) test.*skipped').firstMatch(stdout);
        if (skippedMatch != null) {
          skipped = int.parse(skippedMatch.group(1)!);
        }
      }
    }
    
    // Parse stderr for errors
    if (stderr.isNotEmpty) {
      errors.addAll(stderr.split('\n').where((line) => line.trim().isNotEmpty));
    }
    
    // If exit code is non-zero but no specific failures found, mark as failed
    if (exitCode != 0 && failed == 0 && passed == 0) {
      failed = 1;
      errors.add('Tests failed with exit code $exitCode');
    }
    
    return TestResult(
      suiteName: suiteName,
      suitePath: suitePath,
      passed: passed,
      failed: failed,
      skipped: skipped,
      duration: duration,
      errors: errors,
    );
  }

  void _printTestResult(TestResult result) {
    final icon = result.failed > 0 ? '❌' : '✅';
    final status = result.failed > 0 ? 'FAILED' : 'PASSED';
    
    debugPrint('$icon ${result.suiteName}: $status');
    debugPrint('   📊 ${result.passed} passed, ${result.failed} failed, ${result.skipped} skipped');
    debugPrint('   ⏱️  Duration: ${result.duration.inMilliseconds}ms');
    
    if (result.errors.isNotEmpty) {
      debugPrint('   ⚠️  Errors:');
      for (final error in result.errors.take(3)) {
        debugPrint('      - $error');
      }
      if (result.errors.length > 3) {
        debugPrint('      ... and ${result.errors.length - 3} more errors');
      }
    }
    debugPrint('');
  }

  Future<ValidationResult> _validateEnvironment(TestConfig config) async {
    final errors = <String>[];
    
    // Check Flutter is available
    try {
      final result = await Process.run('flutter', ['--version']);
      if (result.exitCode != 0) {
        errors.add('Flutter is not available or not working properly');
      }
    } catch (e) {
      errors.add('Flutter command not found: $e');
    }
    
    // Check Dart is available
    try {
      final result = await Process.run('dart', ['--version']);
      if (result.exitCode != 0) {
        errors.add('Dart is not available or not working properly');
      }
    } catch (e) {
      errors.add('Dart command not found: $e');
    }
    
    // Check test directories exist
    for (final suite in _testSuites) {
      final dir = Directory(suite.path);
      if (!dir.existsSync() && config.categories.contains(suite.name.toLowerCase())) {
        errors.add('Test directory does not exist: ${suite.path}');
      }
    }
    
    return ValidationResult(errors.isEmpty, errors);
  }

  Future<void> _setupTests(TestConfig config) async {
    debugPrint('🔧 Setting up test environment...');
    
    // Ensure dependencies are up to date
    if (!config.skipPubGet) {
      debugPrint('   📦 Running flutter pub get...');
      final result = await Process.run('flutter', ['pub', 'get']);
      if (result.exitCode != 0) {
        debugPrint('   ⚠️  Warning: pub get failed');
      }
    }
    
    // Generate mocks if needed
    if (config.generateMocks) {
      debugPrint('   🤖 Generating mocks...');
      final result = await Process.run('flutter', ['packages', 'pub', 'run', 'build_runner', 'build']);
      if (result.exitCode != 0) {
        debugPrint('   ⚠️  Warning: mock generation failed');
      }
    }
    
    debugPrint('✅ Test environment setup complete.\n');
  }

  Future<void> _cleanupTests(TestConfig config) async {
    if (config.cleanup) {
      debugPrint('🧹 Cleaning up test artifacts...');
      
      // Clean coverage files if not needed
      if (!config.coverage) {
        final coverageDir = Directory('coverage');
        if (coverageDir.existsSync()) {
          await coverageDir.delete(recursive: true);
        }
      }
      
      debugPrint('✅ Cleanup complete.');
    }
  }

  Future<void> _generateReports(List<TestResult> results, TestConfig config, Duration totalDuration) async {
    debugPrint('📋 Test Results Summary:');
    debugPrint('=' * 50);
    
    int totalPassed = 0;
    int totalFailed = 0;
    int totalSkipped = 0;
    
    for (final result in results) {
      totalPassed += result.passed;
      totalFailed += result.failed;
      totalSkipped += result.skipped;
    }
    
    debugPrint('Total Tests: ${totalPassed + totalFailed + totalSkipped}');
    debugPrint('✅ Passed: $totalPassed');
    debugPrint('❌ Failed: $totalFailed');
    debugPrint('⏭️  Skipped: $totalSkipped');
    debugPrint('⏱️  Total Duration: ${totalDuration.inSeconds}s');
    debugPrint('');
    
    if (totalFailed > 0) {
      debugPrint('❌ Failed Test Suites:');
      for (final result in results.where((r) => r.failed > 0)) {
        debugPrint('   - ${result.suiteName}');
      }
      debugPrint('');
    }
    
    // Generate coverage report if requested
    if (config.coverage && totalFailed == 0) {
      await _generateCoverageReport();
    }
    
    // Generate JUnit XML if requested
    if (config.junitOutput.isNotEmpty) {
      await _generateJUnitReport(results, config.junitOutput);
    }
  }

  Future<void> _generateCoverageReport() async {
    debugPrint('📊 Generating coverage report...');
    
    try {
      // Convert to LCOV
      await Process.run('flutter', ['test', '--coverage']);
      
      // Generate HTML report if lcov is available
      final lcovResult = await Process.run('which', ['genhtml']);
      if (lcovResult.exitCode == 0) {
        await Process.run('genhtml', [
          'coverage/lcov.info',
          '-o',
          'coverage/html',
          '--title',
          'Zenu Test Coverage',
        ]);
        debugPrint('✅ Coverage report generated: coverage/html/index.html');
      } else {
        debugPrint('✅ Coverage data generated: coverage/lcov.info');
        debugPrint('   Install lcov to generate HTML reports: brew install lcov');
      }
    } catch (e) {
      debugPrint('⚠️  Failed to generate coverage report: $e');
    }
  }

  Future<void> _generateJUnitReport(List<TestResult> results, String outputPath) async {
    debugPrint('📄 Generating JUnit XML report...');
    
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<testsuites>');
    
    for (final result in results) {
      buffer.writeln('  <testsuite name="${result.suiteName}" '
                    'tests="${result.passed + result.failed + result.skipped}" '
                    'failures="${result.failed}" '
                    'skipped="${result.skipped}" '
                    'time="${result.duration.inMilliseconds / 1000}">');
      
      // Add individual test cases (simplified)
      for (int i = 0; i < result.passed; i++) {
        buffer.writeln('    <testcase name="Test ${i + 1}" classname="${result.suiteName}"/>');
      }
      
      for (int i = 0; i < result.failed; i++) {
        buffer.writeln('    <testcase name="Failed Test ${i + 1}" classname="${result.suiteName}">');
        buffer.writeln('      <failure message="Test failed"/>');
        buffer.writeln('    </testcase>');
      }
      
      buffer.writeln('  </testsuite>');
    }
    
    buffer.writeln('</testsuites>');
    
    final file = File(outputPath);
    await file.writeAsString(buffer.toString());
    
    debugPrint('✅ JUnit report generated: $outputPath');
  }

  void _printHelp() {
    debugPrint('''
Zenu Test Runner

USAGE:
    dart test/scripts/test_runner.dart [OPTIONS]

OPTIONS:
    --platform <PLATFORM>     Run tests for specific platform (android, ios, windows, macos, linux, web, all)
    --category <CATEGORY>      Run specific test categories (unit, widget, integration, platform)
    --file <FILE>              Run specific test file or directory
    --parallel                 Run test suites in parallel
    --concurrency <N>          Number of parallel test suites (default: 4)
    --coverage                 Generate test coverage
    --fail-fast                Stop on first failure
    --verbose                  Verbose test output
    --reporter <REPORTER>      Test reporter (json, compact, expanded)
    --timeout <TIMEOUT>        Test timeout (default: 30s)
    --no-pub-get              Skip flutter pub get
    --no-generate-mocks       Skip mock generation
    --cleanup                 Clean up test artifacts after run
    --junit-output <FILE>     Generate JUnit XML report
    --list-suites             List available test suites
    --help                    Show this help message

EXAMPLES:
    # Run all tests
    dart test/scripts/test_runner.dart

    # Run only unit tests
    dart test/scripts/test_runner.dart --category unit

    # Run Android platform tests with coverage
    dart test/scripts/test_runner.dart --platform android --coverage

    # Run tests in parallel with fail-fast
    dart test/scripts/test_runner.dart --parallel --fail-fast

    # Run specific test file
    dart test/scripts/test_runner.dart --file test/services/reminder_service_test.dart

    # Generate coverage and JUnit report
    dart test/scripts/test_runner.dart --coverage --junit-output test-results.xml
''');
  }

  void _listTestSuites() {
    debugPrint('Available Test Suites:');
    debugPrint('=' * 40);
    
    for (final suite in _testSuites) {
      debugPrint(suite.name);
      debugPrint('  Path: ${suite.path}');
      debugPrint('  Priority: ${suite.priority}');
      debugPrint('  Platforms: ${suite.platforms.map((p) => p.name).join(', ')}');
      debugPrint('  Timeout: ${suite.timeout}');
      if (suite.requiresDevice) {
        debugPrint('  Requires Device: Yes');
      }
      debugPrint('');
    }
  }
}

// Data classes and enums
enum TestPlatform { android, ios, windows, macos, linux, web, all }

class TestSuite {
  const TestSuite({
    required this.name,
    required this.path,
    required this.priority,
    required this.platforms,
    this.timeout = '30s',
    this.requiresDevice = false,
  });

  final String name;
  final String path;
  final int priority;
  final List<TestPlatform> platforms;
  final String timeout;
  final bool requiresDevice;
}

class TestConfig {
  const TestConfig({
    this.platform,
    this.categories = const [],
    this.testFiles = const [],
    this.parallel = false,
    this.concurrency = 4,
    this.coverage = false,
    this.failFast = false,
    this.verbose = false,
    this.reporter = 'expanded',
    this.timeout = '30s',
    this.skipPubGet = false,
    this.generateMocks = true,
    this.cleanup = false,
    this.junitOutput = '',
    this.listSuites = false,
    this.showHelp = false,
  });

  final TestPlatform? platform;
  final List<String> categories;
  final List<String> testFiles;
  final bool parallel;
  final int concurrency;
  final bool coverage;
  final bool failFast;
  final bool verbose;
  final String reporter;
  final String timeout;
  final bool skipPubGet;
  final bool generateMocks;
  final bool cleanup;
  final String junitOutput;
  final bool listSuites;
  final bool showHelp;

  factory TestConfig.fromArgs(List<String> args) {
    TestPlatform? platform;
    final categories = <String>[];
    final testFiles = <String>[];
    bool parallel = false;
    int concurrency = 4;
    bool coverage = false;
    bool failFast = false;
    bool verbose = false;
    String reporter = 'expanded';
    String timeout = '30s';
    bool skipPubGet = false;
    bool generateMocks = true;
    bool cleanup = false;
    String junitOutput = '';
    bool listSuites = false;
    bool showHelp = false;

    for (int i = 0; i < args.length; i++) {
      switch (args[i]) {
        case '--platform':
          if (i + 1 < args.length) {
            platform = TestPlatform.values.firstWhere(
              (p) => p.name == args[++i],
              orElse: () => TestPlatform.all,
            );
          }
          break;
        case '--category':
          if (i + 1 < args.length) {
            categories.add(args[++i]);
          }
          break;
        case '--file':
          if (i + 1 < args.length) {
            testFiles.add(args[++i]);
          }
          break;
        case '--parallel':
          parallel = true;
          break;
        case '--concurrency':
          if (i + 1 < args.length) {
            concurrency = int.tryParse(args[++i]) ?? 4;
          }
          break;
        case '--coverage':
          coverage = true;
          break;
        case '--fail-fast':
          failFast = true;
          break;
        case '--verbose':
          verbose = true;
          break;
        case '--reporter':
          if (i + 1 < args.length) {
            reporter = args[++i];
          }
          break;
        case '--timeout':
          if (i + 1 < args.length) {
            timeout = args[++i];
          }
          break;
        case '--no-pub-get':
          skipPubGet = true;
          break;
        case '--no-generate-mocks':
          generateMocks = false;
          break;
        case '--cleanup':
          cleanup = true;
          break;
        case '--junit-output':
          if (i + 1 < args.length) {
            junitOutput = args[++i];
          }
          break;
        case '--list-suites':
          listSuites = true;
          break;
        case '--help':
          showHelp = true;
          break;
      }
    }

    return TestConfig(
      platform: platform,
      categories: categories,
      testFiles: testFiles,
      parallel: parallel,
      concurrency: concurrency,
      coverage: coverage,
      failFast: failFast,
      verbose: verbose,
      reporter: reporter,
      timeout: timeout,
      skipPubGet: skipPubGet,
      generateMocks: generateMocks,
      cleanup: cleanup,
      junitOutput: junitOutput,
      listSuites: listSuites,
      showHelp: showHelp,
    );
  }

  @override
  String toString() {
    final parts = <String>[];
    if (platform != null) parts.add('platform=${platform!.name}');
    if (categories.isNotEmpty) parts.add('categories=${categories.join(',')}');
    if (parallel) parts.add('parallel=true');
    if (coverage) parts.add('coverage=true');
    if (failFast) parts.add('fail-fast=true');
    return parts.join(', ');
  }
}

class TestResult {
  const TestResult({
    required this.suiteName,
    required this.suitePath,
    required this.passed,
    required this.failed,
    required this.skipped,
    required this.duration,
    required this.errors,
  });

  final String suiteName;
  final String suitePath;
  final int passed;
  final int failed;
  final int skipped;
  final Duration duration;
  final List<String> errors;
}

class ValidationResult {
  const ValidationResult(this.isValid, this.errors);
  
  final bool isValid;
  final List<String> errors;
}

class Semaphore {
  Semaphore(this.maxCount) : _currentCount = maxCount;
  
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();
  
  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    }
    
    final completer = Completer<void>();
    _waitQueue.add(completer);
    return completer.future;
  }
  
  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}
