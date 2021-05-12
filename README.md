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

# setup k3s
## enable iptables on debian buster (https://rancher.com/docs/k3s/latest/en/advanced/#enabling-legacy-iptables-on-raspbian-buster)
if the current raspian is based on debian bust you have to do the following to enable iptables which is needed for k3s
```
if grep -q buster /etc/os-release; then
    sudo iptables -F
    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
    sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
fi
```
## enable cgroups on debian buster
append `cgroup_memory=1 cgroup_enable=memory` to `/boot/cmdline.txt` to enable cgroups and restart

## install k3s
```
export K3S_KUBECONFIG_MODE="644"

# use MetalLB instead of serviceLB and nginx instead of traefik
export INSTALL_K3S_EXEC=" --disable servicelb --disable traefik"

# get and run install script
curl -sfL https://get.k3s.io | sh -
```
The  k3s config is stored under */etc/rancher/k3s/k3s.yaml*. Download it to your workstation and move it to ~/.kube/config. Now edit the server ip from localhost to the corresponding raspberry ip

## configure system
### kubectl bash completion
```
kubectl completion bash ~/kubectl_completion && sudo mv ~/kubectl_completion /etc/bash_completion.d/kubectl
```
