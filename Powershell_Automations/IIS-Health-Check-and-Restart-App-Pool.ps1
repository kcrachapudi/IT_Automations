# Import IIS module again (required for app pool commands)
Import-Module WebAdministration

# Define the App Pool name (very important in real environments)
$appPoolName = "DefaultAppPool"

# Get current state of the App Pool (Started, Stopped)
$appPool = Get-WebAppPoolState -Name $appPoolName

Write-Output "App Pool Status: $($appPool.Value)"

# If app pool is not running, restart it
if ($appPool.Value -ne "Started") {

    Write-Output "App Pool is down. Restarting..."

    # Restart the app pool
    Restart-WebAppPool -Name $appPoolName

    Write-Output "App Pool restarted successfully."
}
else {
    Write-Output "App Pool is healthy."
}
