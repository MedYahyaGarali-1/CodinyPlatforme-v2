# Codiny Platform - Diagnostic Runner
# Run this script to check your system health

Write-Host ""
Write-Host "🔍 =============================================="  -ForegroundColor Cyan
Write-Host "   CODINY PLATFORM - SYSTEM DIAGNOSTICS"  -ForegroundColor Cyan
Write-Host "=============================================="  -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Choose how to run diagnostics:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Local (requires .env with DATABASE_URL)" -ForegroundColor White
Write-Host "2. Railway (using Railway CLI)" -ForegroundColor White
Write-Host "3. Show diagnostic file location" -ForegroundColor White
Write-Host "4. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "🚀 Running diagnostics locally..." -ForegroundColor Green
        Write-Host ""
        
        cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\backend"
        
        if (Test-Path ".env") {
            Write-Host "✅ .env file found" -ForegroundColor Green
        } else {
            Write-Host "⚠️  .env file not found - make sure DATABASE_URL is set" -ForegroundColor Yellow
        }
        
        Write-Host ""
        node diagnostic-check.js
    }
    
    "2" {
        Write-Host ""
        Write-Host "🚀 Running diagnostics on Railway..." -ForegroundColor Green
        Write-Host ""
        
        # Check if Railway CLI is installed
        $railwayInstalled = Get-Command railway -ErrorAction SilentlyContinue
        
        if ($railwayInstalled) {
            Write-Host "✅ Railway CLI found" -ForegroundColor Green
            Write-Host ""
            
            cd "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\backend"
            railway run node diagnostic-check.js
        } else {
            Write-Host "❌ Railway CLI not installed" -ForegroundColor Red
            Write-Host ""
            Write-Host "To install Railway CLI:" -ForegroundColor Yellow
            Write-Host "1. Visit: https://docs.railway.app/develop/cli" -ForegroundColor White
            Write-Host "2. Or run: npm install -g @railway/cli" -ForegroundColor White
            Write-Host ""
            Write-Host "Alternative: Use Railway Dashboard Shell" -ForegroundColor Yellow
            Write-Host "1. Go to https://railway.app" -ForegroundColor White
            Write-Host "2. Open your backend service" -ForegroundColor White
            Write-Host "3. Click 'Shell' tab" -ForegroundColor White
            Write-Host "4. Run: node diagnostic-check.js" -ForegroundColor White
        }
    }
    
    "3" {
        Write-Host ""
        Write-Host "📍 Diagnostic File Location:" -ForegroundColor Cyan
        Write-Host ""
        $diagPath = "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\backend\diagnostic-check.js"
        Write-Host $diagPath -ForegroundColor White
        Write-Host ""
        Write-Host "📋 Guide Location:" -ForegroundColor Cyan
        Write-Host ""
        $guidePath = "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\DIAGNOSTIC_GUIDE.md"
        Write-Host $guidePath -ForegroundColor White
        Write-Host ""
        
        # Open file explorer to the location
        $response = Read-Host "Open folder in Explorer? (Y/N)"
        if ($response -eq "Y" -or $response -eq "y") {
            explorer "c:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2\backend"
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "👋 Goodbye!" -ForegroundColor Cyan
        Write-Host ""
        exit
    }
    
    default {
        Write-Host ""
        Write-Host "❌ Invalid choice. Please run again and choose 1-4." -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host ""
Write-Host "=============================================="  -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
