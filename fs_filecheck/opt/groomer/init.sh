#!/bin/bash

set -e
set -x

source ./constraint.sh

if [ ${ID} -ne 0 ]; then
    echo "GROOMER: This script has to be run as root."
    exit
fi

clean(){
    echo "GROOMER: cleaning up after init.sh."
    ${SYNC}
}

trap clean EXIT TERM INT

fdisk -l |& tee ${GROOM_LOG}

su ${USERNAME} -c ./groomer.sh |& tee ${GROOM_LOG}
