#!/bin/bash

# groom da kitteh!

GH=/opt/groomer/
JAVA=/usr/bin/java

pdfCopyDirty()
{
    # copy all pdf's over to their relative same locations
    find $1 -iname "*.pdf" -printf 'X=`echo %h | sed -f $GH/sedKillSpace -e s:${1}::`; mkdir -p ${2}${X}; F=`echo %f | sed -f $GH/sedKillSpace`; cp -fv "%p" ${2}$X/$F \n' | while read l; do eval $l; done
    # extract all the txt we can from potentially evil pdf's
    find $2 -iname "*.pdf" -printf 'echo %p extracting text to %p-extracted.txt; $JAVA -jar $GH/pdfbox-app-1.7.1.jar ExtractText %p %p-extracted.txt 2> /dev/null \n' | while read l; do eval $l; done
}

pdfCopyClean()
{
    # convert pdf's on the fly from src to relative dst location
    find $1 -iname "*.pdf" -printf 'X=`echo %h | sed -f $GH/sedKillSpace -e s:${1}::`; mkdir -p ${2}${X}; F=`echo %f | sed -f $GH/sedKillSpace`; echo "%p" extracting text to ${2}$X/$F-extracted.txt; $JAVA -jar $GH/pdfbox-app-1.7.1.jar ExtractText "%p" ${2}$X/$F-extracted.txt 2> /dev/null \n' | while read l; do eval $l; done
}

copySafeFiles()
{
    TYPES="\
           jpg jpeg gif png tif tga raw \
	   mp4 avi mov \
	   mp3 wav \
           txt xml csv tsv \
	  "
    for type in $TYPES
    do
	find $1 -iname "*.$type" -printf 'X=`echo %h | sed -f $GH/sedKillSpace -e s:${1}::`; mkdir -p ${2}${X}; F=`echo %f | sed -f $GH/sedKillSpace`; cp -fv "%p" ${2}$X/$F \n' | while read l; do eval $l; done
    done
}

convertCopyFiles()
{
    # wordy documents
    TYPES="doc docx odt sxw rtf wpd htm html"
    FILTER=Text; OUT=txt
    convertCopyFilesHelper $1 $2 $3 $TYPES $OUT $FILTER 

    # spreadsheets
    TYPES="xls xslx ods sxc" 
    FILTER=calc_pdf_Export; OUT=pdf
    convertCopyFilesHelper $1 $2 $3 $TYPES $OUT $FILTER 

    # presentation files
    TYPES="ppt pptx odp sxi"
    FILTER=impress_pdf_Export; OUT=pdf
    convertCopyFilesHelper $1 $2 $3 $TYPES $OUT $FILTER 
}
convertCopyFilesHelper()
{
    for type in $TYPES
    do
	find $1 -iname "*.$type" -printf 'X=`echo %h | sed -f $GH/sedKillSpace -e s:${1}::`; mkdir -p ${3}${X}; F=`echo %f | sed -f $GH/sedKillSpace`; cp -fv "%p" ${3}$X/$F \n' | while read l; do eval $l; done
	find $3 -iname "*.$type" -printf 'X=`echo %h | sed s:${3}::`; mkdir -p ${2}${X}; soffice --headless --convert-to ${type}-extraced.$OUT:$FILTER %p --outdir ${2}${X} \n' | while read l; do eval $l; done
    done
}

unpackZip()
{
    find $1 -iname "*.zip" -printf 'X=`echo %h | sed -f $GH/sedKillSpace -e s:${1}::`; mkdir -p ${3}${X}; F=`echo %f | sed -f $GH/sedKillSpace`; cp -fv "%p" ${3}$X/$F \n' | while read l; do eval $l; done
    find $3 -iname "*.zip" -printf 'X=`echo %h | sed s:${3}::`; mkdir -p ${ZIPTEMP}/${X}/UNZIPPED_%f/; unzip "%p" -d ${ZIPTEMP}${X}/UNZIPPED_%f/ 2> /dev/null; \n' | while read l; do eval $l; done
    find $3 -iname "*.zip" -printf 'rm -rf %p \n' | while read l; do eval $l; done

    if [ -d ${ZIPTEMP} ]; then
	if [ $COPYDIRTYPDF -eq 1 ]; then
	    pdfCopyDirty $ZIPTEMP $targetDir
	else
	    pdfCopyClean $ZIPTEMP $targetDir
	fi
	copySafeFiles $ZIPTEMP $2 $3
	convertCopyFiles $ZIPTEMP $2 $3
	rm -rf ${TEMP}/*
	rm -rf ${ZIPTEMP}/*
    fi
}

SRC=/src
DST=/dst
if [ ! -d $SRC ]; then
    mkdir $SRC
fi
if [ ! -d $DST ]; then
    mkdir $DST
fi

TEMP=/dst/temp
ZIPTEMP=/dst/ziptemp
FL=${DST}/filelist.txt

umount $DST 2> /dev/null
mount /dev/sdb1 $DST
if [ $? -ne 0 ]; then
#    echo Could not mount target USB stick!
    exit 1
else
    echo Target USB device mounted at $DST
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
PARTITIONS=`ls /dev/sda* | grep '/dev/sda[1-9][0-6]*'`
for partition in $PARTITIONS
do
    echo Processing partition: ${PARTCOUNT} $partition
    umount $SRC 2> /dev/null
    mount -r $partition $SRC
    if [ $? -ne 0 ]; then
	echo could not mount $partition at /$SRC
    else
	echo $partition mounted at $SRC

	echo PARTITION $PARTCOUNT >> $FL
	find $SRC/* -printf 'echo %p | sed s:$SRC:: >> $FL \n' | while read l; do eval $l; done

	# create a director on sdb named PARTION_n
	targetDir=${DST}/FROM_PARTITION_${PARTCOUNT}
	echo copying to: $targetDir
	mkdir -p $targetDir

	if [ $COPYDIRTYPDF -eq 1 ]; then
	    pdfCopyDirty $SRC $targetDir
	else
	    pdfCopyClean $SRC $targetDir
	fi

	# copy stuff
	copySafeFiles $SRC $targetDir
	convertCopyFiles $SRC $targetDir $TEMP
	rm -rf ${TEMP}/*

	# unpack and process archives
	unpackZip $SRC $targetDir $TEMP
    fi
    let PARTCOUNT=$PARTCOUNT+1
done

#cleanup
rm -rf ${TEMP}*
rm -rf ${ZIPTEMP}*
sync
umount $SRC
umount $DST

/sbin/shutdown -h now

