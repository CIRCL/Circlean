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
    echo "GROOMER: cleaning up after init.sh."
    ${SYNC}
    # Stop the music from playing
    kill -9 $(cat /tmp/music.pid)
    rm -f /tmp/music.pid
}

trap clean EXIT TERM INT

# Stop hdmi display from sleeping after a period of time
setterm -powersave off -blank 0

# Start music
./music.sh &
echo $! > /tmp/music.pid

# List block storage devices for debugging
# Make sure to set tee in append (-a) mode below if you uncomment
# lsblk |& tee ${GROOM_LOG}

su ${USERNAME} -c ./mount_dest.sh |& tee ${GROOM_LOG}
