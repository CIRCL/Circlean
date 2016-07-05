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

# Dumb libreoffice wants to write into ~/libreoffice or crash with
# com::sun::star::uno::RuntimeException
mkdir /tmp/libreoffice
chown -R kitten:kitten /tmp/libreoffice
# Avoid:
# Failed to connect to /usr/lib/libreoffice/program/soffice.bin (pid=2455) in 6 seconds.
# Connector : couldn't connect to socket (Success)
# Error: Unable to connect or start own listener. Aborting.
mkdir /tmp/libreoffice_config
chown -R kitten:kitten /tmp/libreoffice_config

# Reject all network connexions.
iptables -F
iptables -A INPUT -j REJECT
iptables -A OUTPUT -j REJECT
iptables -A FORWARD -j REJECT

su ${USERNAME} -c ./groomer.sh

