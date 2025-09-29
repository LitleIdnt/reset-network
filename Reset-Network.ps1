# Reset-Network.ps1
# Script to clear routing table completely, renew IP, and remove any added routes

$LogFile = "$PSScriptRoot\NetworkReset.log"

function Write-Log {
    param([string]$Message)
    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Time - $Message" | Out-File -FilePath $LogFile -Append -Encoding utf8
    Write-Host $Message
}

Write-Log "===== Starting HARD Network Reset ====="

try {
    # 1. Routing-Tabelle holen
    $routes = route print | Select-String "^\s+\d"
    foreach ($line in $routes) {
        $parts = $line.ToString().Trim() -split "\s+"
        $dest = $parts[0]

        # Nur echte Netzwerke löschen, Loopback bleibt
        if ($dest -ne "127.0.0.0") {
            Write-Log "Deleting route $dest ..."
            route delete $dest | Out-File -FilePath $LogFile -Append -Encoding utf8
        }
    }

    # 2. IP Release / Renew
    Write-Log "Releasing IP address (ipconfig /release)..."
    ipconfig /release | Out-File -FilePath $LogFile -Append -Encoding utf8

    Start-Sleep -Seconds 3

    Write-Log "Renewing IP address (ipconfig /renew)..."
    ipconfig /renew | Out-File -FilePath $LogFile -Append -Encoding utf8

    # 3. Sicherstellen, dass auch benutzerdefinierte Routen (Test-Routen) weg sind
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
