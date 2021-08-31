# Install *Raspberry Pi OS*
## From a Linux Host
1. Download the most recent arm64 [image](http://downloads.raspberrypi.org/raspios_arm64/images/)
2. connect your micro-sd card and find out its device name `lsblk -p`
3. unzip and write it to the sd-card `unzip -p 2021-03-04-raspios-buster-armhf.zip | sudo dd of=/dev/sdX bs=4M conv=fsync`
4. change the size of the root partition to span over the whole card with: tbd

## From a Windows Host
1. Download the [Raspberry Pi installer](https://www.raspberrypi.org/software/)
2. Select your disti and write it to the sd card


# Configure *Raspberry Pi OS*

## Enable SSH

1. mount the newly created boot-partition and `cd` into it
2. touch .../boot/ssh (windows auto-mounts the *boot* partition)

## Setup WLAN

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
   
## Configure keyboard layout (default=uk) ([Source](https://www.makeuseof.com/change-keyboard-layout-raspberry-pi/))
- by running `sudo raspi-config` ➜ *5 Localisation Options* ➜ *L3 Keyboard* ➜
- or edititing the config file `sudo nano /etc/default/keyboard`
  ```
  XKBMODEL="pc105"
  XKBLAYOUT="us"
  XKBVARIANT="altgr-intl"
  ```
  


## Configure your timezone (default=London)

- by running `sudo raspi-config` ➜ *5 Localisation Options* ➜ *L2 Timezone* ➜ Europe ➜ Berlin
- or by manually linking localtime to your timezone
  ```
  ln --symbolic /usr/share/zoneinfo/Europe/Berlin /etc/localtime
  ```

## Enable Power Button to comfortably Shutdown/Start Pi

Edit the boot file via `sudo vim /boot/config.txt` and append the following line to
enable Shutdown and Startup via a push button on pin 3. ([Source](https://bitreporter.de/raspberrypi/richtiger-an-ausschalter-fur-den-raspberry-pi/#Ein-Ausschalter_in_der_Raspberry_Pi_Firmware_aktivieren))

```
# Enable Shutdown/Start via push button on pin 3
dtoverlay=gpio-shutdown,gpio_pin=3, active_low=1,gpio_pull=up
```

# Setup k3s

## Preparation

- [install options](https://rancher.com/docs/k3s/latest/en/installation/install-options/)
- [advanced options](https://rancher.com/docs/k3s/latest/en/advanced/)

### [enable iptables on debian buster](https://rancher.com/docs/k3s/latest/en/advanced/#enabling-legacy-iptables-on-raspbian-buster)

if the current raspian is based on debian bust you have to do the following to enable iptables which is needed for k3s

```
if grep -q buster /etc/os-release; then
    sudo iptables -F
    sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
    sudo update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
fi
```

### enable cgroups on debian buster

append `cgroup_memory=1 cgroup_enable=memory` to `/boot/cmdline.txt` to enable cgroups and restart

## Install

```
# Define Permissions of kube config file residing in /etc/rancher/k3s/k3s.yaml
export K3S_KUBECONFIG_MODE="644"

# use MetalLB instead of serviceLB and nginx instead of traefik
export INSTALL_K3S_EXEC=" --disable servicelb --disable traefik"

# get and run install script
curl -sfL https://get.k3s.io | sh -
```

### Setup *Kubernetes Dashboard* [OPTIONAL]

[Project-Page](https://github.com/kubernetes/dashboard)

```
VERSION_KUBERNETES_DASHBOARD=v2.3.1
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBERNETES_DASHBOARD}/aio/deploy/recommended.yaml

cat <<EOF > setup_dashboard.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f setup_dashboard.yaml && rm setup_dashboard.yaml

# Get Login-Token
kubectl describe secret --namespace=kubernetes-dashboard admin-user-token | grep token:

# Forward all ports from k3s machine to local
kubectl proxy
# Forward just port 8001 for the dashboard from k3s machine to local
kubectl proxy --port=8001
```

Open the *[Kubernetes Dashboard](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy)* in your local browser and insert the token you obtainer

## Configure Workstation to connect to *k3s*

The  k3s config is stored under */etc/rancher/k3s/k3s.yaml*. Download it to your workstation and move it to ~/.kube/config. Now edit the server ip from localhost to the corresponding raspberry pi ip

### Enable *kubectl* bash completion [OPTIONAL]

```
kubectl completion bash ~/kubectl_completion && sudo mv ~/kubectl_completion /etc/bash_completion.d/kubectl
```

# Uninstall k3s

If something went wrong you can uninstall k3s at any time with a script that gets generated while installing k3s: /usr/local/bin/k3s-uninstall.sh
