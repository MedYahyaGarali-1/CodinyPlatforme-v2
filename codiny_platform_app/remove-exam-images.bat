@echo off
echo ========================================
echo Remove Exam Images from App Bundle
echo ========================================
echo.
echo WARNING: Only run this AFTER uploading images to Firebase!
echo.
echo This will:
echo 1. Backup exam images to exam_images_BACKUP
echo 2. Remove all images from assets\exam_images\
echo 3. Keep folder structure (required for build)
echo.
set /p "CONFIRM=Have you uploaded ALL images to Firebase? (yes/no): "

if /i not "%CONFIRM%"=="yes" (
    echo.
    echo Operation cancelled. Please upload images to Firebase first!
    echo See FIREBASE_SETUP.md for instructions.
    pause
    exit /b 0
)

echo.
echo Creating backup...
if not exist "assets\exam_images_BACKUP" (
    xcopy "assets\exam_images" "assets\exam_images_BACKUP\" /E /I /Y
    echo Backup created at: assets\exam_images_BACKUP
) else (
    echo Backup already exists, skipping...
)

echo.
echo Removing exam images from bundle...
del /Q "assets\exam_images\*.*"

echo.
echo Creating .gitkeep file...
type nul > "assets\exam_images\.gitkeep"

echo.
echo ========================================
echo Success! Exam images removed from bundle
echo ========================================
echo.
echo App size will be reduced by ~120MB!
echo.
echo Next steps:
echo 1. Run: flutter clean
echo 2. Run: flutter pub get
echo 3. Run: flutter build appbundle --release
echo.
echo Expected app size: ~45-50MB
echo.
pause
