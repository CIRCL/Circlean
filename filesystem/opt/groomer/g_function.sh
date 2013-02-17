#!/bin/bash

set -e
set -x

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

