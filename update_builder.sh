#!/bin/bash

# Force the User
su root

wget https://github.com/coolwanglu/pdf2htmlEX/archive/v0.11.zip
unzip v0.11.zip

cd pdf2htmlEX-0.11/

dpkg-buildpackage -uc -b
