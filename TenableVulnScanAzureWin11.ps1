<#
.SYNOPSIS
    Modifies settings of Azure Win11 VM's to allow for Tenable
    Vulnerability Scans of the VM with Firewalls on.
     Specifically modifies the following:
    - Disables UAC Remote Token Filtering
    - Explicitly allows SMB and RPC Ports Locally

.NOTES
    Author        : Sean Santiago
    Date Created  : 2025-12-23
    Last Modified : 2026-01-12
    Version       : 2.0

.TESTED ON
    Date(s) Tested  : 2026-01-12
    Tested By       : Sean Santiago
    Systems Tested  : Microsoft Azure Win11 Pro 25h2 VM
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    - Must be run as Administrator
#>

# Writes a visible banner to indicate the script has started
Write-Host "=== Preparing system for Tenable authenticated scan ===" -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. DISABLE UAC REMOTE TOKEN FILTERING
# ------------------------------------------------------------

# Writes a status message
Write-Host "Disabling UAC remote restrictions..." -ForegroundColor Yellow

# Creates or updates the LocalAccountTokenFilterPolicy registry value
# This allows full admin tokens when connecting remotely (required for Tenable)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" `
    /v LocalAccountTokenFilterPolicy `
    /t REG_DWORD `
    /d 1 `
    /f | Out-Null

# ------------------------------------------------------------
# 2. EXPLICITLY ALLOW SMB AND RPC PORTS LOCALLY
# ------------------------------------------------------------

# Writes a status message
Write-Host "Allowing SMB and RPC ports through Windows Firewall..."

# Defines required TCP ports for Tenable scanning
$ports = @(445, 135)   # 445 = SMB, 135 = RPC Endpoint Mapper

# Loops through each required port
foreach ($port in $ports) {

    # Checks if a firewall rule for this port already exists
    if (-not (Get-NetFirewallRule -DisplayName "Tenable Port $port" -ErrorAction SilentlyContinue)) {

        # Creates a new inbound firewall rule allowing the port
        New-NetFirewallRule `
            -DisplayName "Tenable Port $port" `
            -Direction Inbound `
            -Protocol TCP `
            -LocalPort $port `
            -Action Allow `
            -Profile Any
    }
}
