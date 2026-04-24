# Raspberry Pi Offsite Backup Node

This folder contains setup notes for a remote/offsite backup node built around a Raspberry Pi, external RAID enclosure, Tailscale remote access, and Samba file sharing.

This is one part of a larger backup strategy. Other components (onsite backup systems, workflows, retention plans, etc.) are documented elsewhere.

## Overview

This system is intended to:

- Live at a remote/offsite location
- Store backup data replicated from primary systems
- Be remotely accessible through [Tailscale](https://tailscale.com/)
- Provide network file shares via [Samba](https://www.samba.org/)
- Use mirrored drives (RAID 1) for local disk redundancy
- Safely shut down during power outages with a UPS

## Hardware Used

### Core System

- Raspberry Pi
- DeskPi Pro V1

### Important DeskPi Pro Setting

Set the **Always On** hardware switch (next to the power button) so the Pi automatically powers back on after outages.

#### Storage

- Dual-bay USB HDD enclosure configured in **RAID 1**
- DIP switches **1 and 2 UP** (mirror mode)

Replace with your exact enclosure model + drive models.

#### Power Protection

Use a UPS to power:

- Internet modem/router (optional)
- Network switch (optional)
- Raspberry Pi
- RAID enclosure

This allows graceful shutdown during outages and preserves remote connectivity longer.

## Recommended OS

Download & install [Raspberry Pi OS Full (64-bit)](https://www.raspberrypi.com/software/operating-systems/)

Current recommended version: Debian Trixie (64-bit)

## Initial System Setup

Update everything first:

```bash
sudo apt update && sudo apt full-upgrade -y
```

Run base configuration:

```bash
sudo raspi-config
```

If using DeskPi utilities:

`
sudo deskpi-config