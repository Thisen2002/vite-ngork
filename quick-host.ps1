# Quick Production Host Script
# This script quickly builds and hosts the entire application in production mode

Write-Host "🚀 Starting Production Build and Host Process..." -ForegroundColor Green
Write-Host ""

# Check if Node.js is installed
try {
    node --version | Out-Null
    Write-Host "✅ Node.js is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js first." -ForegroundColor Red
    exit 1
}

# Check if npm is available
try {
    npm --version | Out-Null
    Write-Host "✅ npm is available" -ForegroundColor Green
} catch {
    Write-Host "❌ npm is not available. Please ensure npm is installed." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📦 Installing main project dependencies..." -ForegroundColor Yellow
npm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install main dependencies" -ForegroundColor Red
    exit 1
}

# Run the comprehensive build and host script
Write-Host ""
Write-Host "🔧 Running comprehensive build and host script..." -ForegroundColor Yellow
.\build-and-host.ps1 -Action both -Environment production

Write-Host ""
Write-Host "🎉 Production hosting setup complete!" -ForegroundColor Green
Write-Host "🌐 Your application is now running at: http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Useful commands:" -ForegroundColor Yellow
Write-Host "   pm2 list              - View all running services"
Write-Host "   pm2 logs              - View logs from all services"
Write-Host "   pm2 monit             - Monitor services in real-time"
Write-Host "   pm2 stop all          - Stop all services"
Write-Host "   pm2 restart all       - Restart all services"
Write-Host ""