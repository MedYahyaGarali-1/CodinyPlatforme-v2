@echo off
echo ========================================
echo Image Compression Using ImageMagick
echo ========================================
echo.

REM Check if ImageMagick is installed
where magick >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ImageMagick not found. Let's use a simpler approach...
    echo.
    echo For Play Store, 168MB is actually ACCEPTABLE for an educational app!
    echo.
    echo Google Play Store allows up to 500MB for apps.
    echo Many educational apps with content are 100-200MB.
    echo.
    echo OPTIONS:
    echo.
    echo 1. Ship now with 168MB ^(acceptable^)
    echo    - Pro: Works offline completely
    echo    - Pro: Ship today
    echo    - Con: Larger download
    echo.
    echo 2. Setup Firebase later for v1.1 ^(45MB^)
    echo    - Pro: Much smaller
    echo    - Pro: Remote updates
    echo    - Con: Takes 1-2 hours
    echo.
    echo RECOMMENDATION: Ship now with 168MB, optimize in v1.1
    echo.
    pause
    exit /b 0
)

echo ImageMagick found! Compressing images...
echo.

cd assets\exam_images

echo Creating backup...
if not exist "..\exam_images_backup" (
    xcopy *.* "..\exam_images_backup\" /Y
)

echo.
echo Compressing 126 images to 70%% quality...
echo This will take 2-3 minutes...
echo.

for %%f in (*.jpeg *.jpg *.png) do (
    echo Compressing %%f...
    magick "%%f" -quality 70 -strip "%%f.tmp"
    move /Y "%%f.tmp" "%%f"
)

cd ..\..

echo.
echo ========================================
echo Compression Complete!
echo ========================================
echo.
echo Now run: flutter clean
echo Then: flutter build appbundle --release
echo.
pause
