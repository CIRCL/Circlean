#!/bin/bash

clean(){
    if [ "${DEBUG}" = true ]; then
        sleep 20
    fi

    # Write anything in memory to disk
    ${SYNC}

    # Remove temporary files from destination key
    rm -rf "${TEMP}"
}

check_not_root() {
    if ! [ "${ID}" -ge "1000" ]; then
        echo "GROOMER: groomer.sh cannot run as root."
        exit
    fi
}

check_has_partitions () {
    local partitions=$1
    if [ -z "${partitions}" ]; then
        echo "GROOMER: ${SRC_DEV} does not have any partitions."
        exit
    fi
}

run_groomer() {
    local dev_partitions
    # Find the partition names on the device
    dev_partitions=$(ls "${SRC_DEV}"* | grep "${SRC_DEV}[1-9][0-6]*" || true)
    check_has_partitions dev_partitions
    local partcount=1
    local partition
    for partition in ${dev_partitions}
    do
        echo "GROOMER: Processing partition ${partition}"
        # Mount the current partition in write mode
        SRC_MNT=`${MOUNT} -o rw -b ${partition}| sed -ne 's/Mounted \(.*\) at \(\/media\/kitten\/.*\).$/\2/p'`
        if [ -z "$SRC_MNT" ]; then
            echo "Unable to mount source partition (${partition})."
            continue
        fi
        # Mark any autorun.inf files as dangerous on the source device to be extra careful
        ls "${SRC_MNT}" | grep -i autorun.inf | xargs -I {} mv "${SRC_MNT}"/{} "${SRC_MNT}"/DANGEROUS_{}_DANGEROUS || true
        # Unmount and remount the current partition in read-only mode
        ${UMOUNT} -b "${partition}"

        if ${MOUNT} -o ro -b "${partition}"; then
            echo "GROOMER: ${partition} mounted at ${SRC_MNT}"

            # Create a directory on ${DST_MNT} named PARTION_$PARTCOUNT
            local target_dir="${DST_MNT}/FROM_PARTITION_${partcount}"
            mkdir -p "${target_dir}"

            # Run the current partition through filecheck.py
            filecheck.py --source "${SRC_MNT}" --destination "${target_dir}" || true

            # List destination files (recursively) for debugging
            if [ "${DEBUG}" = true ]; then
                ls -lR "${target_dir}"
            fi
            ${UMOUNT} -b "${partition}"
        else
            # Previous command (mounting current partition) failed
            echo "GROOMER: Unable to mount ${partition} on ${SRC_MNT}"
        fi
        let partcount=$((partcount + 1))
    done
}

main() {
    set -eu  # exit when a line returns non-0 status, treat unset variables as errors
    trap clean EXIT TERM INT  # run clean when the script ends or is interrupted
    source ./config.sh  # get config values
    if [ "${DEBUG}" = true ]; then
        set -x
    fi
    run_groomer
}

main
