#!/bin/bash

# change locales to en_US.UTF-8
dpkg-reconfigure locales

# Increase size of image. See resize_img.md

apt-get update
apt-get dist-upgrade
apt-get autoremove

echo "deb http://ftp.de.debian.org/debian experimental main" >> /etc/apt/sources.list
echo "deb-src http://ftp.de.debian.org/debian experimental main" >> /etc/apt/sources.list
# Force User
su root
gpg --keyserver pgpkeys.mit.edu --recv-key 8B48AD6246925553
gpg -a --export 8B48AD6246925553 | apt-key add -
gpg --keyserver pgpkeys.mit.edu --recv-key AED4B06F473041FA
gpg -a --export AED4B06F473041FA | apt-key add -
apt-get update
# Needed dependencies for building libpoppler
#apt-get install debhelper autotools-dev libglib2.0-dev libgtk2.0-dev libfontconfig1-dev \
#    libqt4-dev libcairo2-dev libopenjpeg-dev libjpeg-dev libpng-dev libtiff-dev \
#    liblcms2-dev gtk-doc-tools libgirepository1.0-dev gobject-introspection libglib2.0-doc \
#    libcairo2-doc
apt-get build-dep poppler

# build dependencies of pdf2htmlEX
apt-get install cmake libfontforge-dev libspiro-dev python-dev

git clone https://github.com/coolwanglu/pdf2htmlEX.git
