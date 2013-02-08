#!/bin/bash

set -e
set -x

#Constraints
DEV_SRC='/dev/sdf'
DEV_DST='/dev/sdg1'
HOME=testing


clean(){
    echo Cleaning.
}

trap clean EXIT TERM INT

# groom da kitteh!

if [ ! -b ${DEV_SRC} ]; then
    echo 'Source device ('${DEV_SRC}') does not exists.'
    exit
fi

DEV_PARTITIONS=`ls ${DEV_SRC}* | grep ${DEV_SRC}'[1-9][0-6]*' || true`
if [ -z ${DEV_PARTITIONS} ]; then
    echo ${DEV_SRC} 'does not have any partitions.'
    exit
fi

if [ ! -b ${DEV_DST} ]; then
    echo 'Destination device ('${DEV_DST}') does not exists.'
    exit
fi


SRC=${HOME}/src
DST=${HOME}/dst

if [ ! -d $SRC ]; then
    mkdir $SRC
fi
if [ ! -d $DST ]; then
    mkdir $DST
fi

if mount|grep $DST; then
    umount $DST || true
fi

TEMP=${DST}/temp
ZIPTEMP=${DST}/ziptemp
FL=${DST}/filelist.txt

mount ${DEV_DST} $DST

if [ $? -ne 0 ]; then
    echo Unable to mount ${DEV_DST} on $DST
    exit 1
else
    echo 'Target USB device ('${DEV_DST}') mounted at $DST'
    rm -rf $DST/FROM_PARTITION_*

    # mount temp and make sure it's empty
    mkdir -p $TEMP
    mkdir -p $ZIPTEMP

    rm -rf ${TEMP}/*
    rm -rf ${ZIPTEMP}/*

    echo Full file list from source USB > $FL
fi

COPYDIRTYPDF=0
PARTCOUNT=1
for partition in $DEV_PARTITIONS
do
    echo Processing partition: ${partition}
    if mount|grep $SRC; then
        umount $SRC 2> /dev/null
    fi

    mount -r $partition $SRC
    if [ $? -ne 0 ]; then
        echo Unable to mount ${partition} on $SRC
    else
        echo $partition mounted at $SRC

        echo PARTITION $PARTCOUNT >> $FL
        # FIXME: eval probably insecure
        find ${SRC}/* -printf 'echo "%p" | sed s:'${SRC}':: >> '${FL}' \n' | \
            while read l; do eval $l; done

        # create a director on sdb named PARTION_n
        targetDir=${DST}/FROM_PARTITION_${PARTCOUNT}
        echo copying to: $targetDir
        mkdir -p $targetDir

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

#cleanup
rm -rf ${TEMP}*
rm -rf ${ZIPTEMP}*
sync
umount $SRC
umount $DST

#/sbin/shutdown -h now

