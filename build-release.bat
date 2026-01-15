@echo off
echo ========================================
echo Codiny App - Build Release Version
echo ========================================
echo.

REM Check if Flutter is available
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter not found in PATH!
    echo Please install Flutter and ensure it's in your PATH
    echo Download from: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Check if key.properties exists
set KEY_PROPERTIES=codiny_platform_app\android\key.properties
if not exist "%KEY_PROPERTIES%" (
    echo WARNING: key.properties not found!
    echo The app will be signed with debug key (NOT suitable for Play Store)
    echo.
    echo To fix this:
    echo 1. Run: generate-signing-key.bat
    echo 2. Run: setup-android-signing.bat
    echo 3. Run this script again
    echo.
    set /p "CONTINUE=Continue anyway? (yes/no): "
    if /i not "%CONTINUE%"=="yes" (
        echo Build cancelled.
        pause
        exit /b 0
    )
)

cd codiny_platform_app

echo.
echo Cleaning previous builds...
call flutter clean

echo.
echo Getting dependencies...
call flutter pub get

echo.
echo Choose build type:
echo 1. App Bundle (AAB) - Recommended for Play Store
echo 2. APK - For direct installation
echo 3. Both
echo.
set /p "BUILD_TYPE=Enter choice (1-3): "

if "%BUILD_TYPE%"=="1" goto BUILD_AAB
if "%BUILD_TYPE%"=="2" goto BUILD_APK
if "%BUILD_TYPE%"=="3" goto BUILD_BOTH
echo Invalid choice!
goto END

:BUILD_AAB
echo.
echo Building App Bundle (AAB)...
call flutter build appbundle --release
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS! App Bundle built successfully!
    echo ========================================
    echo.
    echo Location: build\app\outputs\bundle\release\app-release.aab
    echo.
    echo This file is ready to upload to Google Play Console!
    echo.
)
goto END

:BUILD_APK
echo.
echo Building APK...
call flutter build apk --release
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS! APK built successfully!
    echo ========================================
    echo.
    echo Location: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo You can install this on Android devices directly.
    echo.
)
goto END

:BUILD_BOTH
echo.
echo Building App Bundle (AAB)...
call flutter build appbundle --release
echo.
echo Building APK...
call flutter build apk --release
if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS! Both builds completed!
    echo ========================================
    echo.
    echo App Bundle: build\app\outputs\bundle\release\app-release.aab
    echo APK: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo Upload the AAB file to Google Play Console!
    echo.
)

:END
cd ..
pause
