#!/bin/bash

source ./constraint.sh

copy(){
    src_file=${1}
    dst_file=${2}
    mkdir -p `dirname ${dst_file}`
    cp ${src_file} ${dst_file}
}

# Plain text
text(){
    echo Text file ${1}
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
        "pdf")
            echo "Got a pdf"
            # WARNING: This command randomly fails, and loop indefinitely...
            pdf2ps -dSAFER -sOutputFile="%stdout" ${src_file} | ps2pdfwr - ${dst_file}
            ;;
        *xml*)
            echo "Got an XML"
            text ${1} ${2}
            ;;
        *)
            echo "Unknown type."
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

