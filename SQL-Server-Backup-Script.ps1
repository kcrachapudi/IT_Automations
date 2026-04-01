# Define SQL Server instance
# "." means local machine
$server = "."

# Define database name
$database = "AdventureWorks"

# Define backup folder path
# Make sure this folder exists
$backupPath = "C:\SQLBackups"

# Generate timestamp for unique backup file
# Format: Year-Month-Day_Hour-Minute-Second
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Build full backup file path
$backupFile = "$backupPath\$database-$timestamp.bak"

Write-Output "Starting backup for database: $database"

# Build SQL query for backup
# BACKUP DATABASE is SQL Server command
$query = "BACKUP DATABASE [$database] TO DISK = N'$backupFile' WITH NOFORMAT, NOINIT, NAME = '$database-Full Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"

# Execute SQL command using sqlcmd (built-in tool)
sqlcmd -S $server -Q $query

Write-Output "Backup completed: $backupFile"
