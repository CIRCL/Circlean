#!/bin/bash


# change locales to en_US.UTF-8
dpkg-reconfigure locales

apt-get update
apt-get dist-upgrade
apt-get autoremove
# System stuff to build
apt-get install git devscripts cmake debhelper
# Deps of pdf2htmlEX
echo "deb http://ftp.de.debian.org/debian experimental" >> /etc/apt/sources.list
apt-get update
apt-get install libfontforge-dev libpng12-dev libspiro-dev python-dev
apt-get install -t experimental libpoppler-dev libpoppler-private-dev

cd /root
git clone https://github.com/coolwanglu/pdf2htmlEX.git
