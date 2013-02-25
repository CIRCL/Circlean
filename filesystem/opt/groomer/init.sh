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
    # Only if running on a rPi
    # mount -o remount,rw /
    ${SYNC}
    # shutdown -h now
}

trap clean EXIT TERM INT

# Remount the root filesystem in RO mode
# mount -o remount,ro /

su  ${USERNAME} -c ./groomer.sh


