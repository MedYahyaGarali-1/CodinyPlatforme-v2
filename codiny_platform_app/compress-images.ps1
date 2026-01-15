# Image Compression Script for Codiny App
# This will compress all exam images to reduce app size

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Codiny App - Image Compression" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$sourcePath = "assets\exam_images"
$backupPath = "assets\exam_images_backup"

# Check if source exists
if (-not (Test-Path $sourcePath)) {
    Write-Host "ERROR: $sourcePath not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Create backup
Write-Host "Creating backup of original images..." -ForegroundColor Yellow
if (-not (Test-Path $backupPath)) {
    Copy-Item -Path $sourcePath -Destination $backupPath -Recurse
    Write-Host "Backup created at: $backupPath" -ForegroundColor Green
} else {
    Write-Host "Backup already exists, skipping..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting compression..." -ForegroundColor Yellow
Write-Host "Target quality: 70% (good balance of size and quality)" -ForegroundColor Yellow
Write-Host ""

# Load System.Drawing assembly
Add-Type -AssemblyName System.Drawing

$files = Get-ChildItem -Path $sourcePath -Include *.jpg,*.jpeg,*.png -File
$totalFiles = $files.Count
$currentFile = 0
$totalOriginalSize = 0
$totalCompressedSize = 0

foreach ($file in $files) {
    $currentFile++
    $originalSize = $file.Length
    $totalOriginalSize += $originalSize
    
    Write-Progress -Activity "Compressing Images" -Status "Processing $($file.Name)" -PercentComplete (($currentFile / $totalFiles) * 100)
    
    try {
        # Load the image
        $img = [System.Drawing.Image]::FromFile($file.FullName)
        
        # Get JPEG encoder
        $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
        
        # Set quality to 70%
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 70L)
        
        # Save compressed image to temp file
        $tempFile = $file.FullName + ".tmp"
        $img.Save($tempFile, $jpegCodec, $encoderParams)
        $img.Dispose()
        
        # Replace original with compressed
        $newName = [System.IO.Path]::ChangeExtension($file.FullName, ".jpeg")
        Move-Item -Path $tempFile -Destination $newName -Force
        
        # If original wasn't .jpeg, delete it
        if ($file.Extension -ne ".jpeg") {
            Remove-Item $file.FullName -Force
        }
        
        $compressedSize = (Get-Item $newName).Length
        $totalCompressedSize += $compressedSize
        $savings = [math]::Round((($originalSize - $compressedSize) / $originalSize) * 100, 1)
        
        Write-Host "  ✓ $($file.Name) - Saved $savings%" -ForegroundColor Green
        
    } catch {
        Write-Host "  ✗ Failed to compress $($file.Name): $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Progress -Activity "Compressing Images" -Completed

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Compression Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Original Size:   $([math]::Round($totalOriginalSize / 1MB, 2)) MB" -ForegroundColor Yellow
Write-Host "Compressed Size: $([math]::Round($totalCompressedSize / 1MB, 2)) MB" -ForegroundColor Green
Write-Host "Total Savings:   $([math]::Round((($totalOriginalSize - $totalCompressedSize) / $totalOriginalSize) * 100, 1))%" -ForegroundColor Green
Write-Host ""
Write-Host "Backup of original images saved at: $backupPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next step: Rebuild your app" -ForegroundColor Yellow
Write-Host "Run: flutter build appbundle --release" -ForegroundColor White
Write-Host ""

Read-Host "Press Enter to exit"
