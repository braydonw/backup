Add link to DeskPi Pro repo & ssd setup guide
Mention using DeskPi Pro V1
Mention you need to set the always on hardware switch next to the power button
Mention which dual HDD enclosure you have and what HDD models - both dip switches (1&2) up for RAID 1
Mention UPS for switch/router, pi, and hdd enclosure
Mention how to setup the rpi safe shutdown when UPS battery is low (maybe also setup alerts / notifications / email when on battery or shutting down)

To install Network UPS Tool
`sudo apt install nut`

Mention using vim.tiny ?

Include code to add to default `~/.bashrc file`
```bash
vim.tiny ~/.bashrc
source ~/.bashrc
```
```bash
# Braydon Custom
alias temp="vcgenmd measure_temp"
alias voltage="vcgencmd measure_volts core"
alias throttled="vcgencmd get_throttled"
```

Mention useful commands:
`temp` (alias to check CPU temp)
`sudo apt update && sudo apt full-upgrade -y`
`sudo raspi-config`
`sudo deskpi-config`

- Mention ALL above steps in a nice format / order
    - Hardware
        - Flip always on switch in DeskPi Pro (near power button)
        - Connect everything. Router/switch, RPi, HDD bay power into power strip. Power strip into wall. Power strip USB into RPi. Switch ethernet into RPi. HDD bay USB into RPi.
    - Software
        - follow these instructions to setup DeskPi pro: https://github.com/DeskPi-Team/deskpi
            - install Raspberry Pi OS Full
                - https://www.raspberrypi.com/software/operating-systems/
                - current: Debian Trixie 64 bit
        - bashrc setup
            - see above
        - install NUT & configure safe shutdown on low battery
            - `sudo apt install nut`
            - what else? TBD
        - install Tailscale 
            - https://tailscale.com/docs/install/linux