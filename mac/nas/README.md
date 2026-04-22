# NAS Media Inventory Monitor

Automatically monitors your NAS media folder for changes and maintains dated inventory snapshots. Runs every 4 hours via macOS `launchd`.

## What It Does

- Scans your NAS Media folder every 4 hours
- Creates a dated inventory file when changes are detected
- Keeps a symlink to the latest inventory (`media-inventory-latest.txt`)
- Automatically cleans up files older than 90 days
- Logs all activity to macOS system log

## Requirements

- macOS (tested on macOS 26 Tahoe)
- NAS mounted at a consistent path (e.g., `/Volumes/YourNAS`)
- `bash` (pre-installed on macOS)
- `find`, `ls`, `diff`, `awk` (all pre-installed)

## Installation

### Step 1: Clone or Copy This Repo

```bash
cd ~
git clone <your-repo-url> nas-inventory-monitor
# Or copy the files manually
```

### Step 2: Run the Installer

```bash
cd ~/nas-inventory-monitor
./install.sh
```

The installer will:

- Create `~/bin/` and `~/NAS-Inventory-Backups/` directories
- Copy the script to `~/bin/nas-media-monitor.sh`
- Customize the `launchd` plist with your username
- Install the plist to `~/Library/LaunchAgents/`
- Load the service
- Run a test to verify everything works

### Step 3: Verify Your NAS Mount Path

Edit `~/bin/nas-media-monitor.sh` and update this line if needed:

```bash
NAS_MOUNT="/Volumes/YourNASName"  # Change to match your NAS
```

Find your NAS name with: `ls /Volumes/`

### Step 4: Test Manually

```bash
~/bin/nas-media-monitor.sh
```

Check for output in `~/NAS-Inventory-Backups/`

## File Locations After Install

| Purpose           | Path                                                         |
|-------------------|--------------------------------------------------------------|
| Main script       | `~/bin/nas-media-monitor.sh`                                 |
| Launchd plist     | `~/Library/LaunchAgents/com.user.nas-monitor.plist`          |
| Inventory backups | `~/NAS-Inventory-Backups/`                                   |
| Logs              | `~/Library/Logs/nas-monitor.log` and `nas-monitor-error.log` |

## Managing the Service

### Check Status

```bash
launchctl list | grep com.user.nas-monitor
```

### View Logs

```bash
# Real-time
tail -f ~/Library/Logs/nas-monitor.log

# Recent system log entries
log show --predicate 'process == "nas-monitor"' --last 1h
```

### Run Manually

```bash
launchctl start com.user.nas-monitor
```

### Stop/Disable

```bash
launchctl unload ~/Library/LaunchAgents/com.user.nas-monitor.plist
```

### Restart After Changes

```bash
launchctl unload ~/Library/LaunchAgents/com.user.nas-monitor.plist
launchctl load ~/Library/LaunchAgents/com.user.nas-monitor.plist
```

## Restoring on a New Mac

1. Copy this repo to the new Mac
2. Mount your NAS (same name as before, or update the script)
3. Run `./install.sh`
4. Copy your old inventory files to `~/NAS-Inventory-Backups/` if you want history

## Customization

### Change Check Interval

Edit `~/Library/LaunchAgents/com.user.nas-monitor.plist`:

```xml
<key>StartInterval</key>
<integer>3600</integer>  <!-- 3600 = 1 hour, 7200 = 2 hours, etc -->
```

### Change Retention Period

Edit `~/bin/nas-media-monitor.sh`:

```bash
RETENTION_DAYS=30   # Keep 30 days instead of 90
RETENTION_DAYS=0    # Keep forever (not recommended)
```

### Change Backup Location

Edit `~/bin/nas-media-monitor.sh`:

```bash
BACKUP_DIR="/path/to/your/preferred/location"
```

## Troubleshooting

| Issue                     | Solution                                              |
|---------------------------|-------------------------------------------------------|
| "NAS not mounted"         | Check `ls /Volumes/` and update `NAS_MOUNT` in script |
| Permission denied         | Run `chmod +x ~/bin/nas-media-monitor.sh`             |
| Not running automatically | Check `launchctl list \| grep nas-monitor` and logs   |
| Empty inventory files     | NAS may be sleeping; check energy saver settings      |

## License

MIT - Use and modify freely.
