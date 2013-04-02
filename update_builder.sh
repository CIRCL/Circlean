#!/bin/bash

# get sources of latest libpoppler from experimental in the debian packages
# Unpack the sources
# unpack the the debian patches in the dir of the sources
# let the dsc file outside of this directory
# Build package
# Take a nap

cd /root/pdf2htmlEX
git pull
dpkg-buildpackage -rfakeroot -uc -b
ls ../*deb
ls /var/cache/apt/archives/libpoppler*

# Copy libpoppler and pdf2htmlex deb out of the chroot.

