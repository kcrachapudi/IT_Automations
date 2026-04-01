###############################################################
# SQL SERVER DATABASE RESTORE SCRIPT
# -------------------------------------------------------------
# What this script does:
# 1. Terminates active connections to the database
# 2. Switches DB to SINGLE_USER mode (required for restore)
# 3. Restores database from .bak file
# 4. Switches DB back to MULTI_USER mode
# 5. Logs every step
###############################################################

###############################################################
# 🔧 CONFIGURATION SECTION (EDIT THESE)
###############################################################

# SQL Server instance (use "." for local machine)
$server = "."

# Database name you want to restore
$database = "AdventureWorks"

# Full path to backup file (.bak)
$backupFile = "C:\SQLBackups\AdventureWorks-2026-04-01_12-00-00.bak"

# Log file path
$logFile = "C:\SQLBackups\restore-log.txt"

###############################################################
# 📝 LOGGING FUNCTION
###############################################################

function Write-Log {
    param (
        [string]$message
    )

    # Create timestamp
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Format log line
    $logEntry = "$timestamp - $message"

    # Print to console
    Write-Output $logEntry

    # Append to log file
    Add-Content -Path $logFile -Value $logEntry
}

###############################################################
# 🚀 STEP 1: VALIDATE BACKUP FILE EXISTS
###############################################################

if (!(Test-Path $backupFile)) {
    Write-Log "ERROR: Backup file not found: $backupFile"
    exit 1
}

Write-Log "Backup file found: $backupFile"

###############################################################
# 🚀 STEP 2: FORCE DATABASE INTO SINGLE USER MODE
###############################################################
# WHY THIS IS IMPORTANT:
# SQL Server cannot restore a DB if other users are connected.
# SINGLE_USER mode kicks everyone out.

Write-Log "Setting database to SINGLE_USER mode..."

$querySingleUser = @"
ALTER DATABASE [$database]
SET SINGLE_USER WITH ROLLBACK IMMEDIATE
"@

# Execute SQL command
sqlcmd -S $server -Q $querySingleUser

###############################################################
# 🚀 STEP 3: RESTORE DATABASE
###############################################################
# WITH REPLACE:
# Overwrites existing database
#
# STATS = 10:
# Shows progress every 10%

Write-Log "Starting database restore..."

$queryRestore = @"
RESTORE DATABASE [$database]
FROM DISK = N'$backupFile'
WITH REPLACE,
     RECOVERY,
     STATS = 10
"@

# Execute restore command
sqlcmd -S $server -Q $queryRestore

Write-Log "Restore command executed."

###############################################################
# 🚀 STEP 4: SET DATABASE BACK TO MULTI USER
###############################################################

Write-Log "Setting database back to MULTI_USER mode..."

$queryMultiUser = @"
ALTER DATABASE [$database]
SET MULTI_USER
"@

sqlcmd -S $server -Q $queryMultiUser

###############################################################
# 🚀 STEP 5: VERIFY DATABASE STATUS
###############################################################

Write-Log "Verifying database status..."

$queryCheck = @"
SELECT name, state_desc
FROM sys.databases
WHERE name = '$database'
"@

# Execute and display result
sqlcmd -S $server -Q $queryCheck

###############################################################
# 🎉 DONE
###############################################################

Write-Log "Database restore completed successfully."