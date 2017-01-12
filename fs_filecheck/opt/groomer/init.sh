#!/bin/bash

# set -e (exit when a line returns non-0 status) and -x (xtrace) flags
set -e
set -x

source ./config.sh

if [ ${ID} -ne 0 ]; then
    echo "GROOMER: This script has to be run as root."
    exit
fi

clean(){
    echo "GROOMER: cleaning up after init.sh."
    ${SYNC}
}

trap clean EXIT TERM INT

lsblk -n -o name,fstype,mountpoint,label,uuid -r |& tee ${GROOM_LOG}

sleep 30

su ${USERNAME} -c ./groomer.sh |& tee -a ${GROOM_LOG}
