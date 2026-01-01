# Quick GitHub Setup Script
# Run this after creating your GitHub repository

Write-Host "`n🚀 Codiny Platform - GitHub Setup`n" -ForegroundColor Cyan

# Get GitHub username
$username = Read-Host "Enter your GitHub username"

# Get repository name
$repo = Read-Host "Enter your repository name (e.g., codiny-platform)"

# Confirm
Write-Host "`n📋 Configuration:" -ForegroundColor Yellow
Write-Host "   GitHub URL: https://github.com/$username/$repo.git"
$confirm = Read-Host "`nIs this correct? (Y/N)"

if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "❌ Cancelled. Please run the script again." -ForegroundColor Red
    exit
}

# Navigate to project directory
$projectPath = "C:\Users\yahya\OneDrive\Desktop\CodinyPlatforme v2"
Set-Location $projectPath

Write-Host "`n🔗 Adding GitHub remote..." -ForegroundColor Green
git remote add origin "https://github.com/$username/$repo.git"

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Remote already exists. Updating..." -ForegroundColor Yellow
    git remote set-url origin "https://github.com/$username/$repo.git"
}

Write-Host "✅ Remote added successfully!" -ForegroundColor Green

Write-Host "`n📤 Pushing to GitHub..." -ForegroundColor Green
git branch -M main
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 Success! Your code is now on GitHub!" -ForegroundColor Green
    Write-Host "   View at: https://github.com/$username/$repo`n" -ForegroundColor Cyan
    
    Write-Host "📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Go to https://railway.app" -ForegroundColor White
    Write-Host "   2. Sign up with GitHub" -ForegroundColor White
    Write-Host "   3. New Project → Deploy from GitHub" -ForegroundColor White
    Write-Host "   4. Follow GITHUB_AND_RAILWAY_SETUP.md (Step 3)`n" -ForegroundColor White
} else {
    Write-Host "`n❌ Push failed. Please check your GitHub credentials." -ForegroundColor Red
    Write-Host "   You may need to authenticate with GitHub." -ForegroundColor Yellow
}

Write-Host "`n✨ Done!`n" -ForegroundColor Cyan
