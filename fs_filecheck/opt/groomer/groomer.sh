#!/bin/bash

# set -e (exit when a line returns non-0 status) and -x (xtrace) flags
set -e
set -x

# Import constants from config file
source ./config.sh

if ! [ "${ID}" -ge "1000" ]; then
    echo "GROOMER: groomer.sh cannot run as root."
    exit
fi

clean(){ 
    # Write anything in memory to disk
    ${SYNC}

    # Remove temporary files from destination key
    rm -rf ${TEMP}
    rm -rf ${ZIPTEMP}
}

trap clean EXIT TERM INT

# Find the partition names on the source device
DEV_PARTITIONS=`ls "${DEV_SRC}"* | grep "${DEV_SRC}[1-9][0-6]*" || true`
if [ -z "${DEV_PARTITIONS}" ]; then
    echo "GROOMER: ${DEV_SRC} does not have any partitions."
    exit
fi

PARTCOUNT=1
for partition in ${DEV_PARTITIONS}
do
    echo "GROOMER: Processing partition ${partition}"
    # Unmount anything that is mounted on /media/src
    if [ `${MOUNT} | grep -c ${SRC}` -ne 0 ]; then
        ${PUMOUNT} ${SRC}
    fi

    # Mount the current partition in write mode
    ${PMOUNT} -w ${partition} ${SRC}
    # Mark any autorun.inf files as dangerous on the source device
    ls ${SRC_MNT} | grep -i autorun.inf | xargs -I {} mv "${SRC_MNT}"/{} "{SRC_MNT}"/DANGEROUS_{}_DANGEROUS || true
    # Unmount and remount the current partition in read-only mode
    ${PUMOUNT} ${SRC}
    ${PMOUNT} -r ${partition} ${SRC}
    if [ ${?} -ne 0 ]; then
        # Previous command (mounting current partition) failed
        echo "GROOMER: Unable to mount ${partition} on /media/${SRC}"
    else
        echo "GROOMER: ${partition} mounted at /media/${SRC}"

        # Put the filenames from the current partition in a logfile
        find "/media/${SRC}" -fls "${LOGS}/contents_partition_${PARTCOUNT}.txt"

        # Create a directory on ${DST} named PARTION_$PARTCOUNT
        target_dir="/media/${DST}/FROM_PARTITION_${PARTCOUNT}"
        mkdir -p "${target_dir}"
        LOGFILE="${LOGS}/processing.txt"

        # Run the current partition through filecheck.py
        echo "==== Starting processing of /media/${SRC} to ${target_dir}. ====" >> ${LOGFILE}
        filecheck.py --source /media/${SRC} --destination ${target_dir} || true
        echo "==== Done with /media/${SRC} to ${target_dir}. ====" >> ${LOGFILE}

        # List destination files (recursively) for debugging
        ls -lR "${target_dir}"
    fi
    let PARTCOUNT=`expr $PARTCOUNT + 1`
done

# The cleanup is automatically done in the function clean called when
# the program exits
