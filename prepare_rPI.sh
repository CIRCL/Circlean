#!/bin/bash

# change locales to en_US.UTF-8
dpkg-reconfigure locales


apt-get update
apt-get dist-upgrade
apt-get autoremove
apt-get install libreoffice libfontforge1 p7zip-full
dpkg -i libpoppler28_0.20.5-3_armhf.deb pdf2htmlex_0.8-1~git201303011406r3bc73-0ubuntu1_armhf.deb

