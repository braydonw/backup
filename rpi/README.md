# Raspberry Pi Offsite Backup Node

This folder documents the **remote / offsite backup node** of a larger backup strategy.

This system is designed to live at another location and receive backups over a secure network connection. Other backup systems (onsite machines, local redundancy, workflows, retention policies, etc.) are documented elsewhere.

# Overview

This node provides:

- Remote / offsite backup storage
- Local disk redundancy via RAID 1 mirror
- Secure remote access through Tailscale
- Network file sharing through Samba
- UPS-backed power protection
- Low-power always-on operation

# Hardware Setup

## Components Used

### Core System

- Raspberry Pi
- DeskPi Pro V1

### Boot Drive

- PNY 480GB SSD  
  `SSD2SC480G1CS1754D117-514`

### Backup Storage

- Dual-bay USB 3.0 RAID enclosure
- 2x HGST 4TB NAS drives  
  `HDN724040ALE640`

Configured as:

- RAID 1 (mirror)

### Power Protection #todo

- Amazon Basics UPS (600VA / 360W)  
    `TODO: add model here`

Recommended to power:

- Modem / router
- Network switch
- Raspberry Pi
- RAID enclosure

## Hardware Configuration

### DeskPi Pro

Set the **Always On** hardware switch (next to the power button).

This allows the system to automatically power back on after a power outage.

### RAID Enclosure

Set enclosure DIP switches for RAID 1 mirror mode:

- Switch 1 = UP
- Switch 2 = UP

### Wiring Notes

- Connect all devices to a UPS-backed power strip (#todo)
- Connect Raspberry Pi to network via Ethernet
- Connect RAID enclosure to Raspberry Pi via USB
- Connect UPS USB data cable to Raspberry Pi for monitoring and safe shutdown events

# Software Setup

## Initial System Setup

Follow the official DeskPi setup guide: https://github.com/DeskPi-Team/deskpi

The latest Raspberry Pi Imager allows you to pre-configure the OS image with settings like:

- Set hostname (`rpi`)
- Set username/password (`bw`/`password`)
- Configure Wi-Fi (if needed)
- Enable SSH & add keys for remote access (use Bitwarden SSH key storage)
- Enable Raspberry Pi Connect
- #todo walk through this again on Windows and update this list / fix the order)

```bash
# Update package lists and install all available upgrades
sudo apt update && sudo apt full-upgrade -y

# Run base Raspberry Pi configuration utility
sudo raspi-config # Enable auto-login to console & desktop

# Run DeskPi Pro configuration utility
sudo deskpi-config # Enable automatic fan control or configure fan curve
```









# Storage Setup

Use GParted or another partitioning tool.

Recommended RAID volume configuration:

- Partition Table: `gpt`
- Filesystem: `ext4`
- Label: `nas`

Expected device: `/dev/sdb1` (verify with `lsblk -f`)

```bash
# Create permanent mount point
sudo mkdir -p /srv/backup

# Find the UUID of /dev/sdb1
lsblk -f

# Backup current fstab
sudo cp /etc/fstab /etc/fstab.bak

# Edit fstab
sudo nano /etc/fstab

# Add this line to /etc/fstab (replace with actual UUID)
UUID=YOUR-UUID-HERE /srv/backup ext4 defaults,nofail,noatime 0 2

# Test fstab without rebooting
sudo mount -a

# Verify mount
df -h

# Set ownership to current user
sudo chown -R $USER:$USER /srv/backup

# Create backup folder
mkdir -p /srv/backup/backup
```

After reboot or power restoration, the RAID volume will automatically mount to:

`/srv/backup`

Primary backup folder:

`/srv/backup/backup`





















# Storage Setup

## Prepare RAID Volume

Use GParted or another partitioning tool.

Recommended configuration:

- Partition Table: `gpt`
- Filesystem: `ext4`
- Label: `nas`

Expected device: `/dev/sdb1` (verify with `lsblk`)


## Mount and Set Permissions

```bash
# Mount the RAID volume
sudo mount /dev/sdb1 /mnt

# Set ownership to the current user
sudo chown -R $USER:$USER /mnt

# Create a folder for backups
mkdir /mnt/backup
```

## Recommended Future Improvement

Use `/etc/fstab` with UUID for automatic mounting on boot.












#todo redo the below sections into something simpler and more concise like "Package Setup" with subsections for Tailscale, Samba, UPS monitoring, etc.

# Remote Access (Tailscale)

Install Tailscale:

https://tailscale.com/docs/install/linux

Then run:

```bash
sudo tailscale up
```

Use cases:

- Remote SSH access
- Remote administration
- Secure SMB access over private network

# File Sharing (Samba)

Install Samba:

```bash
sudo apt install samba
```

Typical shared path:

```bash
/mnt/backup
```

Recommended hardening:

- Dedicated backup user
- Strong password
- Restrict access to Tailscale network only
- Disable guest access

# UPS Safe Shutdown

Install Network UPS Tools:

```bash
sudo apt install nut
```

Goal:

- Detect power loss
- Monitor battery runtime
- Graceful shutdown when battery is low
- Optional alerts / notifications

UPS configuration depends on the exact UPS model.

# Useful Commands

```bash
# Update package lists and install all available upgrades
sudo apt update && sudo apt full-upgrade -y

# Reboot the Raspberry Pi
sudo reboot

# Shut down immediately
sudo shutdown now

# Show CPU temperature
vcgencmd measure_temp

# Show core voltage
vcgencmd measure_volts core

# Show throttling / undervoltage history
vcgencmd get_throttled

# List drives, partitions, and filesystems
lsblk -f

# Show disk usage in human-readable format
df -h

# Unmount backup drive
sudo umount /mnt

# Show network interfaces and IP addresses
ip addr

# Show Tailscale connection status
tailscale status
```

# Future Improvements

- `/etc/fstab` auto-mount by UUID
- SMART monitoring
- Drive health alerts
- Email notifications
- Samba hardening
- Automated snapshot replication
- Remote reboot watchdog
- Periodic restore testing
