# Raspberry Pi Offsite Backup Node

This folder documents the **remote / offsite backup node** of a larger backup strategy.

This system is designed to live at another location and receive backups over a secure network connection. Other backup systems (onsite machines, local redundancy, workflows, retention policies, etc.) are documented elsewhere.

# Overview

This node provides:

- Remote / offsite backup storage
- Local disk redundancy via RAID 1 mirror
- Secure remote access through [Tailscale](https://tailscale.com/)
- Network file sharing through [Samba](https://www.samba.org/)
- UPS-backed power protection
- Low-power always-on operation

# Hardware Setup

## Components Used

### Core System

- Raspberry Pi 4 Model B (4GB RAM)
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

Follow the official DeskPi [setup guide](https://github.com/DeskPi-Team/deskpi) and refer to their [wiki](https://wiki.deskpi.com/deskpipro/) for more details and troubleshooting.

You can also watch [this](https://youtu.be/eaXC5O3amfA) video for a walkthrough of the initial setup process and [this](https://youtu.be/BLfpZWI_yDA) video for SSD setup instructions.

The latest Raspberry Pi Imager allows you to pre-configure the OS image with settings like:

- Set hostname (`rpi`)
- Set username/password (`bw`/`password`)
- Configure Wi-Fi (if needed)
- Enable SSH & add keys for remote access (use Bitwarden SSH key storage)
- Enable Raspberry Pi Connect (optional)
- #todo walk through this again on Windows and update this list / fix the order)

```bash
# Update package lists and install all available upgrades
sudo apt update && sudo apt full-upgrade -y

# Run base Raspberry Pi configuration utility
# - Enable command-line boot (1 → S5 → B1)
# - Enable auto login (1 → S6)
sudo raspi-config 

# Run DeskPi Pro configuration utility
# - Manually configure fan curve or enable auto mode (6 or 7)
sudo deskpi-config 
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
sudo mkdir -p /srv/nas

# Find the UUID of /dev/sdb1
lsblk -f

# Backup current fstab
sudo cp /etc/fstab /etc/fstab.bak

# Edit fstab
sudo nano /etc/fstab

# Add this line to /etc/fstab (replace with actual UUID)
UUID=YOUR-UUID-HERE /srv/nas ext4 defaults,nofail,noatime 0 2

# Reload systemd to apply changes
sudo systemctl daemon-reload

# Test fstab without rebooting
sudo mount -a

# Verify mount
df -h

# Set ownership to current user
sudo chown -R $USER:$USER /srv/nas

# Create backup folder
mkdir -p /srv/nas/backup

# Create symlink for easier access
ln -s /srv/nas ~/nas
```

After reboot or power restoration, the RAID volume will automatically mount to: `/srv/nas`














---
---
---

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

# UPS Safe Shutdown (NUT)

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

# Show system uptime in human-readable format
uptime -p

# Show system boot date and time
uptime -s

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

# TODO

- Figure out if using samba or something else, update docs, remove all samba references if needed
- Figure out if you can spin-down hdds when not in use, update this README with instructions
- See how much of this you can script, create the script, add it to this folder, update README
    - Script can help reduce the stuff in this README and be self-documenting with comments and clear structure
- MAYBE: Add bashrc aliases again (temp, etc.), update script to append to bashrc (idempotent), add list of useful aliases to README
- Figure out how to configure fans so they are normally off and only turn on when the CPU reaches a certain temperature, update script (if possible) and README with instructions
- Configure neovim & lazyvim, then update any vim.tiny / nano references in this README to neovim

# Future Improvements

- SMART monitoring
- Drive health alerts
- Email notifications
- Samba hardening
- Automated snapshot replication
- Remote reboot watchdog
- Periodic restore testing













# NEW

## Bashrc

```bash
# Braydon Custom
alias temp="vcgenmd measure_temp"
alias voltage="vcgencmd measure_volts core"
alias throttled="vcgencmd get_throttled"
```

## HDD Spin-Down

https://github.com/adelolmo/hd-idle


```bash
# Install hd-idle for hard drive spin-down management
sudo apt install hd-idle

# Edit hd-idle configuration
sudo nano /etc/default/hd-idle

# Change this line from false to true & close the file
START_HD_IDLE=true

# Enable hd-idle to start on boot and start the service immediately
sudo systemctl enable --now hd-idle

```




sudo apt install sysstat
sudo apt-get install smartmontools

disabled hd-idle
sudo apt-get install sdparm



sudo systemctl status hd-idle
sudo nano /etc/default/hd-idle
sudo systemctl restart hd-idle
sudo smartctl -a -n standby /dev/sdb
sudo smartctl -d ata -n standby /dev/sdb
sudo iostat -x 1 5 /dev/sdb
sudo smartctl -d ata -i -n standby /dev/sdb
sudo hdparm -S 0 /dev/sdb

sudo smartctl -a /dev/sdb --device=scsi
sudo smartctl -d scsi -n standby /dev/sdb
    # actually reports active (so use scsi, not ata)
sudo cat /var/log/hd-idle.log

# standby
sudo hdparm -y /dev/sdb
# sleep
sudo hdparm -Y /dev/sdb
# check status
sudo hdparm -C /dev/sdb

# view settings
sudo hdparm -I /dev/sdb
sudo hdparm -i /dev/sdb

