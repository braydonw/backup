# Backup Architecture

This repository documents my backup architecture, configuration files, and operational runbooks for restoring systems. It's designed around practical recoverability: getting machines back online quickly with critical data intact, without over-engineering for theoretical completeness.

## Backup Model

This setup is 3-2-1 inspired rather than strict: multiple recoverable copies across heterogeneous storage, with offsite coverage through both self-hosted and cloud options. The goal is resilience against single points of failure without excessive operational burden.

| Copy         | Location                         | Media Type         | Notes                                 |
| ------------ | -------------------------------- | ------------------ | ------------------------------------- |
| Primary      | Each machine's internal storage  | NVMe / NAND flash  | Live working systems                  |
| Local backup | Mac external HDD                 | HDD                | On-site, lower redundancy priority    |
| Offsite 1    | Raspberry Pi (RAID 1)            | HDD                | Self-hosted, geographically separate  |
| Offsite 2    | Dropbox                          | Cloud              | Encrypted, provider may change        |

**TODO: FINISH THIS DOC** - https://t3.chat/chat/f04fc80a-bd4e-4385-b478-78351093c3e0

- This setup is **3-2-1 inspired** rather than a strict textbook implementation
- Goal: keep multiple recoverable copies across local and remote locations
- Remote/offsite copies currently include **Dropbox** and the **Raspberry Pi** backup host

## Machine-Level Docs

- [Linux](linux/README.md) - Primary
- [Windows](windows/README.md) - Gaming
- [Mac](mac/README.md) - HTPC & NAS
- [Raspberry Pi](rpi/README.md) - Offsite Backup
- [Dropbox](dropbox/README.md) - Cloud Backup
- [Recovery Playbooks](recovery/README.md)

## Storage Topology

- **FormD T1 Desktop**
  - `4TB NVMe` — Windows
  - `4TB NVMe` — Linux
- **Mac Mini**
  - `256GB internal NAND flash` — macOS/system
  - `4TB external HDD` — backup/media storage (lower redundancy priority)
- **Raspberry Pi**
  - `480GB SSD` — boot/system
  - `2x 4TB external HDDs` — RAID 1 remote backups

## Recovery (TODO)

- Root-level goal: ensure each machine can be restored to a usable state with critical data available.
- Detailed procedures, runbooks, and validation steps should live in machine-level docs and/or `recovery/README.md`.
- Root-level focus is only scope, topology, and where to find implementation details.
