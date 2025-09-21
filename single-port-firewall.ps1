# Single Port Firewall Configuration
# Run as Administrator to open just ONE port for internet access

param(
    [int]$Port = 8080,
    [switch]$Enable,
    [switch]$Disable,
    [switch]$Status,
    [switch]$Help
)

if ($Help -or (!$Enable -and !$Disable -and !$Status)) {
    Write-Host "Single Port Firewall Configuration" -ForegroundColor Cyan
    Write-Host "===================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\single-port-firewall.ps1 [-Port <port>] -<Action>"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -Port      Port number to configure (default: 8080)"
    Write-Host "  -Enable    Open the port for internet access"
    Write-Host "  -Disable   Close the port"
    Write-Host "  -Status    Check if the port is open"
    Write-Host "  -Help      Show this help"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\single-port-firewall.ps1 -Port 8080 -Enable   # Open port 8080"
    Write-Host "  .\single-port-firewall.ps1 -Port 80 -Enable     # Open port 80"
    Write-Host "  .\single-port-firewall.ps1 -Port 8080 -Disable  # Close port 8080"
    Write-Host "  .\single-port-firewall.ps1 -Port 8080 -Status   # Check port status"
    Write-Host ""
    Write-Host "⚠️  Must be run as Administrator!" -ForegroundColor Yellow
    exit 0
}

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (!(Test-Administrator)) {
    Write-Host "❌ This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

$ruleName = "Exhibition App - Port $Port"

if ($Enable) {
    Write-Host "🔓 Opening port $Port for internet access..." -ForegroundColor Green
    
    try {
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow -ErrorAction Stop
        Write-Host "✅ Successfully opened port $Port" -ForegroundColor Green
        Write-Host ""
        Write-Host "🌐 Your app is now accessible over the internet at:" -ForegroundColor Cyan
        Write-Host "   http://YOUR_PUBLIC_IP:$Port" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "💡 Next steps:" -ForegroundColor Yellow
        Write-Host "   1. Find your public IP: Visit whatismyip.com" -ForegroundColor White
        Write-Host "   2. Configure router port forwarding (port $Port)" -ForegroundColor White
        Write-Host "   3. Share your URL: http://YOUR_PUBLIC_IP:$Port" -ForegroundColor White
    }
    catch {
        if ($_.Exception.Message -like "*already exists*") {
            Write-Host "⚠️  Port $Port is already open" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Failed to open port $Port : $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}
elseif ($Disable) {
    Write-Host "🔒 Closing port $Port..." -ForegroundColor Yellow
    
    try {
        Remove-NetFirewallRule -DisplayName $ruleName -ErrorAction Stop
        Write-Host "✅ Successfully closed port $Port" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️  Rule for port $Port not found" -ForegroundColor Yellow
    }
}
elseif ($Status) {
    Write-Host "📊 Checking port $Port status..." -ForegroundColor Cyan
    
    try {
        $existingRule = Get-NetFirewallRule -DisplayName $ruleName -ErrorAction Stop
        Write-Host "✅ Port $Port is OPEN for internet access" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Port $Port is CLOSED" -ForegroundColor Red
    }
}