###############################################################
# DISK SPACE MONITORING + ALERT SCRIPT
# -------------------------------------------------------------
# What this script does:
# 1. Checks disk usage for all drives (or specific drives)
# 2. Calculates free space %
# 3. Triggers alert if below threshold
# 4. Logs all results
###############################################################

###############################################################
# 🔧 CONFIGURATION SECTION (EDIT THESE)
###############################################################

# Threshold for minimum free space (in percentage)
# Example: 20 means alert if free space < 20%
$thresholdPercent = 20

# Log file path
$logFile = "C:\Logs\disk-monitor-log.txt"

# OPTIONAL: Monitor only specific drives (leave empty for all)
# Example: @("C:", "D:")
$drivesToMonitor = @()

###############################################################
# 📝 LOGGING FUNCTION
###############################################################

function Write-Log {
    param (
        [string]$message
    )

    # Generate timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format message
    $logEntry = "$timestamp - $message"

    # Print to console
    Write-Output $logEntry

    # Append to log file
    Add-Content -Path $logFile -Value $logEntry
}

###############################################################
# 🚀 STEP 1: GET DISK INFORMATION
###############################################################
# Get-WmiObject Win32_LogicalDisk retrieves disk info
# DriveType=3 means "Local Disk" (not CD/DVD, network, etc.)

$disks = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

###############################################################
# 🚀 STEP 2: FILTER DRIVES (OPTIONAL)
###############################################################

if ($drivesToMonitor.Count -gt 0) {
    # If user specified drives, filter them
    $disks = $disks | Where-Object { $drivesToMonitor -contains $_.DeviceID }
}

###############################################################
# 🚀 STEP 3: LOOP THROUGH EACH DISK
###############################################################

foreach ($disk in $disks) {

    # Total size of disk (bytes → convert to GB)
    $totalSizeGB = [math]::Round($disk.Size / 1GB, 2)

    # Free space (bytes → convert to GB)
    $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)

    # Calculate free space percentage
    $freePercent = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)

    # Log current disk status
    Write-Log "Drive: $($disk.DeviceID) | Free: $freeSpaceGB GB / $totalSizeGB GB ($freePercent%)"

    ###########################################################
    # 🚨 STEP 4: CHECK THRESHOLD
    ###########################################################

    if ($freePercent -lt $thresholdPercent) {

        Write-Log "ALERT: Low disk space on $($disk.DeviceID) - Only $freePercent% free!"

        #######################################################
        # 🚨 ALERT ACTION (SIMPLE VERSION)
        #######################################################

        # Option 1: Console alert
        Write-Output "WARNING: Disk space critically low on $($disk.DeviceID)"

        # Option 2: Write to Windows Event Log (optional advanced)
        # Write-EventLog -LogName Application -Source "DiskMonitor" -EntryType Warning -EventId 1001 -Message "Low disk space on $($disk.DeviceID)"

        # Option 3: Trigger another script (cleanup, etc.)
        # Example:
        # & "C:\Scripts\log-cleanup.ps1"

        #######################################################
        # NOTE:
        # In real environments, this is where you:
        # - Send email
        # - Trigger monitoring system alert
        # - Auto-run cleanup scripts
        #######################################################
    }
}

###############################################################
# 🎉 DONE
###############################################################

Write-Log "Disk monitoring completed."