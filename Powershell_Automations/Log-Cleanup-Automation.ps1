###############################################################
# LOG CLEANUP AUTOMATION SCRIPT
# -------------------------------------------------------------
# What this script does:
# 1. Scans a folder (and subfolders) for log files
# 2. Identifies files older than X days
# 3. Deletes old files
# 4. Logs all actions
###############################################################

###############################################################
# 🔧 CONFIGURATION SECTION (EDIT THESE)
###############################################################

# Folder where logs are stored
# Example:
# IIS logs: C:\inetpub\logs\LogFiles
# App logs: C:\Logs
$logFolder = "C:\Logs"

# File extension to target (you can change to *.txt, *.log, etc.)
$fileFilter = "*.log"

# Number of days to KEEP logs
# Files older than this will be deleted
$daysToKeep = 7

# Log file to record cleanup activity
$logFile = "C:\Logs\cleanup-log.txt"

###############################################################
# 📝 LOGGING FUNCTION
###############################################################

function Write-Log {
    param (
        [string]$message
    )

    # Get current timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format message
    $logEntry = "$timestamp - $message"

    # Print to console
    Write-Output $logEntry

    # Append to log file
    Add-Content -Path $logFile -Value $logEntry
}

###############################################################
# 🚀 STEP 1: VALIDATE FOLDER EXISTS
###############################################################

if (!(Test-Path $logFolder)) {
    Write-Log "ERROR: Log folder does not exist: $logFolder"
    exit 1
}

Write-Log "Scanning folder: $logFolder"

###############################################################
# 🚀 STEP 2: CALCULATE CUTOFF DATE
###############################################################
# We only delete files OLDER than this date

$cutoffDate = (Get-Date).AddDays(-$daysToKeep)

Write-Log "Deleting files older than: $cutoffDate"

###############################################################
# 🚀 STEP 3: GET ALL MATCHING FILES
###############################################################
# -Recurse → includes subfolders
# -File → ensures only files (not directories)

$files = Get-ChildItem -Path $logFolder -Filter $fileFilter -Recurse -File

Write-Log "Total files found: $($files.Count)"

###############################################################
# 🚀 STEP 4: LOOP THROUGH FILES
###############################################################

foreach ($file in $files) {

    # Check if file is older than cutoff date
    if ($file.LastWriteTime -lt $cutoffDate) {

        Write-Log "Deleting file: $($file.FullName)"

        try {
            # Attempt to delete file
            Remove-Item $file.FullName -Force

            Write-Log "Deleted successfully."
        }
        catch {
            # Catch any errors (file locked, permissions, etc.)
            Write-Log "ERROR deleting file: $($file.FullName)"
            Write-Log $_
        }
    }
    else {
        # Optional: log skipped files (can be noisy in large systems)
        # Write-Log "Skipping (recent file): $($file.FullName)"
    }
}

###############################################################
# 🚀 STEP 5: OPTIONAL - REMOVE EMPTY FOLDERS
###############################################################
# After deleting logs, some folders may be empty

Write-Log "Checking for empty folders..."

$folders = Get-ChildItem -Path $logFolder -Recurse -Directory

foreach ($folder in $folders) {

    # Check if folder is empty
    if (!(Get-ChildItem -Path $folder.FullName)) {

        Write-Log "Removing empty folder: $($folder.FullName)"

        try {
            Remove-Item $folder.FullName -Force
        }
        catch {
            Write-Log "ERROR removing folder: $($folder.FullName)"
        }
    }
}

###############################################################
# 🎉 DONE
###############################################################

Write-Log "Log cleanup completed successfully."