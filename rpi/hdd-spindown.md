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

```bash
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
# reports active (so use scsi, not ata?)
sudo smartctl -d scsi -n standby /dev/sdb
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
```
