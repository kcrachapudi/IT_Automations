# Import IIS module so we can interact with IIS (web server)
# This module gives us commands like Get-Website, Start-Website, etc.
Import-Module WebAdministration

# Define the name of the IIS website we want to monitor
# IMPORTANT: This must match exactly what you see in IIS Manager
$siteName = "Default Web Site"

# Get the current state of the website (Started, Stopped, etc.)
$site = Get-Website -Name $siteName

# Output the current status for visibility/logging
Write-Output "Current state of $siteName is: $($site.State)"

# Check if the site is NOT running
# -ne means "not equal"
if ($site.State -ne "Started") {

    Write-Output "Website is NOT running. Attempting to start..."

    # Start the website
    Start-Website -Name $siteName

    # Re-check the status after attempting restart
    $site = Get-Website -Name $siteName

    Write-Output "New state of $siteName is: $($site.State)"
}
else {
    # If already running, do nothing but log
    Write-Output "Website is already running. No action needed."
}
