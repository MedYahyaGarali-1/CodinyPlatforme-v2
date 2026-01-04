@echo off
cls
echo.
echo ===============================================
echo    CODINY PLATFORM - SYSTEM DIAGNOSTICS
echo ===============================================
echo.
echo Choose how to run:
echo.
echo 1. Run diagnostics on Railway (recommended)
echo 2. Run diagnostics locally (needs .env file)
echo 3. Show file locations
echo 4. Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" goto railway
if "%choice%"=="2" goto local
if "%choice%"=="3" goto locations
if "%choice%"=="4" goto end

:railway
echo.
echo Running diagnostics on Railway...
echo.
cd backend
railway run node diagnostic-check.js
pause
goto end

:local
echo.
echo Running diagnostics locally...
echo.
cd backend
node diagnostic-check.js
pause
goto end

:locations
echo.
echo Diagnostic File:
echo %cd%\backend\diagnostic-check.js
echo.
echo Guide File:
echo %cd%\DIAGNOSTIC_GUIDE.md
echo.
pause
goto end

:end
echo.
echo Goodbye!
echo.
