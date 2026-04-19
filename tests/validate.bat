@echo off
REM Full-stack validation (Windows wrapper).
REM Delegates to validate.sh via bash; the .sh owns all the real logic
REM so there is only one source of truth for validation stages.
setlocal

where bash >nul 2>nul
if errorlevel 1 (
    echo [!] bash not found on PATH. Install Git for Windows or run from a bash shell.
    exit /b 2
)

bash "%~dp0validate.sh" %*
exit /b %ERRORLEVEL%
