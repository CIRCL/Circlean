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
    kill -9 $(cat /tmp/music.pid)
    rm -f /tmp/music.pid
}

trap clean EXIT TERM INT

./music.sh &
echo $! > /tmp/music.pid
echo "GROOMER: music started."

su ${USERNAME} -c ./groomer.sh | tee ${GROOM_LOG}
