#!/bin/bash

# set -e (exit when a line returns non-0 status) and -x (xtrace) flags
set -e
set -x

# Import constants from config file
source ./config.sh

if ! [ "${ID}" -ge "1000" ]; then
    echo "GROOMER: mount_keys.sh cannot run as root."
    exit
fi

clean(){
    echo "GROOMER: Cleaning up in mount_keys.sh."

    # Copy the temporary logfile to the destination key
    cp ${GROOM_LOG} "${DST_MNT}/groomer_log_dst.txt"

    # Write anything in memory to disk
    ${SYNC}

    # Unmount source and destination
    pumount ${SRC}

    # Clean up and unmount destination
    pumount ${DST}

    exit
}

trap clean EXIT TERM INT

# Check that a device is available on /dev/source_key (symlinked to /dev/sda or sdb)
if [ ! -b ${DEV_SRC} ]; then
    echo "GROOMER: Source device (${DEV_SRC}) does not exist."
    exit
fi

# Check that a device is available on /dev/dest_key (symlinked to /dev/sda or sdb)
if [ ! -b ${DEV_DST} ]; then
    echo "GROOMER: Destination device (${DEV_DST}) does not exist."
    exit
fi

# If there is already a device mounted on /media/dst, unmount it
if ${MOUNT}|grep ${DST}; then
    ${PUMOUNT} ${DST} || true
fi

# uid= only works on a vfat FS. What should wedo if we get an ext* FS ?
# What does this ^ comment mean?

# Mount the first partition of DST (/dev/dest_key1)
# pmount automatically mounts on /media/ (at /media/dst in this case).
${PMOUNT} -w "${DEV_DST}1" ${DST}
if [ ${?} -ne 0 ]; then
    echo "GROOMER: Unable to mount ${DEV_DST}1 on ${DST_MNT}"
    exit
else
    echo "GROOMER: Destination USB device (${DEV_DST}1) mounted at ${DST_MNT}"

    # Remove any existing "FROM_PARTITION_" directories
    rm -rf "/media/${DST}/FROM_PARTITION_"*

    # Prepare temp dirs and make sure they're empty if they already exist
    mkdir -p "${TEMP}"
    mkdir -p "${ZIPTEMP}"
    mkdir -p "${LOGS}"
    rm -rf "${TEMP}/"*
    rm -rf "${ZIPTEMP}/"*
    rm -rf "${LOGS}/"*
fi

# Now that destination is mounted and prepared, run the groomer
./groomer.sh
