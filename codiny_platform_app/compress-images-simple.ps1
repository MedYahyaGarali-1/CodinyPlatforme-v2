# Simple Image Compression Script
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Codiny App - Image Compression" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$sourcePath = "assets\exam_images"
$backupPath = "assets\exam_images_backup"

if (-not (Test-Path $sourcePath)) {
    Write-Host "ERROR: $sourcePath not found!" -ForegroundColor Red
    pause
    exit
}

Write-Host "Creating backup..." -ForegroundColor Yellow
if (-not (Test-Path $backupPath)) {
    Copy-Item -Path $sourcePath -Destination $backupPath -Recurse
    Write-Host "Backup created!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Compressing images to 70% quality..." -ForegroundColor Yellow
Write-Host ""

Add-Type -AssemblyName System.Drawing

$files = Get-ChildItem -Path $sourcePath -Include *.jpg,*.jpeg,*.png -File
$total = $files.Count
$count = 0
$originalTotal = 0
$compressedTotal = 0

foreach ($file in $files) {
    $count++
    $percent = [math]::Round(($count / $total) * 100)
    Write-Host "[$count/$total] $percent% - Processing $($file.Name)..." -NoNewline
    
    $originalSize = $file.Length
    $originalTotal += $originalSize
    
    try {
        $img = [System.Drawing.Image]::FromFile($file.FullName)
        $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 70L)
        
        $tempFile = $file.FullName + ".tmp"
        $img.Save($tempFile, $jpegCodec, $encoderParams)
        $img.Dispose()
        
        $newName = [System.IO.Path]::ChangeExtension($file.FullName, ".jpeg")
        Move-Item -Path $tempFile -Destination $newName -Force
        
        if ($file.Extension -ne ".jpeg") {
            Remove-Item $file.FullName -Force -ErrorAction SilentlyContinue
        }
        
        $compressedSize = (Get-Item $newName).Length
        $compressedTotal += $compressedSize
        $savings = [math]::Round((($originalSize - $compressedSize) / $originalSize) * 100, 1)
        
        Write-Host " Done! (Saved $savings%)" -ForegroundColor Green
    }
    catch {
        Write-Host " Failed!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Compression Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Original Size:   $([math]::Round($originalTotal / 1MB, 2)) MB" -ForegroundColor Yellow
Write-Host "Compressed Size: $([math]::Round($compressedTotal / 1MB, 2)) MB" -ForegroundColor Green
Write-Host "Total Savings:   $([math]::Round((($originalTotal - $compressedTotal) / $originalTotal) * 100, 1))%" -ForegroundColor Green
Write-Host ""
Write-Host "Backup saved at: $backupPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: flutter clean && flutter build appbundle --release" -ForegroundColor White
Write-Host ""
pause
