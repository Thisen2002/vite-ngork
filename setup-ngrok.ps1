# Ngrok Setup Script for Exhibition App
# This script helps you set up Ngrok tunneling for your unified server

param(
    [int]$Port = 8080,
    [switch]$Help
)

if ($Help) {
    Write-Host "Ngrok Setup for Exhibition App" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "This script helps you set up Ngrok tunneling for internet access."
    Write-Host ""
    Write-Host "Usage: .\setup-ngrok.ps1 [-Port <port>]"
    Write-Host ""
    Write-Host "Prerequisites:" -ForegroundColor Yellow
    Write-Host "1. Download ngrok from https://ngrok.com/download"
    Write-Host "2. Sign up for a free account"
    Write-Host "3. Place ngrok.exe in your project folder"
    Write-Host ""
    Write-Host "Steps:" -ForegroundColor Yellow
    Write-Host "1. Run: .\setup-ngrok.ps1"
    Write-Host "2. Follow the instructions"
    Write-Host "3. Share the ngrok URL with anyone!"
    exit 0
}

Write-Host "🚀 Ngrok Setup for Exhibition App" -ForegroundColor Green
Write-Host "Port: $Port" -ForegroundColor Cyan
Write-Host ""

# Check if unified server is running
Write-Host "🔍 Checking if unified server is running..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:$Port/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Unified server is running on port $Port" -ForegroundColor Green
    }
}
catch {
    Write-Host "❌ Unified server is not running on port $Port" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start your server first:" -ForegroundColor Yellow
    Write-Host "  .\single-port-host.ps1 -Port $Port" -ForegroundColor White
    Write-Host ""
    exit 1
}

# Check if ngrok exists
if (!(Test-Path ".\ngrok.exe")) {
    Write-Host "❌ ngrok.exe not found in current directory" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Download ngrok from: https://ngrok.com/download" -ForegroundColor White
    Write-Host "2. Extract ngrok.exe to this folder" -ForegroundColor White
    Write-Host "3. Run this script again" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✅ ngrok.exe found" -ForegroundColor Green
Write-Host ""

# Test API endpoints
Write-Host "🧪 Testing API endpoints..." -ForegroundColor Yellow

$endpoints = @(
    @{ Name = "Frontend"; URL = "http://localhost:$Port"; Expected = "Exhibition App" },
    @{ Name = "Health Check"; URL = "http://localhost:$Port/health"; Expected = "OK" },
    @{ Name = "API Gateway"; URL = "http://localhost:$Port/api/"; Expected = "running" },
    @{ Name = "Events API"; URL = "http://localhost:$Port/events-api/"; Expected = "" },
    @{ Name = "Heatmap API"; URL = "http://localhost:$Port/heatmap-api/"; Expected = "" },
    @{ Name = "Maps API"; URL = "http://localhost:$Port/maps-api/"; Expected = "" }
)

$workingEndpoints = 0
foreach ($endpoint in $endpoints) {
    try {
        $response = Invoke-WebRequest -Uri $endpoint.URL -UseBasicParsing -TimeoutSec 3
        if ($response.StatusCode -eq 200) {
            Write-Host "  ✅ $($endpoint.Name): Working" -ForegroundColor Green
            $workingEndpoints++
        } else {
            Write-Host "  ⚠️  $($endpoint.Name): Status $($response.StatusCode)" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "  ❌ $($endpoint.Name): Failed" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📊 $workingEndpoints/$($endpoints.Count) endpoints working" -ForegroundColor Cyan
Write-Host ""

# Instructions for Ngrok
Write-Host "🌐 To start Ngrok:" -ForegroundColor Green
Write-Host ""
Write-Host "1. Open a NEW PowerShell window" -ForegroundColor Yellow
Write-Host "2. Navigate to this folder" -ForegroundColor Yellow
Write-Host "3. Run this command:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   .\ngrok.exe http $Port" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Ngrok will show you URLs like:" -ForegroundColor Yellow
Write-Host "   https://abc123.ngrok-free.app" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Share that URL with anyone!" -ForegroundColor Yellow
Write-Host ""

Write-Host "💡 Pro Tips:" -ForegroundColor Yellow
Write-Host "• The HTTPS URL works better than HTTP" -ForegroundColor White
Write-Host "• Your app will work on mobile devices" -ForegroundColor White
Write-Host "• All API calls now go through the same tunnel" -ForegroundColor White
Write-Host "• Keep both this server AND ngrok running" -ForegroundColor White
Write-Host ""

Write-Host "🎉 Ready for Ngrok! Your app is properly configured." -ForegroundColor Green