###############################################################
# WINDOWS SERVICE AUTO-HEALING SCRIPT
# -------------------------------------------------------------
# What this script does:
# 1. Checks status of critical Windows services
# 2. If a service is stopped or unhealthy:
#       → Attempts to start/restart it
# 3. Logs all actions
# 4. Prevents repeated failures from going unnoticed
###############################################################

###############################################################
# 🔧 CONFIGURATION SECTION (EDIT THESE)
###############################################################

# List of services to monitor
# IMPORTANT:
# Use service names (not display names)
# Example:
# W3SVC = IIS Web Server
# MSSQLSERVER = SQL Server default instance

$servicesToMonitor = @(
    "W3SVC",         # IIS Web Server (:contentReference[oaicite:0]{index=0})
    "MSSQLSERVER"    # SQL Server (:contentReference[oaicite:1]{index=1})
)

# Log file path
$logFile = "C:\Logs\service-heal-log.txt"

# Number of retry attempts if service fails to start
$maxRetries = 2

# Delay (in seconds) between retries
$retryDelay = 3

###############################################################
# 📝 LOGGING FUNCTION
###############################################################

function Write-Log {
    param (
        [string]$message
    )

    # Generate timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format log message
    $logEntry = "$timestamp - $message"

    # Output to console
    Write-Output $logEntry

    # Save to log file
    Add-Content -Path $logFile -Value $logEntry
}

###############################################################
# 🚀 STEP 1: LOOP THROUGH EACH SERVICE
###############################################################

foreach ($serviceName in $servicesToMonitor) {

    Write-Log "Checking service: $serviceName"

    try {
        #######################################################
        # 🚀 STEP 2: GET SERVICE OBJECT
        #######################################################

        $service = Get-Service -Name $serviceName -ErrorAction Stop

        Write-Log "Current status: $($service.Status)"

        #######################################################
        # 🚀 STEP 3: CHECK IF SERVICE IS RUNNING
        #######################################################

        if ($service.Status -ne "Running") {

            Write-Log "Service is NOT running. Attempting recovery..."

            ###################################################
            # 🔁 STEP 4: RETRY LOOP
            ###################################################

            $attempt = 0
            $success = $false

            while ($attempt -lt $maxRetries -and -not $success) {

                $attempt++
                Write-Log "Attempt #$attempt to start service: $serviceName"

                try {
                    # Try to start the service
                    Start-Service -Name $serviceName -ErrorAction Stop

                    # Wait a few seconds to allow service to stabilize
                    Start-Sleep -Seconds $retryDelay

                    # Re-check service status
                    $service = Get-Service -Name $serviceName

                    if ($service.Status -eq "Running") {
                        Write-Log "Service started successfully."
                        $success = $true
                    }
                    else {
                        Write-Log "Service did not reach RUNNING state."
                    }
                }
                catch {
                    Write-Log "ERROR during start attempt: $_"
                }
            }

            ###################################################
            # ❌ STEP 5: FINAL FAILURE HANDLING
            ###################################################

            if (-not $success) {
                Write-Log "CRITICAL: Service $serviceName failed to start after $maxRetries attempts."

                # OPTIONAL: trigger alert / escalation
                # Example:
                # Send email
                # Write to event log
                # Trigger incident system
            }
        }
        else {
            Write-Log "Service is healthy."
        }
    }
    catch {
        #######################################################
        # 🚨 HANDLE CASE WHERE SERVICE DOES NOT EXIST
        #######################################################

        Write-Log "ERROR: Service not found: $serviceName"
        Write-Log $_
    }
}

###############################################################
# 🎉 DONE
###############################################################

Write-Log "Service auto-healing check completed."