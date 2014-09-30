#!/bin/bash

# We cannot use the version 0.12 because it requires fontforge 2.0
# The fork use a saner list of dependencies and a patch that allows to build on debian jessie.

wget https://github.com/Rafiot/pdf2htmlEX/archive/KittenGroomer.zip
unzip KittenGroomer.zip

cd pdf2htmlEX-KittenGroomer/

dpkg-buildpackage -uc -b
