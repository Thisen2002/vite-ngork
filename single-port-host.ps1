# Single Port Hosting Script
# This script starts all backend services internally and exposes only ONE port (80) to the internet

param(
    [int]$Port = 80,
    [switch]$Help
)

if ($Help) {
    Write-Host "Single Port Exhibition App Hosting" -ForegroundColor Cyan
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\single-port-host.ps1 [-Port <port>]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Port    Port to expose (default: 80)"
    Write-Host "  -Help    Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\single-port-host.ps1           # Host on port 80"
    Write-Host "  .\single-port-host.ps1 -Port 8080  # Host on port 8080"
    exit 0
}

Write-Host "🚀 Starting Single Port Exhibition App Server..." -ForegroundColor Green
Write-Host "Port: $Port" -ForegroundColor Cyan
Write-Host ""

# Stop any existing PM2 processes
Write-Host "🛑 Stopping existing services..." -ForegroundColor Yellow
pm2 delete all 2>$null

# Start all backend services (internal ports)
Write-Host "🔧 Starting backend services on internal ports..." -ForegroundColor Yellow

# Start backend services with production config (but only the backend services)
$backendServices = @(
    "api-gateway-prod",
    "events-service-prod", 
    "heatmap-service-prod",
    "maps-service-prod",
    "auth-service-prod",
    "org-management-service-prod",
    "event-service-dashboard-prod",
    "building-service-prod",
    "alert-service-prod"
)

foreach ($service in $backendServices) {
    Write-Host "Starting $service..." -ForegroundColor Yellow
    pm2 start ecosystem.production.config.cjs --only $service
}

# Wait for services to start
Write-Host "⏳ Waiting for backend services to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Start the unified proxy server on the specified port
Write-Host "🌐 Starting unified proxy server on port $Port..." -ForegroundColor Green
$env:PORT = $Port
pm2 start unified-server.cjs --name "unified-server" --env PORT=$Port

# Show status
Write-Host ""
Write-Host "📊 Service Status:" -ForegroundColor Green
pm2 list

Write-Host ""
Write-Host "🎉 Single Port Server Ready!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Your app is accessible at:" -ForegroundColor Cyan
Write-Host "   📱 Frontend:     http://localhost:$Port" -ForegroundColor Yellow
Write-Host "   🔌 API Gateway:  http://localhost:$Port/api" -ForegroundColor Yellow
Write-Host "   📅 Events:       http://localhost:$Port/events-api" -ForegroundColor Yellow
Write-Host "   🗺️  Maps:         http://localhost:$Port/maps-api" -ForegroundColor Yellow
Write-Host "   🔥 Heatmap:      http://localhost:$Port/heatmap-api" -ForegroundColor Yellow
Write-Host "   🔐 Auth:         http://localhost:$Port/auth" -ForegroundColor Yellow
Write-Host "   ⚕️  Health:       http://localhost:$Port/health" -ForegroundColor Yellow
Write-Host ""
Write-Host "🔒 To expose to internet, only open port $Port in:" -ForegroundColor Cyan
Write-Host "   - Windows Firewall" -ForegroundColor White
Write-Host "   - Router Port Forwarding" -ForegroundColor White
Write-Host ""
Write-Host "💡 Useful commands:" -ForegroundColor Yellow
Write-Host "   pm2 logs unified-server    # View proxy server logs"
Write-Host "   pm2 monit                  # Monitor all services"
Write-Host "   pm2 stop all               # Stop all services"