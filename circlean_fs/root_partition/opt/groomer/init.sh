#!/bin/bash

clean(){
    if [ "${DEBUG}" = true ]; then
        sleep 20
    fi
    echo "GROOMER: cleaning up after init.sh."
    "${SYNC}"
    # Stop the music from playing
    kill -9 "$(cat /tmp/music.pid)"
    rm -f /tmp/music.pid
}

check_is_root() {
    if [ "${ID}" -ne 0 ]; then
        echo "GROOMER: This script has to be run as root."
        exit
    fi
}

start_music() {
    ./music.sh &
    echo $! > /tmp/music.pid
}

run_groomer() {
    if [ "${DEBUG}" = true ]; then
        lsblk |& tee -a "${DEBUG_LOG}"  # list block storage devices for debugging
        su "${USERNAME}" -c ./mount_dest.sh |& tee -a "${DEBUG_LOG}"
    else
        su "${USERNAME}" -c ./mount_dest.sh
    fi
}

main() {
    set -eu  # exit when a line returns non-0 status, treat unset variables as errors
    trap clean EXIT TERM INT  # run clean when the script ends or is interrupted
    check_is_root
    source ./config.sh  # get config values
    if [ "${DEBUG}" = true ]; then
        set -x
    fi
    if [ "${MUSIC}" = true ]; then
        start_music
    fi
    run_groomer
}

main
