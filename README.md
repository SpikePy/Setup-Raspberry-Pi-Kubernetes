# pi4_setup
1. Download the most recent arm64 (image)[http://downloads.raspberrypi.org/raspios_arm64/images/]
2. connect your micro-sd card and find out its device name `lsblk -p`
3. unzip and write it to the sd-card `unzip -p 2021-03-04-raspios-buster-armhf.zip | sudo dd of=/dev/sdX bs=4M conv=fsync`
4. change the size of the root-partitioan to span over the whole card with: tbd
5. enable ssh
  1. mount the newly created boot-partition and `cd` into it
  2. touch .../boot/ssh
6. setup WLAN
  1. mount the newly created boot-partition and `cd` into it
  2. vim .../boot/wpa_supplicant.conf
