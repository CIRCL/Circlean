#!/bin/bash

clean(){
        if [ "${DEBUG}" = true ]; then
            sleep 20
            # Copy the temporary logfile to the destination key
            cp "${DEBUG_LOG}" "${DST_MNT}/groomer_debug_log.txt"
        fi
        echo "GROOMER: Cleaning up in mount_keys.sh."
        rm -rf "${DST_MNT}/IN_PROGRESS.txt"*
        ${SYNC}  # Write anything in memory to disk
        # Unmount source and destination
        pumount "${SRC_MNT}"
        pumount "${DST_MNT}"
        exit
}

check_not_root() {
    if ! [ "${ID}" -ge "1000" ]; then
        echo "GROOMER: mount_keys.sh cannot run as root."
        exit
    fi
}

check_source_exists() {
    if [ ! -b "${SRC_DEV}" ]; then
        echo "GROOMER: Source device (${SRC_DEV}) does not exist."
        exit
    fi
}

check_dest_exists() {
    if [ ! -b "${DST_DEV}" ]; then
        echo "GROOMER: Destination device (${DST_DEV}) does not exist."
        exit
    fi
}

unmount_dest_if_mounted() {
    if ${MOUNT}|grep "${DST_MNT}"; then
        ${PUMOUNT} "${DST_MNT}" || true
    fi
}

mount_dest_partition() {
    if ${PMOUNT} -w "${DST_DEV}1" "${DST_MNT}"; then  # pmount automatically mounts on /media/ (at /media/dst in this case).
        echo "GROOMER: Destination USB device (${DST_DEV}1) mounted at ${DST_MNT}"
    else
        echo "GROOMER: Unable to mount ${DST_DEV}1 on ${DST_MNT}"
        exit
    fi
}

copy_in_progress_file() {
    cp "/opt/groomer/IN_PROGRESS.txt" "${DST_MNT}/IN_PROGRESS.txt"
}

prepare_dest_partition() {
    rm -rf "${DST_MNT}/FROM_PARTITION_"*  # Remove any existing "FROM_PARTITION_" directories
    # Prepare temp dir and make sure it's empty if it already exists:
    mkdir -p "${TEMP}"
    rm -rf "${TEMP:?}/"*
}

main() {
    set -eu  # exit when a line returns non-0 status, treat unset variables as errors
    trap clean EXIT TERM INT  # run clean when the script ends or is interrupted
    source ./config.sh  # get config values
    if [ "${DEBUG}" = true ]; then
        set -x
    fi
    check_not_root
    check_source_exists
    check_dest_exists
    unmount_dest_if_mounted
    mount_dest_partition
    copy_in_progress_file
    prepare_dest_partition
    ./groomer.sh
}

main
