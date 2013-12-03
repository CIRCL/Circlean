#!/bin/bash

# change locales to en_US.UTF-8
dpkg-reconfigure locales


apt-get update
apt-get dist-upgrade
apt-get autoremove
apt-get install libreoffice p7zip-full libfontforge1 timidity
dpkg -i libpoppler37*.deb pdf2htmlex*.deb

pushd /home/kitten
ln -s /tmp/libreoffice
popd

chown -R kitten:kitten /home/kitten

rm /etc/mtab
ln -s /proc/mounts /etc/mtab
