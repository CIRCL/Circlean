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
    #mount -o remount,rw /
    ${SYNC}
}

trap clean EXIT TERM INT

# Remount the root filesystem in RO mode
#mount -o remount,ro /

chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/

su ${USERNAME} -c ./groomer.sh


