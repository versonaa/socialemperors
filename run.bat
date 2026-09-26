@echo off
setlocal
rem Social Emperors - update from GitHub, then run the local server.
rem Double-click to start. Press Ctrl+C (or close the window) to stop the server.

set "BRANCH=claude/lucid-goodall-5ks1y2"

rem Run from a temporary copy so "git pull" can safely update this file.
if /i not "%~1"=="--child" (
    copy /y "%~f0" "%TEMP%\socialemperors_run.bat" >nul
    call "%TEMP%\socialemperors_run.bat" --child "%~dp0."
    exit /b
)

cd /d "%~2"
title Social Emperors Server

rem ---------------------------------------------------------------- checks

git --version >nul 2>&1
if errorlevel 1 (
    echo [!] Git not found. Install it from https://git-scm.com/ and try again.
    goto :fatal
)
python --version >nul 2>&1
if errorlevel 1 (
    echo [!] Python not found. Install it from https://www.python.org/
    echo     and tick "Add Python to PATH" during installation.
    goto :fatal
)

rem ---------------------------------------------------------------- update

echo [+] Fetching updates from GitHub...
git fetch origin
if errorlevel 1 goto :update_failed

git show-ref --verify --quiet "refs/remotes/origin/%BRANCH%"
if errorlevel 1 (
    echo [i] Branch %BRANCH% is not on GitHub yet, staying on the current branch.
    git pull --ff-only
    if errorlevel 1 goto :update_failed
    goto :deps
)

git checkout "%BRANCH%"
if errorlevel 1 goto :update_failed
git pull --ff-only origin "%BRANCH%"
if errorlevel 1 goto :update_failed
goto :deps

:update_failed
echo.
echo [!] Update failed, running the code you already have.
echo     If you edited files locally, these changes may be blocking the update:
git status --short
echo.

rem ---------------------------------------------------------- dependencies

:deps
if not exist ".venv\Scripts\python.exe" (
    echo [+] Creating virtual environment in .venv ...
    python -m venv .venv
    if errorlevel 1 goto :fatal
)
echo [+] Installing requirements...
".venv\Scripts\python.exe" -m pip install --disable-pip-version-check -q -r requirements.txt
if errorlevel 1 echo [!] Could not install requirements, trying to start anyway.

rem ------------------------------------------------------------------- run

echo.
echo [+] Starting server. Open http://127.0.0.1:5050/ in FlashBrowser.
echo.
".venv\Scripts\python.exe" server.py
echo.
echo [i] Server stopped.
pause
exit /b 0

:fatal
pause
exit /b 1
