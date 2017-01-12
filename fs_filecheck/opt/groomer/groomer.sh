#!/bin/bash

# set -e (exit when a line returns non-0 status) and -x (xtrace) flags
set -e
set -x

source ./config.sh

if ! [ "${ID}" -ge "1000" ]; then
    echo "GROOMER: This script cannot run as root."
    exit
fi

clean(){
    echo "GROOMER: Cleaning up after groomer.sh."

    cp ${GROOM_LOG} "${DST_MNT}/groomer_log_dst.txt"
    cp ${GROOM_LOG} "${SRC_MNT}/groomer_log_src.txt"
 
    # Write anything in memory to disk
    ${SYNC}

    # Unmount source
    pumount ${SRC}

    # Clean up and unmount destination
    rm -rf ${TEMP}
    rm -rf ${ZIPTEMP}
    pumount ${DST}

    exit
}

trap clean EXIT TERM INT

# De we have a source device?
if [ ! -b ${DEV_SRC} ]; then
    echo "GROOMER: Source device (${DEV_SRC}) does not exist."
    exit
fi

# Do we have a destination device
if [ ! -b ${DEV_DST} ]; then
    echo "GROOMER: Destination device (${DEV_DST}) does not exist."
    exit
fi

# Make sure destination device isn't already mounted
if ${MOUNT}|grep ${DST}; then
    ${PUMOUNT} ${DST} || true
fi

# uid= only works on a vfat FS. What should wedo if we get an ext* FS ?
# What does this ^ comment mean?

# Mount the first partition of DST (/dev/sdb1)
# pmount automatically mount on /media/, so at /media/dst in this case
${PMOUNT} -w ${DEV_DST_ONE} ${DST}
if [ ${?} -ne 0 ]; then
    echo "GROOMER: Unable to mount ${DEV_DST_ONE} on ${DST_MNT}"
    exit
else
    echo "GROOMER: Destination USB device (${DEV_DST_ONE}) mounted at ${DST_MNT}"

    # Remove any existing "FROM_PARTITION_" directories
    rm -rf "/media/${DST}/FROM_PARTITION_"*

    # prepare temp dirs and make sure they're empty if they already exist
    mkdir -p "${TEMP}"
    mkdir -p "${ZIPTEMP}"
    mkdir -p "${LOGS}"
    rm -rf "${TEMP}/"*
    rm -rf "${ZIPTEMP}/"*
    rm -rf "${LOGS}/"*
fi

sleep 30

${PMOUNT} -w ${DEV_SRC_ONE} ${SRC}

sleep 10

# Groom da kitteh!

# List all block devices (uncomment for diagnostics)
# lsblk -n -o name,fstype,mountpoint,label,uuid -r

# Find the partition names on the source device
DEV_PARTITIONS=`ls "${DEV_SRC}"* | grep "${DEV_SRC}[1-9][0-6]*" || true`
if [ -z "${DEV_PARTITIONS}" ]; then
    echo "GROOMER: ${DEV_SRC} does not have any partitions."
    exit
fi

sleep 10
# PARTCOUNT=1
# for partition in ${DEV_PARTITIONS}
# do
#     # Processing a partition
#     echo "GROOMER: Processing partition ${partition}"
#     if [ `${MOUNT} | grep -c ${SRC}` -ne 0 ]; then
#         ${PUMOUNT} ${SRC}
#     fi

#     ${PMOUNT} -w ${partition} ${SRC}
#     ls "/media/${SRC}" | grep -i autorun.inf | xargs -I {} mv "/media/${SRC}"/{} "/media/${SRC}"/DANGEROUS_{}_DANGEROUS || true
#     ${PUMOUNT} ${SRC}
#     ${PMOUNT} -r ${partition} ${SRC}
#     if [ ${?} -ne 0 ]; then
#         echo "GROOMER: Unable to mount ${partition} on /media/${SRC}"
#     else
#         echo "GROOMER: ${partition} mounted at /media/${SRC}"

#         # Print the filenames on the current partition in a logfile
#         find "/media/${SRC}" -fls "${LOGS}/Content_partition_${PARTCOUNT}.txt"

#         # create a directory on ${DST} named PARTION_$PARTCOUNT
#         target_dir="/media/${DST}/FROM_PARTITION_${PARTCOUNT}"
#         echo "GROOMER: Copying to ${target_dir}"
#         mkdir -p "${target_dir}"
#         LOGFILE="${LOGS}/processing.txt"

#         echo "GROOMER: ==== Starting processing of /media/${SRC} to ${target_dir}. ====" >> ${LOGFILE}
#         filecheck.py --source /media/${SRC} --destination ${target_dir} || true
#         echo "GROOMER: ==== Done with /media/${SRC} to ${target_dir}. ====" >> ${LOGFILE}

#         ls -lR "${target_dir}"
#     fi
#     let PARTCOUNT=`expr $PARTCOUNT + 1`
# done

# The cleanup is automatically done in the function clean called when
# the program quits
