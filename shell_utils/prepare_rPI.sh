#!/bin/bash

# change locales to en_US.UTF-8
dpkg-reconfigure locales

sed -i "s/wheezy/jessie/" /etc/apt/sources.list
apt-get update
apt-get dist-upgrade
apt-get autoremove
apt-get install libreoffice p7zip-full libfontforge1 timidity freepats pmount
dpkg -i pdf2htmlex*.deb

# Disable swap
dphys-swapfile uninstall

# enable rc.local
systemctl enable rc-local.service
