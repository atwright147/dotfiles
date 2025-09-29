@echo off
echo Starting package installation...
echo.

REM Try different Python commands
set PYTHON_CMD=
python --version >nul 2>&1
if %errorlevel% equ 0 (
    set PYTHON_CMD=python
    goto :python_found
)

python3 --version >nul 2>&1
if %errorlevel% equ 0 (
    set PYTHON_CMD=python3
    goto :python_found
)

py --version >nul 2>&1
if %errorlevel% equ 0 (
    set PYTHON_CMD=py
    goto :python_found
)

REM Python not found, try to install it
echo Python is not installed or not in PATH.
echo Attempting to install Python using WinGet...
winget install --id Python.Python.3.12 --silent --exact
if %errorlevel% equ 0 (
    echo Python installed! Please restart this script.
) else (
    echo Failed to install Python automatically.
    echo Please install Python from https://python.org or Microsoft Store
)
echo.
pause
exit /b 1

:python_found
echo Found Python: %PYTHON_CMD%

REM Run the Python script
echo Running package installer...
%PYTHON_CMD% install_packages.py

REM Check if the script ran successfully
if %errorlevel% neq 0 (
    echo.
    echo Script encountered an error.
)

echo.
echo Script execution completed.
pause
