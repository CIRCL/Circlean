#!/bin/bash

# set -e (exit when a line returns non-0 status) and -x (xtrace) flags
set -e
set -x

# Import constants from config file
source ./config.sh

if [ ${ID} -ne 0 ]; then
    echo "GROOMER: This script has to be run as root."
    exit
fi

clean(){
    if [ ${DEBUG} = true ]; then
        sleep 20
    fi
    echo "GROOMER: cleaning up after init.sh."
    ${SYNC}
    # Stop the music from playing
    kill -9 $(cat /tmp/music.pid)
    rm -f /tmp/music.pid
}

trap clean EXIT TERM INT

# Start music
./music.sh &
echo $! > /tmp/music.pid

# List block storage devices for debugging
if [ ${DEBUG} = true ]; then
    lsblk |& tee -a ${DEBUG_LOG}
fi

su ${USERNAME} -c ./mount_dest.sh |& tee -a ${DEBUG_LOG}
