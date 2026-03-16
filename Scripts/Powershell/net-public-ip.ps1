# Script to get the public IP address of the host machine
# Author: Claude Code
# Date: 2026-03-15

<#
.SYNOPSIS
Get the public IP address of the host machine using multiple methods.

.DESCRIPTION
This script attempts to find the public IP address by:
1. Checking the local LAN IP from routing table
2. Trying to resolve public IP from DNS servers
3. Fallback to common IP leak sites if needed

.EXAMPLE
.\net-public-ip.ps1
# Run the script to display public IP
#>

# Exit on error
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Public IP Address Detection Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Method 1: Get local IP from routing table
Write-Host "Method 1: Checking routing table for default gateway..." -ForegroundColor Yellow

try {
    # Get IP routing table
    $routes = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction Stop
    if ($routes.Count -gt 0) {
        $nextHop = $routes[0].NextHop
        if ($nextHop) {
            # Get the interface IP for the default route's next hop
            $gatewayInterface = $netAdapter | Where-Object { $_.NetIPConfiguration.InterfaceAlias -eq $env:COMPUTERNAME -or $nextHop -in ($netAdapter.NetIPConfiguration.IPv4Address + $netAdapter.NetIPConfiguration.IPv6Address) }

            # Alternative: Get all network adapters and their IPs
            $adapter = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq 'Up' }
            $localIp = $null

            foreach ($a in $adapter) {
                $ips = $a.NetConnectionIPInformation.IPAddress
                foreach ($ip in $ips) {
                    if ([System.Net.IPAddress]::IsLoopback($ip.IPAddress) -eq $false) {
                        $localIp = $ip.IPAddress
                        break
                    }
                }
                if ($localIp) { break }
            }

            if ($localIp) {
                Write-Host "  Found local IP: $($localIp.ToString())" -ForegroundColor Green
            }
        }
    }
} catch {
    Write-Host "  Could not determine local IP (not connected to network?)" -ForegroundColor Red
}

Write-Host ""

# Method 2: Try to get public IP via DNS
Write-Host "Method 2: Attempting DNS-based lookup..." -ForegroundColor Yellow

$publicIp = $null

# Common public IP leak services (used by major cloud providers)
$ipServices = @(
    "https://ipinfo.io/ip",
    "https://api.ipify.org?format=json",
    "https://icanhazip.com",
    "https://ifconfig.me/ip",
    "https://checkip.amazonaws.com",
    "https://ip.4open.network"
)

foreach ($service in $ipServices) {
    try {
        Write-Host "  Trying: $service" -ForegroundColor Gray

        $response = Invoke-WebRequest -Uri $service -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
        $content = $response.Content.Trim()

        # Try to parse as JSON
        $json = $null
        try {
            $json = ConvertFrom-Json $content
            $ip = if ($json -is [hashtable]) { $json.ip -or $json.ipaddr -or $json.origin } else { $content }
            if ($ip) {
                Write-Host "  SUCCESS! Public IP: $($ip.ToString())" -ForegroundColor Green
                $publicIp = $ip
                break
            }
        } catch {
            # Not JSON, try string directly
            $ip = $content
            if ([System.Net.IPAddress]::TryParse($ip, [ref]$null)) {
                Write-Host "  SUCCESS! Public IP: $($ip.ToString())" -ForegroundColor Green
                $publicIp = $ip
                break
            }
        }
    } catch {
        Write-Host "  Failed to connect: $_" -ForegroundColor Red
    }
}

if ($publicIp) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Your Public IP Address is:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  IP Address: $($publicIp.ToString())" -ForegroundColor White
    Write-Host "  Type: IPv4" -ForegroundColor White
    Write-Host ""

    # Get geolocation if available
    try {
        $geoResponse = Invoke-WebRequest -Uri "https://ipinfo.io/json" -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        $geo = ConvertFrom-Json $geoResponse.Content
        if ($geo.city) {
            Write-Host "  Location: $($geo.city), $($geo.region), $($geo.country)" -ForegroundColor Gray
        }
    } catch {
        # Ignore geo lookup errors
    }
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Method 3: Alternative - use netsh to get connection info
Write-Host "Method 3: Checking active connections..." -ForegroundColor Yellow

try {
    $connections = Get-NetTCPConnection -ErrorAction SilentlyContinue |
        Where-Object {
            $_.State -eq "Established" -and
            $_.RemoteAddress -ne "0.0.0.0" -and
            $_.LocalAddress -ne "0.0.0.0"
        } |
        Select-Object -ExpandProperty LocalAddress -Unique |
        Sort-Object -Descending |
        Select-Object -First 1

    if ($connections) {
        Write-Host "  Sample active connection IP: $($connections.ToString())" -ForegroundColor Gray
        Write-Host "  Note: This shows local IPs, not public IP." -ForegroundColor Gray
    }
} catch {
    # Ignore errors
}

Write-Host ""

# Method 4: Using netsh to show interface IP
Write-Host "Method 4: Windows network interfaces..." -ForegroundColor Yellow

try {
    $adapter = Get-NetAdapter -Status -ErrorAction SilentlyContinue |
        Where-Object { $_.Status -eq 'Up' } |
        Select-Object -First 3

    foreach ($a in $adapter) {
        $ipAddrs = $a.NetConnectionIPInformation.IPv4Address + $a.NetConnectionIPInformation.IPv6Address
        foreach ($ipObj in $ipAddrs) {
            if ($ipObj.IPAddress -ne "0.0.0.0" -and $ipObj.IPAddress -ne "fe80::1" -and $ipObj.IPAddress -ne "::1") {
                Write-Host "  Interface: $($a.InterfaceAlias)" -ForegroundColor Gray
                Write-Host "    IP: $($ipObj.IPAddress.ToString())" -ForegroundColor Gray
                Write-Host ""
            }
        }
    }
} catch {
    # Ignore errors
}

Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($publicIp) {
    Write-Host "  DETECTED PUBLIC IP:" -ForegroundColor Green
    Write-Host "    $($publicIp.ToString())" -ForegroundColor Green
} else {
    Write-Host "  Unable to determine public IP address." -ForegroundColor Red
    Write-Host ""
    Write-Host "  Possible reasons:" -ForegroundColor Yellow
    Write-Host "    - No internet connection" -ForegroundColor Yellow
    Write-Host "    - Behind NAT without public IP route" -ForegroundColor Yellow
    Write-Host "    - All IP leak services unavailable" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan

# Provide suggestions
Write-Host ""
Write-Host "Suggestions:" -ForegroundColor Cyan
Write-Host "1. If you see multiple local IPs, contact your ISP to get your public IP." -ForegroundColor Gray
Write-Host "2. Cloud providers (AWS, Azure, GCP) have a metadata service:" -ForegroundColor Gray
Write-Host "   AWS: http://169.254.169.254/latest/meta-data/public-ipv4" -ForegroundColor Gray
Write-Host "   Azure: http://169.254.169.254/metadata/instance/publicIPAddress?format=text" -ForegroundColor Gray
Write-Host "   GCP: http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip" -ForegroundColor Gray
Write-Host ""
