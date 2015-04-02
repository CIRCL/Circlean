#!/bin/bash

set -e
set -x

source ./constraint.sh
if ! [ "${ID}" -ge "1000" ]; then
    echo "This script cannot run as root."
    exit
fi

source ./functions.sh

clean(){
    echo Cleaning.
    ${SYNC}

    # Cleanup source
    pumount ${SRC}

    # Cleanup destination
    rm -rf ${TEMP}
    rm -rf ${ZIPTEMP}
    pumount ${DST}

    exit
}

trap clean EXIT TERM INT

# De we have a source device
if [ ! -b ${DEV_SRC} ]; then
    echo "Source device (${DEV_SRC}) does not exists."
    exit
fi
# Find the partition names on the source device
DEV_PARTITIONS=`ls "${DEV_SRC}"* | grep "${DEV_SRC}[1-9][0-6]*" || true`
if [ -z "${DEV_PARTITIONS}" ]; then
    echo "${DEV_SRC} does not have any partitions."
    exit
fi

# Do we have a destination device
if [ ! -b "/dev/${DEV_DST}" ]; then
    echo "Destination device (/dev/${DEV_DST}) does not exists."
    exit
fi

# mount and prepare destination device
if ${MOUNT}|grep ${DST}; then
    ${PUMOUNT} ${DST} || true
fi
# uid= only works on a vfat FS. What should wedo if we get an ext* FS ?
${PMOUNT} -w ${DEV_DST} ${DST}
if [ ${?} -ne 0 ]; then
    echo "Unable to mount /dev/${DEV_DST} on /media/${DST}"
    exit
else
    echo "Target USB device (/dev/${DEV_DST}) mounted at /media/${DST}"
    rm -rf "/media/${DST}/FROM_PARTITION_"*

    # prepare temp dirs and make sure it's empty
    mkdir -p "${TEMP}"
    mkdir -p "${ZIPTEMP}"
    mkdir -p "${LOGS}"

    rm -rf "${TEMP}/"*
    rm -rf "${ZIPTEMP}/"*
    rm -rf "${LOGS}/"*
fi

# Groom da kitteh!

# Find the FS types
# lsblk -n -o name,fstype,mountpoint,label,uuid -r

PARTCOUNT=1
for partition in ${DEV_PARTITIONS}
do
    # Processing a partition
    echo "Processing partition: ${partition}"
    if [ `${MOUNT} | grep -c ${SRC}` -ne 0 ]; then
        ${PUMOUNT} ${SRC}
    fi

    ${PMOUNT} -w ${partition} ${SRC}
    ls "/media/${SRC}" | grep -i autorun.inf | xargs -I {} mv "/media/${SRC}"/{} "/media/${SRC}"/DANGEROUS_{}_DANGEROUS || true
    ${PUMOUNT} ${SRC}
    ${PMOUNT} -r ${partition} ${SRC}
    if [ ${?} -ne 0 ]; then
        echo "Unable to mount ${partition} on /media/${SRC}"
    else
        echo "${partition} mounted at /media/${SRC}"

        # Print the filenames on the current partition in a logfile
        find "/media/${SRC}" -fls "${LOGS}/Content_partition_${PARTCOUNT}.txt"

        # create a directory on ${DST} named PARTION_$PARTCOUNT
        target_dir="/media/${DST}/FROM_PARTITION_${PARTCOUNT}"
        echo "copying to: ${target_dir}"
        mkdir -p "${target_dir}"
        LOGFILE="${LOGS}/processing.txt"

        echo "==== Starting processing of /media/${SRC} to ${target_dir}. ====" >> ${LOGFILE}
        main ${target_dir} || true
        echo "==== Done with /media/${SRC} to ${target_dir}. ====" >> ${LOGFILE}

        ls -lR "${target_dir}"
    fi
    let PARTCOUNT=`expr $PARTCOUNT + 1`
done

# The cleanup is automatically done in the function clean called when
# the program quits
