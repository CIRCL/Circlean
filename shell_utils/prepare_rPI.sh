#!/bin/bash

# change locales to en_US.UTF-8
dpkg-reconfigure locales

apt-get update
apt-get dist-upgrade
apt-get autoremove

# enable rc.local
systemctl enable rc-local.service
