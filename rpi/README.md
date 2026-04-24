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

### Power Protection


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

## Operating System

Currently using **Raspberry Pi OS**, which is based on Debian Trixie and includes the Raspberry Pi Desktop environment.

## DeskPi Pro Setup

Follow the official DeskPi setup guide:

https://github.com/DeskPi-Team/deskpi

No need to duplicate their instructions here.

## Initial Updates

```bash
sudo apt update && sudo apt full-upgrade -y
```

## Base Raspberry Pi Configuration

```bash
sudo raspi-config
```

## DeskPi Configuration Utility

```bash
sudo deskpi-config
```

# Storage Setup

## Prepare RAID Volume

Use GParted or another partitioning tool.

Recommended configuration:

- Partition Table: `gpt`
- Filesystem: `ext4`
- Label: `nas`

Expected device:

```bash
/dev/sdb1
```

## Mount Drive

```bash
sudo mount /dev/sdb1 /mnt
```

## Set Ownership

```bash
sudo chown -R $USER:$USER /mnt
```

## Create Backup Folder

```bash
mkdir /mnt/backup
```

## Recommended Future Improvement

Use `/etc/fstab` with UUID for automatic mounting on boot.

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

## System Updates

```bash
sudo apt update && sudo apt full-upgrade -y
```

## Reboot

```bash
sudo reboot
```

## Shutdown

```bash
sudo shutdown now
```

## Temperature

```bash
vcgencmd measure_temp
```

## Voltage

```bash
vcgencmd measure_volts core
```

## Throttling / Undervoltage Status

```bash
vcgencmd get_throttled
```

## Show Drives

```bash
lsblk -f
```

## Disk Usage

```bash
df -h
```

## Unmount Backup Drive

```bash
sudo umount /mnt
```

## Network Interfaces

```bash
ip addr
```

## Tailscale Status

```bash
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

# Notes

This node is intended for **backup storage**, not primary storage.

Backups only matter if restores are tested regularly.