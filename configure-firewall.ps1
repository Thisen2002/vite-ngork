# Windows Firewall Configuration Script for Internet Access
# Run this script as Administrator to allow inbound traffic

param(
    [switch]$Enable,
    [switch]$Disable,
    [switch]$Status
)

$ports = @{
    "Exhibition App Frontend" = 3000
    "Exhibition App API Gateway" = 5000
    "Exhibition App Events" = 3036
    "Exhibition App Maps" = 3001
    "Exhibition App Heatmap" = 3897
    "Exhibition App Auth" = 5004
    "Exhibition App Org Management" = 5001
    "Exhibition App Events Dashboard" = 5002
    "Exhibition App Buildings" = 5003
    "Exhibition App Alerts" = 5010
}

function Enable-FirewallRules {
    Write-Host "🔥 Configuring Windows Firewall for Internet Access..." -ForegroundColor Green
    
    foreach ($rule in $ports.GetEnumerator()) {
        $displayName = $rule.Key
        $port = $rule.Value
        
        Write-Host "Opening port $port for $displayName..." -ForegroundColor Yellow
        
        try {
            New-NetFirewallRule -DisplayName $displayName -Direction Inbound -Protocol TCP -LocalPort $port -Action Allow -ErrorAction Stop
            Write-Host "✅ Successfully opened port $port" -ForegroundColor Green
        }
        catch {
            if ($_.Exception.Message -like "*already exists*") {
                Write-Host "⚠️  Rule for port $port already exists" -ForegroundColor Yellow
            } else {
                Write-Host "❌ Failed to open port $port : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host ""
    Write-Host "🎉 Firewall configuration complete!" -ForegroundColor Green
    Write-Host "Your application ports are now open for internet access." -ForegroundColor Cyan
}

function Disable-FirewallRules {
    Write-Host "🚫 Disabling Exhibition App Firewall Rules..." -ForegroundColor Yellow
    
    foreach ($rule in $ports.GetEnumerator()) {
        $displayName = $rule.Key
        
        try {
            Remove-NetFirewallRule -DisplayName $displayName -ErrorAction Stop
            Write-Host "✅ Removed rule: $displayName" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️  Rule not found: $displayName" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "✅ Firewall rules removed!" -ForegroundColor Green
}

function Show-FirewallStatus {
    Write-Host "📊 Exhibition App Firewall Status:" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($rule in $ports.GetEnumerator()) {
        $displayName = $rule.Key
        $port = $rule.Value
        
        try {
            $existingRule = Get-NetFirewallRule -DisplayName $displayName -ErrorAction Stop
            Write-Host "✅ Port $port ($displayName) - OPEN" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Port $port ($displayName) - CLOSED" -ForegroundColor Red
        }
    }
}

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Main execution
if (!(Test-Administrator)) {
    Write-Host "❌ This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

if ($Enable) {
    Enable-FirewallRules
} elseif ($Disable) {
    Disable-FirewallRules
} elseif ($Status) {
    Show-FirewallStatus
} else {
    Write-Host "Exhibition App Firewall Configuration" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\configure-firewall.ps1 -Enable    # Open all ports for internet access"
    Write-Host "  .\configure-firewall.ps1 -Disable   # Close all exhibition app ports"
    Write-Host "  .\configure-firewall.ps1 -Status    # Show current port status"
    Write-Host ""
    Write-Host "⚠️  Must be run as Administrator!" -ForegroundColor Yellow
}