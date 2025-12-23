<#
.SYNOPSIS
    Modifies settings of Azure Win11 VM's to allow for Tenable
    Vulnerability Scans. Specifically modifies the following:
    - Enables Administrative Shares
    - Disables UAC Remote Token Filtering
    - Enables and Starts Required Windows Services
    - Enables Required Windows Firewall Rule Groups
    - Explicitly allows SMB and RPC Ports Locally
    - Configures NTLM & LAN Manager Authentication
    - Verifies SMB (TCP 445) is Listening

.NOTES
    Author        : Sean Santiago
    Date Created  : 2025-12-23
    Last Modified : 2025-12-23
    Version       : 1.0

.TESTED ON
    Date(s) Tested  : 2025-12-23
    Tested By       : Sean Santiago
    Systems Tested  : Microsoft Azure Win11 Pro 24h2 VM
    PowerShell Ver. : 5.1.17763.6189

.USAGE
    - Must be run as Administrator
    - Reboot is REQUIRED after execution
#>

# Writes a visible banner to indicate the script has started
Write-Host "=== Preparing system for Tenable authenticated scan ===" -ForegroundColor Cyan

# ------------------------------------------------------------
# 1. ENABLE ADMINISTRATIVE SHARES (ADMIN$)
# ------------------------------------------------------------

# Writes a status message to the console
Write-Host "Enabling administrative shares..." -ForegroundColor Yellow

# Adds or updates the AutoShareWks registry value
# This ensures default admin shares (like ADMIN$ and C$) are automatically created
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" `
    /v AutoShareWks `
    /t REG_DWORD `
    /d 1 `
    /f | Out-Null

# Restarts the Server service so the admin shares are re-created immediately
Restart-Service LanmanServer -Force

# ------------------------------------------------------------
# 2. DISABLE UAC REMOTE TOKEN FILTERING
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
# 3. ENABLE AND START REQUIRED WINDOWS SERVICES
# ------------------------------------------------------------

# Defines a list of services required for authenticated vulnerability scanning
$services = @(
    "Winmgmt",          # Windows Management Instrumentation (used heavily by Tenable)
    "RemoteRegistry",  # Allows Tenable to query registry keys remotely
    "LanmanServer"     # Required for SMB and admin shares
)

# Loops through each service in the list
foreach ($svc in $services) {

    # Writes the name of the service being configured
    Write-Host "Configuring service: $svc"

    # Sets the service to start automatically at boot
    Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue

    # Starts the service if it is not already running
    Start-Service -Name $svc -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------
# 4. ENABLE REQUIRED WINDOWS FIREWALL RULE GROUPS
# ------------------------------------------------------------

# Defines firewall rule groups required for Tenable scans
$fwGroups = @(
    "File and Printer Sharing",          # Enables SMB (TCP 445)
    "Remote Service Management",         # Allows RPC-based management
    "Windows Management Instrumentation (WMI)" # Allows WMI queries
)

# Loops through each firewall rule group
foreach ($group in $fwGroups) {

    # Writes which firewall group is being enabled
    Write-Host "Enabling firewall rule group: $group"

    # Enables all firewall rules in that display group
    Enable-NetFirewallRule -DisplayGroup $group -ErrorAction SilentlyContinue
}

# ------------------------------------------------------------
# 5. EXPLICITLY ALLOW SMB AND RPC PORTS LOCALLY
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

# ------------------------------------------------------------
# 6. CONFIGURE NTLM & LAN MANAGER AUTHENTICATION
# ------------------------------------------------------------

# Writes a status message
Write-Host "Configuring NTLM and LAN Manager settings..."

# Sets LAN Manager authentication level to NTLMv2 only
# This is required for secure authentication with Tenable
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" `
    /v LmCompatibilityLevel `
    /t REG_DWORD `
    /d 5 `
    /f | Out-Null

# Allows the system to receive NTLM authentication requests
# If this is restricted, Tenable authentication fails
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" `
    /v RestrictReceivingNTLMTraffic `
    /t REG_DWORD `
    /d 0 `
    /f | Out-Null

# ------------------------------------------------------------
# 7. VERIFY SMB (TCP 445) IS LISTENING
# ------------------------------------------------------------

# Writes a status message
Write-Host "Verifying SMB (TCP 445) listening state..."

# Queries active TCP listeners on port 445
$port445 = Get-NetTCPConnection -LocalPort 445 -ErrorAction SilentlyContinue

# Checks whether the port is actively listening
if ($port445) {

    # Success message if SMB is listening
    Write-Host "✔ SMB is listening on TCP 445" -ForegroundColor Green

} else {

    # Warning message if SMB is not listening
    Write-Host "✖ SMB is NOT listening on TCP 445" -ForegroundColor Red
}

# ------------------------------------------------------------
# 8. COMPLETION MESSAGE
# ------------------------------------------------------------

# Writes a completion banner
Write-Host "`n=== Configuration complete ===" -ForegroundColor Cyan

# Warns the user that a reboot is required for all changes to apply
Write-Host "A reboot is REQUIRED before running Tenable scan." -ForegroundColor Yellow
