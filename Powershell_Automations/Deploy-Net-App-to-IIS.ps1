###############################################################
# .NET APPLICATION DEPLOYMENT SCRIPT TO IIS
# -------------------------------------------------------------
# What this script does:
# 1. Stops IIS Website (to avoid file locks)
# 2. Optionally stops App Pool
# 3. Copies new build files to IIS directory
# 4. Starts App Pool + Website again
# 5. Logs every step
###############################################################

# Import IIS module (required for IIS commands like Stop-Website)
Import-Module WebAdministration

###############################################################
# 🔧 CONFIGURATION SECTION (EDIT THESE FOR YOUR ENVIRONMENT)
###############################################################

# Name of your IIS website (check IIS Manager)
$siteName = "Default Web Site"

# Name of the Application Pool
$appPoolName = "DefaultAppPool"

# Path where your new published .NET app exists
# Example: dotnet publish output folder
$sourcePath = "C:\Deploy\MyApp"

# Path where IIS hosts the application
# Example: C:\inetpub\wwwroot\MyApp
$destinationPath = "C:\inetpub\wwwroot\MyApp"

# Log file path (optional but very useful in real environments)
$logFile = "C:\Deploy\deploy-log.txt"

###############################################################
# 📝 LOGGING FUNCTION (Reusable)
###############################################################

function Write-Log {
    param (
        [string]$message
    )

    # Get current timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format log line
    $logEntry = "$timestamp - $message"

    # Output to console
    Write-Output $logEntry

    # Append to log file
    Add-Content -Path $logFile -Value $logEntry
}

###############################################################
# 🚀 STEP 1: STOP WEBSITE
###############################################################

Write-Log "Stopping IIS Website: $siteName"

# Stop the website to prevent file-in-use errors
Stop-Website -Name $siteName

###############################################################
# 🚀 STEP 2: STOP APP POOL (EXTRA SAFETY)
###############################################################

Write-Log "Stopping App Pool: $appPoolName"

# Stop App Pool (this ensures no background processes are locking files)
Stop-WebAppPool -Name $appPoolName

###############################################################
# 🚀 STEP 3: VERIFY SOURCE EXISTS
###############################################################

if (!(Test-Path $sourcePath)) {
    Write-Log "ERROR: Source path does not exist: $sourcePath"
    exit 1
}

###############################################################
# 🚀 STEP 4: CLEAN DESTINATION FOLDER
###############################################################

Write-Log "Cleaning destination folder: $destinationPath"

# Remove existing files (VERY IMPORTANT for clean deployment)
# -Recurse = include subfolders
# -Force = ignore read-only files
Remove-Item "$destinationPath\*" -Recurse -Force -ErrorAction SilentlyContinue

###############################################################
# 🚀 STEP 5: COPY NEW FILES
###############################################################

Write-Log "Copying new build files..."

# Copy everything from source to destination
Copy-Item -Path "$sourcePath\*" -Destination $destinationPath -Recurse -Force

###############################################################
# 🚀 STEP 6: START APP POOL
###############################################################

Write-Log "Starting App Pool: $appPoolName"

Start-WebAppPool -Name $appPoolName

###############################################################
# 🚀 STEP 7: START WEBSITE
###############################################################

Write-Log "Starting Website: $siteName"

Start-Website -Name $siteName

###############################################################
# 🚀 STEP 8: VERIFY DEPLOYMENT
###############################################################

# Check if website is running
$site = Get-Website -Name $siteName

if ($site.State -eq "Started") {
    Write-Log "Deployment SUCCESSFUL. Website is running."
}
else {
    Write-Log "WARNING: Website is NOT running after deployment."
}

###############################################################
# 🎉 DONE
###############################################################

Write-Log "Deployment script completed."