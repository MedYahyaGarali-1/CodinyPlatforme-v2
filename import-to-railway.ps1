# Railway Database Import Script
# Simple 1-command database import

Write-Host "`n🎯 Railway Database Import`n" -ForegroundColor Cyan

# Step 1: Get connection string
Write-Host "📋 Step 1: Paste your Railway connection string" -ForegroundColor Yellow
Write-Host "   (From Railway → Connect button)" -ForegroundColor Gray
$connectionString = Read-Host "`nConnection String"

# Step 2: Get backup file
Write-Host "`n📁 Step 2: Drag and drop your backup SQL file here" -ForegroundColor Yellow
Write-Host "   (Or type the full path)" -ForegroundColor Gray
$backupFile = Read-Host "`nSQL File Path"

# Remove quotes if user dragged file
$backupFile = $backupFile.Trim('"')

# Check if file exists
if (-not (Test-Path $backupFile)) {
    Write-Host "`n❌ File not found: $backupFile" -ForegroundColor Red
    exit
}

Write-Host "`n🚀 Importing database..." -ForegroundColor Green
Write-Host "   This may take 1-3 minutes...`n" -ForegroundColor Gray

# Import using psql (PostgreSQL command line)
$env:PGPASSWORD = ""
psql $connectionString -f $backupFile

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ SUCCESS! Database imported!`n" -ForegroundColor Green
    Write-Host "🎉 Your app should work now!" -ForegroundColor Cyan
} else {
    Write-Host "`n⚠️  Import had some warnings, but probably worked!" -ForegroundColor Yellow
    Write-Host "   Check your Railway logs to verify." -ForegroundColor Gray
}

Write-Host "`n✨ Done!`n" -ForegroundColor Cyan
