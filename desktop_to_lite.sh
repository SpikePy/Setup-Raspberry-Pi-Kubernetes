#!/bin/dash

##################################################################################
#                                                                                #
# Make raspian desktop varian (only variant available for arm64) to lite variant #
#                                                                                #
##################################################################################

sudo apt update
sudo apt purge -y x11-common bluez gnome-menus gnome-icon-theme gnome-themes-standard
sudo apt purge -y hicolor-icon-theme gnome-themes-extra-data bluealsa cifs-utils
sudo apt purge -y desktop-base desktop-file-utils
sudo apt autoremove -y
sudo apt autoclean
