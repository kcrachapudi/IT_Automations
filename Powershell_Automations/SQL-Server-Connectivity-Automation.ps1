###############################################################
# SAFE IIS RESTART SCRIPT WITH LOGGING
# -------------------------------------------------------------
# What this script does:
# 1. Logs the restart attempt with timestamp
# 2. Stops IIS cleanly (not force kill)
# 3. Waits to ensure shutdown completes
# 4. Starts IIS again
# 5. Logs success or failure
###############################################################

###############################################################
# 🔧 CONFIGURATION SECTION (EDIT THIS)
###############################################################

# Log file path (make sure folder exists)
$logFile = "C:\Logs\iis-restart-log.txt"

# Optional: Add delay after stopping IIS
# This helps ensure all processes shut down cleanly
$shutdownDelay = 5

###############################################################
# 📝 LOGGING FUNCTION
###############################################################

function Write-Log {
    param (
        [string]$message
    )

    # Get current timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format log entry
    $logEntry = "$timestamp - $message"

    # Output to console (for immediate visibility)
    Write-Output $logEntry

    # Append to log file (persistent record)
    Add-Content -Path $logFile -Value $logEntry
}

###############################################################
# 🚀 STEP 1: LOG START OF OPERATION
###############################################################

Write-Log "Starting IIS restart process..."

###############################################################
# 🚀 STEP 2: STOP IIS SAFELY
###############################################################
# Use iisreset /stop instead of force-killing processes
# This ensures graceful shutdown of all IIS worker processes

try {

    Write-Log "Stopping IIS..."

    # Command to stop IIS
    iisreset /stop

    # Wait to ensure IIS shuts down fully
    Write-Log "Waiting $shutdownDelay seconds for IIS to stop..."

    Start-Sleep -Seconds $shutdownDelay

    Write-Log "IIS stop command executed."

}
catch {

    ###########################################################
    # 🚨 HANDLE STOP FAILURE
    ###########################################################

    Write-Log "ERROR: Failed to stop IIS."
    Write-Log $_
}

###############################################################
# 🚀 STEP 3: START IIS
###############################################################
# Restart IIS after clean shutdown

try {

    Write-Log "Starting IIS..."

    # Command to start IIS
    iisreset /start

    Write-Log "IIS start command executed."

}
catch {

    ###########################################################
    # 🚨 HANDLE START FAILURE
    ###########################################################

    Write-Log "ERROR: Failed to start IIS."
    Write-Log $_
}

###############################################################
# 🚀 STEP 4: VERIFY IIS STATUS
###############################################################
# Check if IIS service is running properly

try {

    # Query IIS service status
    $service = Get-Service -Name "W3SVC"

    Write-Log "IIS Service Status: $($service.Status)"

    if ($service.Status -eq "Running") {
        Write-Log "SUCCESS: IIS restarted successfully."
    }
    else {
        Write-Log "WARNING: IIS is not running after restart."
    }

}
catch {

    ###########################################################
    # 🚨 HANDLE STATUS CHECK FAILURE
    ###########################################################

    Write-Log "ERROR: Unable to verify IIS service status."
    Write-Log $_
}

###############################################################
# 🎉 DONE
###############################################################

Write-Log "IIS restart process completed."