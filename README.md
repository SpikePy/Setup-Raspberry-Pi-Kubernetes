# pi4_setup
1. Download the most recent arm64 [image](http://downloads.raspberrypi.org/raspios_arm64/images/)
2. connect your micro-sd card and find out its device name `lsblk -p`
3. unzip and write it to the sd-card `unzip -p 2021-03-04-raspios-buster-armhf.zip | sudo dd of=/dev/sdX bs=4M conv=fsync`
4. change the size of the root partition to span over the whole card with: tbd
5. enable ssh
    1. mount the newly created boot-partition and `cd` into it
    2. touch .../boot/ssh
6. setup WLAN
    1. mount the newly created boot-partition and `cd` into it
    2. vim .../boot/wpa_supplicant.conf
    ```
    country=DE
    ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
    update_config=1
    
    network={
        ssid="$SSID"
        psk="$KEY"
    }
    ```

# install k3s
## enable iptables on debian buster
if the current raspian is based on debian bust you have to do the following to enable iptables which is needed for k3s
```
if grep -q buster /etc/os-release; then
    sudo iptables -F
    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
    sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
    sudo reboot
fi
```
