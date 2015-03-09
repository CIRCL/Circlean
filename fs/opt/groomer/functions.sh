#!/bin/bash


source ./constraint.sh
source ./constraint_conv.sh

RECURSIVE_ARCHIVE_MAX=3
RECURSIVE_ARCHIVE_CURRENT=0
ARCHIVE_BOMB=0
LOGFILE="${LOGS}/processing.txt"

# Something went wrong.
error_handler(){
    echo "FAILED." >> ${LOGFILE}
    echo -e "\tSomething went wrong during the duplication of the last file." >> ${LOGFILE}
    echo -e "\tPlease open a bug on https://www.github.com/Rafiot/KittenGroomer" >> ${LOGFILE}
    continue
}

trap error_handler ERR TERM INT

office_n_txt(){
    src_file=${1}
    dst_file=${2}${1##$CURRENT_SRC}.html
    temp=${2}/temp
    ${LO} --headless --convert-to pdf --outdir "${temp}" "${src_file}"
    ${PDF} --dest-dir=/ ${temp}/*.pdf ${dst_file}
    rm -rf "${temp}"
}

copy(){
    src_file=${1}
    dst_file=${2}
    mkdir -p `dirname "${dst_file}"`
    cp "${src_file}" "${dst_file}"
}

# Plain text
text(){
    echo Text file ${1}
    office_n_txt ${1} ${2}
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
    if [ ${ARCHIVE_BOMB} -eq 0 ]; then
        temp_extract_dir=${2}_temp
        mkdir -p "${temp_extract_dir}"
        ${UNPACKER} -p1 x "${1}" -o"${temp_extract_dir}" -bd
        main ${2} ${RECURSIVE_ARCHIVE_CURRENT} ${temp_extract_dir} || true
        rm -rf "${temp_extract_dir}"
    fi
    if [ ${ARCHIVE_BOMB} -eq 1 ]; then
        rm -rf "${2}"
        rm -rf "${2}_temp"
    fi
    CURRENT_SRC="/media/${SRC}"
}


application(){
    echo App file ${1}
    src_file=${1}
    dst_file=${2}${1##$CURRENT_SRC}
    mime_details=${3}
    case ${mime_details} in
        pdf)
            echo "Got a pdf"
            ${PDF} --dest-dir "${2}" "${src_file}"
            ;;
        msword|vnd.openxmlformats-officedocument.*|vnd.ms-*|vnd.oasis.opendocument*)
            # https://blogs.msdn.com/b/vsofficedeveloper/archive/2008/05/08/office-2007-open-xml-mime-types.aspx
            # http://plan-b-for-openoffice.org/glossary/term/mime-type
            echo "MS Office or ODF document"
            office_n_txt ${src_file} ${2}
            ;;
        *xml*)
            echo "Got an XML"
            office_n_txt ${src_file} ${2}
            ;;
        x-dosexec)
            echo "Win executable"
            copy ${src_file} ${2}/DANGEROUS_${1##$CURRENT_SRC/}_DANGEROUS
            ;;
        zip|x-rar|x-bzip2|x-lzip|x-lzma|x-lzop|x-xz|x-compress|x-gzip|x-tar|*compressed)
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
    set -e
    set -x

    if [ -z ${2} ]; then
        CURRENT_SRC="/media/${SRC}"
        RECURSIVE_ARCHIVE_CURRENT=0
        ARCHIVE_BOMB=0
    else
        RECURSIVE_ARCHIVE_CURRENT=${2}
        CURRENT_SRC=${3}
        if [ ${RECURSIVE_ARCHIVE_CURRENT} -gt ${RECURSIVE_ARCHIVE_MAX} ]; then
            echo Archive bomb.
            ARCHIVE_BOMB=1
            echo "ARCHIVE BOMB." >> ${LOGFILE}
            echo "The content of the archive contains recursively other archives." >> ${LOGFILE}
            echo "This is a bad sign so the archive is not extracted to the destination key." >> ${LOGFILE}
            return
        else
            RECURSIVE_ARCHIVE_CURRENT=`expr ${RECURSIVE_ARCHIVE_CURRENT} + 1`
        fi
    fi

    FILE_LIST=`find ${CURRENT_SRC} -type f`
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for file in ${FILE_LIST}; do
        # first param is the destination dir
        dest=${1}

        mime=`file -b --mime-type "${file}"`
        echo ${mime}
        main_mime=`echo ${mime} | cut -f1 -d/`
        details=`echo ${mime} | cut -f2 -d/`
        echo -n "Processing ${file} (${mime})... " >> ${LOGFILE}
        case "${main_mime}" in
            "text")
                text ${file} ${dest} || error_handler
                ;;
            "audio")
                audio ${file} ${dest} || error_handler
                ;;
            "image")
                image ${file} ${dest} || error_handler
                ;;
            "video")
                video ${file} ${dest} || error_handler
                ;;
            "application")
                application ${file} ${dest} ${details} || error_handler
                ;;
            "example")
                example ${file} ${dest} || error_handler
                ;;
            "message")
                message ${file} ${dest} || error_handler
                ;;
            "model")
                model ${file} ${dest} || error_handler
                ;;
            "multipart")
                multipart ${file} ${dest} || error_handler
                ;;
            *)
                echo "This should never happen... :]"
                echo $mime $main_mime $details
                ;;
        esac
        echo "done." >> ${LOGFILE}
    done
    IFS=$SAVEIFS
    return 0
}


