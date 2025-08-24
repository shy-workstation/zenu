# Zenu Windows Production Build Script
param(
    [switch]$SkipTests,
    [switch]$SkipMSIX,
    [switch]$Verbose,
    [switch]$Clean,
    [string]$OutputPath = "release"
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "     Building Zenu for Windows Production" -ForegroundColor Cyan  
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Error handling
$ErrorActionPreference = "Stop"

try {
    # Check Flutter installation
    Write-Host "🔍 Checking Flutter installation..." -ForegroundColor Yellow
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter is not installed or not in PATH"
    }
    Write-Host "✅ Flutter found" -ForegroundColor Green
    
    # Setup paths
    $ProjectDir = Get-Location
    $ReleaseDir = Join-Path $ProjectDir $OutputPath
    $BuildDir = Join-Path $ProjectDir "build\windows\x64\runner\Release"
    
    Write-Host "📁 Project Directory: $ProjectDir" -ForegroundColor Gray
    Write-Host "📁 Release Directory: $ReleaseDir" -ForegroundColor Gray
    Write-Host ""
    
    # Clean previous builds if requested
    if ($Clean -or $true) {  # Always clean for production
        Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Yellow
        if (Test-Path $BuildDir) {
            Remove-Item $BuildDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $ReleaseDir) {
            Get-ChildItem $ReleaseDir -Include "*.exe", "*.dll" -Force | Remove-Item -Force -ErrorAction SilentlyContinue
        }
        Write-Host "✅ Cleanup completed" -ForegroundColor Green
    }
    
    # Create release directory
    if (-not (Test-Path $ReleaseDir)) {
        New-Item -Path $ReleaseDir -ItemType Directory -Force | Out-Null
    }
    
    # Get dependencies
    Write-Host "📦 Getting Flutter dependencies..." -ForegroundColor Yellow
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to get Flutter dependencies"
    }
    Write-Host "✅ Dependencies retrieved" -ForegroundColor Green
    
    # Generate build files
    Write-Host "⚙️ Generating build files..." -ForegroundColor Yellow
    flutter pub run build_runner build --delete-conflicting-outputs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "⚠️ Build runner failed, but continuing..." -ForegroundColor Yellow
    } else {
        Write-Host "✅ Build files generated" -ForegroundColor Green
    }
    
    # Run tests unless skipped
    if (-not $SkipTests) {
        Write-Host "🧪 Running tests..." -ForegroundColor Yellow
        flutter test
        if ($LASTEXITCODE -ne 0) {
            Write-Host "⚠️ Some tests failed, but continuing build..." -ForegroundColor Yellow
        } else {
            Write-Host "✅ All tests passed" -ForegroundColor Green
        }
    } else {
        Write-Host "⏭️ Skipping tests" -ForegroundColor Yellow
    }
    
    # Build Flutter app
    Write-Host "🏗️ Building Flutter Windows release..." -ForegroundColor Yellow
    $buildArgs = @("build", "windows", "--release")
    if ($Verbose) {
        $buildArgs += "--verbose"
    }
    
    & flutter @buildArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter build failed"
    }
    Write-Host "✅ Flutter build completed" -ForegroundColor Green
    
    # Copy built files
    Write-Host "📋 Copying build artifacts..." -ForegroundColor Yellow
    
    $exePath = Join-Path $BuildDir "zenu.exe"
    if (Test-Path $exePath) {
        Copy-Item $exePath (Join-Path $ReleaseDir "Zenu.exe") -Force
        Write-Host "  ✅ Executable copied" -ForegroundColor Green
    } else {
        throw "Built executable not found at $exePath"
    }
    
    # Copy DLLs
    $dlls = Get-ChildItem $BuildDir -Filter "*.dll"
    foreach ($dll in $dlls) {
        Copy-Item $dll.FullName $ReleaseDir -Force
        Write-Host "  📄 $($dll.Name)" -ForegroundColor Gray
    }
    Write-Host "✅ Libraries copied" -ForegroundColor Green
    
    # Copy data directory
    $dataDir = Join-Path $BuildDir "data"
    if (Test-Path $dataDir) {
        $releaseDataDir = Join-Path $ReleaseDir "data"
        if (Test-Path $releaseDataDir) {
            Remove-Item $releaseDataDir -Recurse -Force
        }
        Copy-Item $dataDir $releaseDataDir -Recurse -Force
        Write-Host "✅ Data directory copied" -ForegroundColor Green
    }
    
    # Build MSIX package unless skipped
    if (-not $SkipMSIX) {
        Write-Host "📦 Building MSIX package..." -ForegroundColor Yellow
        flutter pub run msix:create
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ MSIX package created" -ForegroundColor Green
            # Copy MSIX to release directory
            $msixFiles = Get-ChildItem "$BuildDir" -Filter "*.msix"
            foreach ($msixFile in $msixFiles) {
                Copy-Item $msixFile.FullName $ReleaseDir -Force
                Write-Host "  📦 $($msixFile.Name)" -ForegroundColor Gray
            }
        } else {
            Write-Host "⚠️ MSIX package creation failed" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⏭️ Skipping MSIX package creation" -ForegroundColor Yellow
    }
    
    # Generate checksums
    Write-Host "🔐 Generating checksums..." -ForegroundColor Yellow
    $exeFile = Join-Path $ReleaseDir "Zenu.exe"
    if (Test-Path $exeFile) {
        $hash = Get-FileHash $exeFile -Algorithm SHA256
        $hash.Hash | Out-File "$exeFile.sha256" -Encoding UTF8
        Write-Host "✅ SHA256: $($hash.Hash.Substring(0,16))..." -ForegroundColor Green
    }
    
    # Create version info
    Write-Host "📄 Creating version info..." -ForegroundColor Yellow
    $versionInfo = @"
Version: 1.0.2
Build Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Platform: Windows x64
Environment: Production
Flutter Version:
$($flutterVersion | Out-String)
Build Configuration:
- Tests Skipped: $SkipTests
- MSIX Skipped: $SkipMSIX
- Verbose: $Verbose
- Clean Build: $Clean
"@
    
    $versionInfo | Out-File (Join-Path $ReleaseDir "version.txt") -Encoding UTF8
    Write-Host "✅ Version info created" -ForegroundColor Green
    
    # Display results
    Write-Host ""
    Write-Host "📋 Release Contents:" -ForegroundColor Cyan
    Get-ChildItem $ReleaseDir | ForEach-Object {
        $size = if ($_.PSIsContainer) { "DIR" } else { "$([math]::Round($_.Length / 1KB, 1)) KB" }
        Write-Host "  📄 $($_.Name) ($size)" -ForegroundColor Gray
    }
    
    # Calculate total size
    $totalSize = (Get-ChildItem $ReleaseDir -Recurse | Measure-Object -Property Length -Sum).Sum
    Write-Host ""
    Write-Host "💾 Total release size: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "✅ Build completed successfully!" -ForegroundColor Green
    Write-Host "📁 Release files are in: $ReleaseDir" -ForegroundColor Cyan
    
    # Test build option
    $testBuild = Read-Host "Would you like to test the build? (y/n)"
    if ($testBuild -eq "y" -or $testBuild -eq "Y") {
        Write-Host ""
        Write-Host "🚀 Starting Zenu..." -ForegroundColor Yellow
        Start-Process (Join-Path $ReleaseDir "Zenu.exe")
    }
    
    Write-Host ""
    Write-Host "🎉 Build process complete!" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")