#!/bin/bash

apt-get update
apt-get dist-upgrade
apt-get autoremove
apt-get install libreoffice
dpkg -i libpoppler28_0.20.5-3_armhf.deb libpoppler-private-dev_0.20.5-3_armhf.deb \
    pdf2htmlex_0.8-1~git201303011406r3bc73-0ubuntu1_armhf.deb

