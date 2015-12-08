#!/bin/bash

set -e
set -x

source ./constraint.sh

if [ ${ID} -ne 0 ]; then
    echo "This script has to be run as root."
    exit
fi

clean(){
    echo Done, cleaning.
    ${SYNC}
    kill -9 $(cat /tmp/music.pid)
    rm -f /tmp/music.pid
}

trap clean EXIT TERM INT

./music.sh &
echo $! > /tmp/music.pid

su ${USERNAME} -c ./groomer.sh

