#!/bin/bash

source ./constraint.sh
source ./constraint_conv.sh

# https://blogs.msdn.com/b/vsofficedeveloper/archive/2008/05/08/office-2007-open-xml-mime-types.aspx
# http://plan-b-for-openoffice.org/glossary/term/mime-type
OFFICE_MIME="msword|vnd.openxmlformats-officedocument.*|vnd.ms-*|vnd.oasis.opendocument*"

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
    copy ${1} ${2}${1##$SRC}
}

# Multimedia
## WARNING: They are assumed safe.
audio(){
    echo Audio file ${1}
    copy ${1} ${2}${1##$SRC}
}

image(){
    echo Image file ${1}
    copy ${1} ${2}${1##$SRC}
}

video(){
    echo Video file ${1}
    copy ${1} ${2}${1##$SRC}
}

# Random - Used

application(){
    echo App file ${1}
    src_file=${1}
    dst_file=${2}${1##$SRC}
    mime_details=${3}
    case ${mime_details} in
        pdf)
            echo "Got a pdf"
            ${PDF} --dest-dir ${2} ${src_file}
            ;;
        ${OFFICE_MIME})
            echo "MS Office or ODF document"
            temp=${2}/temp
            mkdir ${temp}
            ${LO} --convert-to pdf --outdir ${temp} ${src_file}
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
    copy ${1} ${2}${1##$SRC}
}

message(){
    echo Message file ${1}
    copy ${1} ${2}${1##$SRC}
}

model(){
    echo Model file ${1}
    copy ${1} ${2}${1##$SRC}
}

multipart(){
    echo Multipart file ${1}
    copy ${1} ${2}${1##$SRC}
}

main(){
    if [ -z ${1} ]; then
        echo "Please specify the destination directory."
        exit
    fi
    # first param is the destination dir
    dest=${1}

    FILE_COMMAND='file -b --mime-type'
    FILE_LIST=`find ${SRC} -type f`
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

