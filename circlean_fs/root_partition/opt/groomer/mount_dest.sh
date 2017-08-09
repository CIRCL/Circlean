#!/bin/bash

clean(){
        if [ "${DEBUG}" = true ]; then
            sleep 20
            # Copy the temporary logfile to the destination key
            cp "${DEBUG_LOG}" "${DST_MNT}/groomer_debug_log.txt"
        fi
        echo "GROOMER: Cleaning up in mount_keys.sh."
        ${SYNC}  # Write anything in memory to disk
        # Unmount source and destination
        pumount "${SRC}"
        pumount "${DST}"
        exit
    }

check_not_root() {
    if ! [ "${ID}" -ge "1000" ]; then
        echo "GROOMER: mount_keys.sh cannot run as root."
        exit
    fi
}

check_source_exists() {
    if [ ! -b "${DEV_SRC}" ]; then
        echo "GROOMER: Source device (${DEV_SRC}) does not exist."
        exit
    fi
}

check_dest_exists() {
    if [ ! -b "${DEV_DST}" ]; then
        echo "GROOMER: Destination device (${DEV_DST}) does not exist."
        exit
    fi
}

unmount_dest_if_mounted() {
    if ${MOUNT}|grep "${DST}"; then
        ${PUMOUNT} "${DST}" || true
    fi
}

mount_dest_partition() {
    if "${PMOUNT}" -w "${DEV_DST}1" "${DST}"; then  # pmount automatically mounts on /media/ (at /media/dst in this case).
        echo "GROOMER: Destination USB device (${DEV_DST}1) mounted at ${DST_MNT}"
    else
        echo "GROOMER: Unable to mount ${DEV_DST}1 on ${DST_MNT}"
        exit
    fi
}

prepare_dest_partition() {
    rm -rf "/media/${DST}/FROM_PARTITION_"*  # Remove any existing "FROM_PARTITION_" directories
    # Prepare temp dirs and make sure they're empty if they already exist
    mkdir -p "${TEMP}"
    mkdir -p "${LOGS}"
    rm -rf "${TEMP:?}/"*
    rm -rf "${LOGS:?}/"*
}

main() {
    set -eu  # exit when a line returns non-0 status, treat unset variables as errors
    trap clean EXIT TERM INT
    set -x
    source ./config.sh
    check_not_root
    check_source_exists
    check_dest_exists
    unmount_dest_if_mounted
    mount_dest_partition
    prepare_dest_partition
    ./groomer.sh
}

main