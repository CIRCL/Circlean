#!/bin/bash

# change locales to en_US.UTF-8
dpkg-reconfigure locales

# Increase size of image. See resize_img.md

apt-get update
apt-get dist-upgrade
apt-get autoremove

# build dependencies of pdf2htmlEX
apt-get install cmake debhelper libpoppler-dev libjpeg-dev libfontforge-dev \
    libspiro-dev python-dev default-jre-headless libpoppler-private-dev
