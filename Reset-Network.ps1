###############################################################################
# PowerShell Script Reset local Network
# Author: Justin Geis - CrossX-IT GmbH
# Created: 2025-04-11
# Updated: 2025-09-22
# Version: 1.3.1
# Description: Hard reset of the local network configuration by:
#              - Clearing the routing table
#              - Releasing and renewing the IP address
#              - Cleaning up leftover static routes
# Prerequisites: Run as Administrator
# Usage: Execute the script in PowerShell with elevated privileges.
###############################################################################


$LogFile = "$PSScriptRoot\NetworkReset.log"
function Write-Log {
    param([string]$Message)
    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Time - $Message" | Out-File -FilePath $LogFile -Append -Encoding utf8
    Write-Host $Message
}
Write-Log "===== Starting HARD Network Reset ====="
try {
    $routes = route print | Select-String "^\s+\d"
    foreach ($line in $routes) {
        $parts = $line.ToString().Trim() -split "\s+"
        $dest = $parts[0]
        if ($dest -ne "127.0.0.0") {
            Write-Log "Deleting route $dest ..."
            route delete $dest | Out-File -FilePath $LogFile -Append -Encoding utf8
        }
    }
    Write-Log "Releasing IP address (ipconfig /release)..."
    ipconfig /release | Out-File -FilePath $LogFile -Append -Encoding utf8
    Start-Sleep -Seconds 3
    Write-Log "Renewing IP address (ipconfig /renew)..."
    ipconfig /renew | Out-File -FilePath $LogFile -Append -Encoding utf8
    Write-Log "Cleaning up leftover static routes..."
    $cleanup = route print | Select-String "^\s+\d"
    foreach ($line in $cleanup) {
        $parts = $line.ToString().Trim() -split "\s+"
        $dest = $parts[0]
        if ($dest -ne "127.0.0.0") {
            Write-Log "Force deleting route $dest ..."
            route delete $dest | Out-File -FilePath $LogFile -Append -Encoding utf8
        }
    }

    Write-Log "===== Network Reset Completed Successfully =====`r`n"
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
}
