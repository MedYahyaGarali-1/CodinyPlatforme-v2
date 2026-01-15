@echo off
echo ========================================
echo Codiny App - Image Compression Tool
echo ========================================
echo.
echo This will compress all exam images to reduce app size
echo from ~120MB to ~30-40MB (70%% reduction)
echo.
echo Requirements:
echo - ImageMagick or similar tool
echo.
pause

cd assets\exam_images

echo Compressing images...
echo This may take several minutes...
echo.

REM Using PowerShell to compress images
powershell -Command "& {Get-ChildItem -Filter *.png,*.jpg,*.jpeg | ForEach-Object { Write-Host 'Compressing' $_.Name; Add-Type -AssemblyName System.Drawing; $img = [System.Drawing.Image]::FromFile($_.FullName); $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }; $params = New-Object System.Drawing.Imaging.EncoderParameters(1); $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 75L); $img.Save($_.FullName + '.tmp.jpg', $encoder, $params); $img.Dispose(); Move-Item -Force ($_.FullName + '.tmp.jpg') $_.FullName }}"

cd ..\..

echo.
echo ========================================
echo Compression complete!
echo ========================================
echo.
echo Please rebuild your app:
echo flutter build appbundle --release
echo.
pause
