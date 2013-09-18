#!/bin/bash

# Force the User
su root

apt-get -b source -t experimental poppler

# Note: libpoppler-private-dev is not listed in the dependencies of pdf2htmlEX
# but still needed because of poppler-config.h
dpkg -i libpoppler-dev* libpoppler37* libpoppler-private-dev*

cd pdf2htmlEX/
git pull

dpkg-buildpackage -uc -b
