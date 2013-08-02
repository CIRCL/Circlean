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

su ${USERNAME} -c ./groomer.sh


