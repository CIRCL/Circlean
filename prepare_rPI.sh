#!/bin/bash

# change locales to en_US.UTF-8
dpkg-reconfigure locales


apt-get update
apt-get dist-upgrade
apt-get autoremove
apt-get install libreoffice p7zip-full libfontforge1
dpkg -i libpoppler28*.deb pdf2htmlex*.deb

chown -R kitten:kitten /home/kitten
