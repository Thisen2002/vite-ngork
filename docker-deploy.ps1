# Docker deployment scripts and utilities

# Quick Docker Deploy Script for Windows
# Usage: .\docker-deploy.ps1 [-Action <build|up|down|logs|status>]

param(
    [string]$Action = "up"  # Options: "build", "up", "down", "logs", "status"
)

function Show-Usage {
    Write-Host ""
    Write-Host "Usage: .\docker-deploy.ps1 [-Action <action>]"
    Write-Host ""
    Write-Host "Actions:"
    Write-Host "  build   - Build Docker images"
    Write-Host "  up      - Start all services (default)"
    Write-Host "  down    - Stop all services"
    Write-Host "  logs    - View logs from all services"
    Write-Host "  status  - Check service status"
    Write-Host ""
}

function Test-DockerInstalled {
    try {
        docker --version | Out-Null
        docker-compose --version | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Build-DockerImages {
    Write-Host "🐳 Building Docker images..." -ForegroundColor Green
    docker-compose build --no-cache
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker images built successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to build Docker images" -ForegroundColor Red
        exit 1
    }
}

function Start-Services {
    Write-Host "🚀 Starting all services with Docker Compose..." -ForegroundColor Green
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ All services started successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "🌐 Your application is now running at:" -ForegroundColor Cyan
        Write-Host "   Frontend: http://localhost" -ForegroundColor Yellow
        Write-Host "   API Gateway: http://localhost:5000" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📊 Monitor services: docker-compose logs -f" -ForegroundColor Cyan
        Write-Host "⏹️  Stop services: docker-compose down" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Failed to start services" -ForegroundColor Red
        exit 1
    }
}

function Stop-Services {
    Write-Host "⏹️ Stopping all services..." -ForegroundColor Yellow
    docker-compose down
    Write-Host "✅ All services stopped!" -ForegroundColor Green
}

function Show-Logs {
    Write-Host "📋 Showing logs from all services..." -ForegroundColor Cyan
    docker-compose logs --tail=100 -f
}

function Show-Status {
    Write-Host "📊 Service Status:" -ForegroundColor Cyan
    docker-compose ps
}

# Main execution
if (!(Test-DockerInstalled)) {
    Write-Host "❌ Docker or Docker Compose is not installed!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

switch ($Action.ToLower()) {
    "build" {
        Build-DockerImages
    }
    "up" {
        Build-DockerImages
        Start-Services
    }
    "down" {
        Stop-Services
    }
    "logs" {
        Show-Logs
    }
    "status" {
        Show-Status
    }
    default {
        Write-Host "❌ Invalid action: $Action" -ForegroundColor Red
        Show-Usage
        exit 1
    }
}