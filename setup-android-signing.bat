@echo off
echo ========================================
echo Codiny App - Setup Android Signing
echo ========================================
echo.

set KEYSTORE_PATH=%USERPROFILE%\codiny-upload-keystore.jks
set KEY_PROPERTIES=codiny_platform_app\android\key.properties

REM Check if keystore exists
if not exist "%KEYSTORE_PATH%" (
    echo ERROR: Keystore not found at: %KEYSTORE_PATH%
    echo Please run generate-signing-key.bat first!
    echo.
    pause
    exit /b 1
)

echo Keystore found at: %KEYSTORE_PATH%
echo.
echo Please enter your signing key information:
echo (These should match what you used when creating the keystore)
echo.

set /p "STORE_PASSWORD=Enter keystore password: "
set /p "KEY_PASSWORD=Enter key password: "
set "KEY_ALIAS=upload"

REM Create key.properties file
echo Creating key.properties file...
(
    echo storePassword=%STORE_PASSWORD%
    echo keyPassword=%KEY_PASSWORD%
    echo keyAlias=%KEY_ALIAS%
    echo storeFile=%KEYSTORE_PATH:\=/%
) > "%KEY_PROPERTIES%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS! Android signing configured!
    echo ========================================
    echo.
    echo Configuration saved to: %KEY_PROPERTIES%
    echo.
    echo NEXT STEPS:
    echo 1. Run: build-release.bat to build your release app
    echo 2. The app will be signed with your keystore automatically
    echo.
    echo IMPORTANT:
    echo - NEVER commit key.properties to Git
    echo - Keep your keystore file safe
    echo - Remember your passwords
    echo.
) else (
    echo.
    echo ERROR: Failed to create key.properties file!
    echo.
)

pause
