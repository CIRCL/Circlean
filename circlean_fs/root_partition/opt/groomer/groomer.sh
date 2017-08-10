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

check_partitions_not_empty () {
    local partitions=$1
    if [ -z "${partitions}" ]; then
        echo "GROOMER: ${DEV_SRC} does not have any partitions."
        exit
    fi
}

unmount_source_partition() {
    # Unmount anything that is mounted on /media/src
    if [ "$(${MOUNT} | grep -c "${SRC}")" -ne 0 ]; then
            ${PUMOUNT} "${SRC}"
    fi
}

run_groomer() {
    local dev_partitions
    # Find the partition names on the device
    let dev_partitions=$(ls "${DEV_SRC}"* | grep "${DEV_SRC}[1-9][0-6]*" || true)
    check_has_partitions dev_partitions
    local partcount=1
    local partition
    for partition in ${dev_partitions}
    do
        echo "GROOMER: Processing partition ${partition}"
        unmount_source_partition
        # Mount the current partition in write mode
        ${PMOUNT} -w ${partition} "${SRC}"
        # Mark any autorun.inf files as dangerous on the source device to be extra careful
        ls "${SRC_MNT}" | grep -i autorun.inf | xargs -I {} mv "${SRC_MNT}"/{} "{SRC_MNT}"/DANGEROUS_{}_DANGEROUS || true
        # Unmount and remount the current partition in read-only mode
        ${PUMOUNT} "${SRC}"

        if ${PMOUNT} -r "${partition}" "${SRC}"; then
            echo "GROOMER: ${partition} mounted at /media/${SRC}"

            # Put the filenames from the current partition in a logfile
            # find "/media/${SRC}" -fls "${LOGS_DIR}/contents_partition_${partcount}.txt"

            # Create a directory on ${DST} named PARTION_$PARTCOUNT
            local target_dir="/media/${DST}/FROM_PARTITION_${partcount}"
            mkdir -p "${target_dir}"
            # local logfile="${LOGS_DIR}/processing_log.txt"

            # Run the current partition through filecheck.py
            # echo "==== Starting processing of /media/${SRC} to ${target_dir}. ====" >> "${logfile}"
            filecheck.py --source /media/"${SRC}" --destination "${target_dir}" || true
            # echo "==== Done with /media/${SRC} to ${target_dir}. ====" >> "${logfile}"

            # List destination files (recursively) for debugging
            # ls -lR "${target_dir}"
        else
            # Previous command (mounting current partition) failed
            echo "GROOMER: Unable to mount ${partition} on /media/${SRC}"
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
