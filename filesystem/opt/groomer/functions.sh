#!/bin/bash

set -e
set -x

source ./constraint.sh
source ./constraint_conv.sh

RECURSIVE_ARCHIVE_MAX=3
RECURSIVE_ARCHIVE_CURRENT=0

copy(){
    src_file=${1}
    dst_file=${2}
    mkdir -p `dirname ${dst_file}`
    cp ${src_file} ${dst_file}
}

# Plain text
text(){
    echo Text file ${1}
    # XXX: append .txt ?
    copy ${1} ${2}${1##$CURRENT_SRC}
}

# Multimedia
## WARNING: They are assumed safe.
audio(){
    echo Audio file ${1}
    copy ${1} ${2}${1##$CURRENT_SRC}
}

image(){
    echo Image file ${1}
    copy ${1} ${2}${1##$CURRENT_SRC}
}

video(){
    echo Video file ${1}
    copy ${1} ${2}${1##$CURRENT_SRC}
}

# Random - Used

archive(){
    echo Archive file ${1}
    src_file=${1}
    dst_dir=${2}
    temp_extract_dir=${dst_dir}_temp
    mkdir -p ${temp_extract_dir}
    ${UNPACKER} x ${src_file} -o${temp_extract_dir} -bd
    main ${dst_dir} ${RECURSIVE_ARCHIVE_CURRENT} ${temp_extract_dir}
    rm -rf ${temp_extract_dir}
}


application(){
    echo App file ${1}
    src_file=${1}
    dst_file=${2}${1##$CURRENT_SRC}
    mime_details=${3}
    case ${mime_details} in
        pdf)
            echo "Got a pdf"
            ${PDF} --dest-dir ${2} ${src_file}
            ;;
        msword|vnd.openxmlformats-officedocument.*|vnd.ms-*|vnd.oasis.opendocument*)
            # https://blogs.msdn.com/b/vsofficedeveloper/archive/2008/05/08/office-2007-open-xml-mime-types.aspx
            # http://plan-b-for-openoffice.org/glossary/term/mime-type
            echo "MS Office or ODF document"
            temp=${2}/temp
            mkdir ${temp}
            ${LO} --headless --convert-to pdf --outdir ${temp} ${src_file}
            ${PDF} --dest-dir ${2} ${temp}/*.pdf
            rm -rf ${temp}
            ;;
        *xml*)
            echo "Got an XML"
            text ${src_file} ${2}
            ;;
        x-dosexec)
            echo "Win executable"
            copy ${src_file} ${dst_file}_DANGEROUS
            ;;
        x-gzip|x-7z-compressed)
            echo "Compressed file"
            archive ${src_file} ${dst_file}
            ;;
        octet-stream)
            echo "Unknown type."
            copy ${src_file} ${dst_file}.bin
            ;;
        *)
            echo "Unhandled type"
            copy ${src_file} ${dst_file}
            ;;
    esac

}

# Random - Unused?
## WARNING: They are assumed safe.

example(){
    echo Example file ${1}
    copy ${1} ${2}${1##$CURRENT_SRC}
}

message(){
    echo Message file ${1}
    copy ${1} ${2}${1##$CURRENT_SRC}
}

model(){
    echo Model file ${1}
    copy ${1} ${2}${1##$CURRENT_SRC}
}

multipart(){
    echo Multipart file ${1}
    copy ${1} ${2}${1##$CURRENT_SRC}
}

main(){
    if [ -z ${1} ]; then
        echo "Please specify the destination directory."
        exit
    fi
    # first param is the destination dir
    dest=${1}

    if [ -z ${2} ]; then
        CURRENT_SRC=${SRC}
    else
        CURRENT_SRC=${2}
    fi


    if [ -z ${2} ]; then
        RECURSIVE_ARCHIVE_CURRENT=0
    else
        RECURSIVE_ARCHIVE_CURRENT=${2}
        CURRENT_SRC=${3}
        if [ ${RECURSIVE_ARCHIVE_CURRENT} -gt ${RECURSIVE_ARCHIVE_MAX} ]; then
            echo Archive bomb.
            rm -rf ${CURRENT_SRC}
            return
        else
            RECURSIVE_ARCHIVE_CURRENT=`expr ${RECURSIVE_ARCHIVE_CURRENT} + 1`
        fi
    fi

    FILE_COMMAND='file -b --mime-type'
    FILE_LIST=`find ${CURRENT_SRC} -type f`
    for file in ${FILE_LIST}; do
        mime=`$FILE_COMMAND ${file}`
        echo ${mime}
        main=`echo ${mime} | cut -f1 -d/`
        details=`echo ${mime} | cut -f2 -d/`
        case "${main}" in
            "text")
                text ${file} ${dest}
                ;;
            "audio")
                audio ${file} ${dest}
                ;;
            "image")
                image ${file} ${dest}
                ;;
            "video")
                video ${file} ${dest}
                ;;
            "application")
                application ${file} ${dest} ${details}
                ;;
            "example")
                example ${file} ${dest}
                ;;
            "message")
                message ${file} ${dest}
                ;;
            "model")
                model ${file} ${dest}
                ;;
            "multipart")
                multipart ${file} ${dest}
                ;;
            *)
                echo "This should never happen... :]"
                echo $mime $main $details
                ;;
        esac
    done
}

