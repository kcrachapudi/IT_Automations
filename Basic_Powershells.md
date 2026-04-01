⚡ 🟦 10 PowerShell Automations (IIS + SQL Server + Ops)

Think of these as your core automation toolkit.

1. Restart IIS Safely (with logging)
Restart IIS only if needed
Log action with timestamp

👉 Use case: Production support

2. Check Website Status + Auto Recover
Check if IIS site is stopped
Start it automatically

👉 Prevent downtime without manual intervention

3. Deploy .NET App to IIS
Stop site
Copy new build
Start site

👉 This becomes your manual fallback deployment script

4. Monitor App Pool Health
Detect stopped/crashed app pools
Restart automatically

👉 Very common real-world issue

5. SQL Server Backup Automation
Run full DB backup
Save with timestamp

👉 Critical for “backup & recovery” requirement

6. SQL Server Restore Script
Restore DB from backup file

👉 Huge resume booster (most people skip this)

7. Check SQL Server Connectivity
Attempt DB connection
Log success/failure

👉 Helps debug outages quickly

8. Windows Service Auto-Healing
Check key services (IIS, SQL Server)
Restart if stopped

👉 Classic “support engineer” automation

9. Disk Space Monitoring + Alert
Check server disk usage
Log or alert if > threshold

👉 Prevents production crashes

10. Log Cleanup Automation
Delete old logs (IIS, app logs)
Keep last X days

👉 Keeps systems clean + avoids disk issues
