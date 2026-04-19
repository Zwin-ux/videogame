@echo off
REM Hive Signal test runner (Windows). Requires Godot 4.6+ on PATH.
setlocal

where godot >nul 2>nul
if errorlevel 1 (
    echo [!] 'godot' not found on PATH.
    echo     Install Godot 4.6+ and add it to PATH, or set GODOT env var.
    exit /b 2
)

godot --headless --script tests/run_tests.gd
exit /b %ERRORLEVEL%
