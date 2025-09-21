# Production Build and Host Script
# Usage: .\build-and-host.ps1 [-Action <action>] [-Environment <env>]
# Actions: build, host, both (default)
# Environment: development, production (default)

param(
    [string]$Action = "both",          # Options: "build", "host", "both"
    [string]$Environment = "production" # Options: "development", "production"
)

# Display usage information
function Show-Usage {
    Write-Host ""
    Write-Host "Usage: .\build-and-host.ps1 [-Action <action>] [-Environment <env>]"
    Write-Host ""
    Write-Host "Actions:"
    Write-Host "  build    - Build all services for production"
    Write-Host "  host     - Start hosting all services"
    Write-Host "  both     - Build and host all services (default)"
    Write-Host ""
    Write-Host "Environment:"
    Write-Host "  development - Run in development mode"
    Write-Host "  production  - Run in production mode (default)"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\build-and-host.ps1                              # Build and host in production"
    Write-Host "  .\build-and-host.ps1 -Action build                # Only build for production"
    Write-Host "  .\build-and-host.ps1 -Action host                 # Only start hosting"
    Write-Host "  .\build-and-host.ps1 -Environment development     # Run in development mode"
    Write-Host ""
}

# Validate parameters
if ($Action -notin @("build", "host", "both")) {
    Write-Host "Error: Invalid action '$Action'" -ForegroundColor Red
    Show-Usage
    exit 1
}

if ($Environment -notin @("development", "production")) {
    Write-Host "Error: Invalid environment '$Environment'" -ForegroundColor Red
    Show-Usage
    exit 1
}

# Function to check if PM2 is installed
function Test-PM2Installed {
    try {
        pm2 --version | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to install PM2 globally
function Install-PM2 {
    Write-Host "PM2 not found. Installing PM2 globally..." -ForegroundColor Yellow
    npm install -g pm2
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to install PM2" -ForegroundColor Red
        exit 1
    }
    Write-Host "PM2 installed successfully" -ForegroundColor Green
}

# Function to build all services
function Build-AllServices {
    Write-Host "=== Building All Services for $Environment ===" -ForegroundColor Green
    
    # Create logs directory if it doesn't exist
    if (!(Test-Path "./logs")) {
        New-Item -ItemType Directory -Path "./logs" -Force
        Write-Host "Created logs directory" -ForegroundColor Yellow
    }

    # Build frontend
    Write-Host "Building Frontend..." -ForegroundColor Yellow
    if ($Environment -eq "production") {
        # Copy production config if it exists
        if (Test-Path "./vite.config.production.ts") {
            Copy-Item "./vite.config.production.ts" "./vite.config.temp.ts" -Force
            Copy-Item "./vite.config.temp.ts" "./vite.config.ts" -Force
            Remove-Item "./vite.config.temp.ts"
        }
        
        # Load production environment
        if (Test-Path "./.env.production") {
            Copy-Item "./.env.production" "./.env.local" -Force
        }
        
        npm run build
    } else {
        Write-Host "Development mode - skipping frontend build" -ForegroundColor Yellow
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Frontend build failed" -ForegroundColor Red
        exit 1
    }

    # Install dependencies for all backend services
    Write-Host "Installing backend dependencies..." -ForegroundColor Yellow
    
    $backendFolders = @(
        ".\backend\events",
        ".\backend\Maps\backend map",
        ".\backend\heatmap\backend\exhibition-map-backend",
        ".\backend\Organizer_Dashboard-main\backend\api-gateway",
        ".\backend\Organizer_Dashboard-main\backend\services\alert-service",
        ".\backend\Organizer_Dashboard-main\backend\services\auth-service",
        ".\backend\Organizer_Dashboard-main\backend\services\building-service",
        ".\backend\Organizer_Dashboard-main\backend\services\event-service",
        ".\backend\Organizer_Dashboard-main\backend\services\orgMng-service"
    )

    foreach ($folder in $backendFolders) {
        if (Test-Path $folder) {
            Write-Host "Installing dependencies in $folder" -ForegroundColor Yellow
            Push-Location $folder
            npm install
            if ($LASTEXITCODE -ne 0) {
                Write-Host "Failed to install dependencies in $folder" -ForegroundColor Red
                Pop-Location
                exit 1
            }
            Pop-Location
        } else {
            Write-Host "Warning: Folder $folder not found" -ForegroundColor Yellow
        }
    }

    Write-Host "=== Build Complete ===" -ForegroundColor Green
}

# Function to host all services
function Start-Hosting {
    Write-Host "=== Starting All Services in $Environment Mode ===" -ForegroundColor Green
    
    # Check and install PM2 if needed
    if (!(Test-PM2Installed)) {
        Install-PM2
    }

    # Stop existing PM2 processes
    Write-Host "Stopping existing PM2 processes..." -ForegroundColor Yellow
    pm2 delete all 2>$null

    # Select the appropriate ecosystem config
    $ecosystemConfig = if ($Environment -eq "production") {
        "./ecosystem.production.config.cjs"
    } else {
        "./ecosystem.config.cjs"
    }

    # Start all services using PM2
    Write-Host "Starting all services with PM2..." -ForegroundColor Yellow
    pm2 start $ecosystemConfig

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to start services with PM2" -ForegroundColor Red
        exit 1
    }

    # Show PM2 status
    Write-Host "PM2 Process Status:" -ForegroundColor Green
    pm2 list

    # Show service URLs
    Write-Host ""
    Write-Host "=== Services are now running ===" -ForegroundColor Green
    Write-Host ""
    if ($Environment -eq "production") {
        Write-Host "🌐 Frontend:              http://localhost:3000" -ForegroundColor Cyan
        Write-Host "🚪 API Gateway:           http://localhost:5000" -ForegroundColor Cyan
        Write-Host "📅 Events Service:        http://localhost:3036" -ForegroundColor Cyan
        Write-Host "🗺️  Maps Service:          http://localhost:3001" -ForegroundColor Cyan
        Write-Host "🔥 Heatmap Service:       http://localhost:3897" -ForegroundColor Cyan
        Write-Host "🔐 Auth Service:          http://localhost:5004" -ForegroundColor Cyan
        Write-Host "🏢 Org Management:        http://localhost:5001" -ForegroundColor Cyan
        Write-Host "📊 Event Dashboard:       http://localhost:5002" -ForegroundColor Cyan
        Write-Host "🏗️  Building Service:      http://localhost:5003" -ForegroundColor Cyan
        Write-Host "🚨 Alert Service:         http://localhost:5010" -ForegroundColor Cyan
    } else {
        Write-Host "🌐 Frontend:              http://localhost:5173" -ForegroundColor Cyan
        Write-Host "🚪 API Gateway:           http://localhost:5000" -ForegroundColor Cyan
        Write-Host "📅 Events Service:        http://localhost:3036" -ForegroundColor Cyan
        Write-Host "🗺️  Maps Service:          http://localhost:3001" -ForegroundColor Cyan
        Write-Host "🔥 Heatmap Service:       http://localhost:3897" -ForegroundColor Cyan
        Write-Host "🔐 Auth Service:          http://localhost:5004" -ForegroundColor Cyan
        Write-Host "🏢 Org Management:        http://localhost:5001" -ForegroundColor Cyan
        Write-Host "📊 Event Dashboard:       http://localhost:5002" -ForegroundColor Cyan
        Write-Host "🏗️  Building Service:      http://localhost:5003" -ForegroundColor Cyan
        Write-Host "🚨 Alert Service:         http://localhost:5010" -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "📊 Monitor services:      pm2 monit" -ForegroundColor Yellow
    Write-Host "📝 View logs:            pm2 logs" -ForegroundColor Yellow
    Write-Host "🔄 Restart all:          pm2 restart all" -ForegroundColor Yellow
    Write-Host "⏹️  Stop all:             pm2 stop all" -ForegroundColor Yellow
    Write-Host "❌ Delete all:           pm2 delete all" -ForegroundColor Yellow
}

# Execute based on parameters
Write-Host "Environment: $Environment" -ForegroundColor Cyan
Write-Host "Action: $Action" -ForegroundColor Cyan
Write-Host ""

switch ($Action) {
    "build" {
        Build-AllServices
    }
    "host" {
        Start-Hosting
    }
    "both" {
        Build-AllServices
        Write-Host ""
        Start-Hosting
    }
}

Write-Host ""
Write-Host "Script execution completed!" -ForegroundColor Green
Write-Host "Visit http://localhost:$(if ($Environment -eq 'production') { '3000' } else { '5173' }) to access your application" -ForegroundColor Green