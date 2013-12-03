#!/bin/bash

set -e
#set -x

source ./constraint.sh

if [ ${ID} -ne 0 ]; then
    echo "This script has to be run as root."
    exit
fi

clean(){
    echo Done, cleaning.
    ${SYNC}
}

trap clean EXIT TERM INT

./music.sh &

# Dumb libreoffice wants to write into ~/libreoffice or crash with
# com::sun::star::uno::RuntimeException
mkdir /tmp/libreoffice
chown -R kitten:kitten /tmp/libreoffice

su ${USERNAME} -c ./groomer.sh


