# PowerShell script to run the package installer
param()

Write-Host "Starting package installation..." -ForegroundColor Green
Write-Host ""

# Function to check for Python
function Test-Python {
    $pythonCommands = @("python", "python3", "py")

    foreach ($cmd in $pythonCommands) {
        try {
            $version = & $cmd --version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Found Python using '$cmd': $version" -ForegroundColor Yellow
                return $cmd
            }
        } catch {
            # Continue to next command
        }
    }
    return $null
}

# Check if Python is available
$pythonCmd = Test-Python
if (-not $pythonCmd) {
    Write-Host "Python is not installed or not in PATH." -ForegroundColor Red
    Write-Host ""
    Write-Host "Attempting to install Python using WinGet..." -ForegroundColor Yellow

    try {
        winget install --id Python.Python.3.12 --silent --exact
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Python installed successfully! Please restart this script." -ForegroundColor Green
        } else {
            Write-Host "Failed to install Python automatically." -ForegroundColor Red
            Write-Host "Please install Python manually from https://python.org or Microsoft Store" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "WinGet not available. Please install Python manually from https://python.org" -ForegroundColor Yellow
    }

    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Change to the script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Run the Python script
Write-Host "Running package installer..." -ForegroundColor Green
try {
    & $pythonCmd install_packages.py
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Script encountered an error (Exit code: $LASTEXITCODE)" -ForegroundColor Red
    } else {
        Write-Host "Script completed successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host "Failed to run the Python script: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Script execution completed." -ForegroundColor Cyan
Read-Host "Press Enter to exit"
