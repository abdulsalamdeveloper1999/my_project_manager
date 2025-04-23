# PowerShell script to run the Flutter app with admin privileges
Write-Host "Time Tracker Pro - Administrator Mode Setup" -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "This script must run with administrator privileges." -ForegroundColor Red
    Write-Host "Please right-click the script and select 'Run as administrator'." -ForegroundColor Red
    exit
}

# Step 1: Clean up build directory
Write-Host "Step 1: Cleaning up build directory..." -ForegroundColor Cyan
if (Test-Path -Path ".\build") {
    Write-Host "Removing existing build directory..."
    Remove-Item -Recurse -Force .\build -ErrorAction SilentlyContinue
    if ($?) {
        Write-Host "Build directory removed successfully." -ForegroundColor Green
    } else {
        Write-Host "Warning: Could not completely remove build directory. Continuing anyway..." -ForegroundColor Yellow
    }
} else {
    Write-Host "No build directory found. Continuing..." -ForegroundColor Green
}

# Step 2: Get packages
Write-Host "Step 2: Getting packages..." -ForegroundColor Cyan
flutter pub get
if ($?) {
    Write-Host "Packages downloaded successfully." -ForegroundColor Green
} else {
    Write-Host "Error getting packages. Please check your internet connection." -ForegroundColor Red
    exit
}

# Step 3: Run the Windows app
Write-Host "Step 3: Running application..." -ForegroundColor Cyan
Write-Host "This may take a minute for the first build..." -ForegroundColor Yellow
flutter run -d windows
if ($?) {
    Write-Host "Application ran successfully." -ForegroundColor Green
} else {
    Write-Host "Error running application." -ForegroundColor Red
    
    # Additional information for debugging
    Write-Host "Additional debugging information:" -ForegroundColor Cyan
    Write-Host "Flutter doctor output:" -ForegroundColor Cyan
    flutter doctor -v
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 