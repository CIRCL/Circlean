#!/bin/bash

cd /root/pdf2htmlEX
git pull
dpkg-buildpackage -rfakeroot -uc -b
ls ../*deb
ls /var/cache/apt/archives/libpoppler*

