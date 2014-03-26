#!/bin/bash

# change locales to en_US.UTF-8
dpkg-reconfigure locales


apt-get update
apt-get dist-upgrade
apt-get autoremove
apt-get install libreoffice p7zip-full libfontforge1 timidity
dpkg -i --ignore-depends=libpoppler27 pdf2htmlex*.deb

# Make Libreoffice usable on a RO filesystem
pushd /home/kitten
ln -s /tmp/libreoffice
popd

chown -R kitten:kitten /home/kitten

ln -s /proc/mounts /etc/mtab

# Disable swap
dphys-swapfile uninstall
