#!/bin/bash

set -e
set -x

#Constraints
DEV_SRC='/dev/sdf'
DEV_DST='/dev/sdg1'
HOME=testing
############


SRC=${HOME}/src
DST=${HOME}/dst

TEMP=${DST}/temp
ZIPTEMP=${DST}/ziptemp
LOGS=${DST}/logs


clean(){
    echo Cleaning.
    sync

    # Cleanup source
    umount $SRC
    rm -rf $SRC

    # Cleanup destination
    rm -rf ${TEMP}
    rm -rf ${ZIPTEMP}
    umount $DST
    rm -rf $DST

    # Only if running on a rPi
    #/sbin/shutdown -h now
}

trap clean EXIT TERM INT

# De we have a source device
if [ ! -b ${DEV_SRC} ]; then
    echo 'Source device ('${DEV_SRC}') does not exists.'
    exit
fi
# Find the partition names on the source device
DEV_PARTITIONS=`ls ${DEV_SRC}* | grep ${DEV_SRC}'[1-9][0-6]*' || true`
if [ -z ${DEV_PARTITIONS} ]; then
    echo ${DEV_SRC} 'does not have any partitions.'
    exit
fi

# Do we have a destination device
if [ ! -b ${DEV_DST} ]; then
    echo 'Destination device ('${DEV_DST}') does not exists.'
    exit
fi

# Prepare mount points
if [ ! -d $SRC ]; then
    mkdir $SRC
fi
if [ ! -d $DST ]; then
    mkdir $DST
fi

# Mount and prepare destination device
if mount|grep $DST; then
    umount $DST || true
fi
mount -o noexec ${DEV_DST} ${DST}
if [ $? -ne 0 ]; then
    echo Unable to mount ${DEV_DST} on ${DST}
    exit
else
    echo 'Target USB device ('${DEV_DST}') mounted at '${DST}
    rm -rf ${DST}/FROM_PARTITION_*

    # mount temp and make sure it's empty
    mkdir -p ${TEMP}
    mkdir -p ${ZIPTEMP}
    mkdir -p ${LOGS}

    rm -rf ${TEMP}/*
    rm -rf ${ZIPTEMP}/*
    rm -rf ${LOGS}/*
fi

# Groom da kitteh!

COPYDIRTYPDF=0
PARTCOUNT=1
for partition in ${DEV_PARTITIONS}
do
    # Processing a partition
    echo Processing partition: ${partition}
    if mount|grep $SRC; then
        umount $SRC
    fi

    mount -o noexec -r $partition $SRC
    if [ $? -ne 0 ]; then
        echo Unable to mount ${partition} on $SRC
    else
        echo $partition mounted at $SRC

        # Print the filenames on the current partition in a logfile
        find ${SRC}/* -fls ${LOGS}/${PARTCOUNT}

        # create a directory on $DST named PARTION_$PARTCOUNT
        targetDir=${DST}/FROM_PARTITION_${PARTCOUNT}
        echo copying to: $target_dir
        mkdir -p $target_dir

        #if [ $COPYDIRTYPDF -eq 1 ]; then
        #    pdfCopyDirty $SRC $targetDir
        #else
        #    pdfCopyClean $SRC $targetDir
        #fi

        # copy stuff
        #copySafeFiles $SRC $targetDir
        #convertCopyFiles $SRC $targetDir $TEMP
        #rm -rf ${TEMP}/*

        # unpack and process archives
        #unpackZip $SRC $targetDir $TEMP
    fi
    let PARTCOUNT=$PARTCOUNT+1
done

# The cleanup is automatically done in the finction clean called when
# the program quits
