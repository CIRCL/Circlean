#!/bin/bash

source ./constraint.sh

# Plain text
text(){
    echo Text file ${1}
}

# Multimedia
audio(){
    echo Audio file ${1}
}

image(){
    echo Image file ${1}
}

video(){
    echo Video file ${1}
}

# Random - Used

application(){
    echo App file ${1}
}

# Random - Unused

example(){
    echo Example file ${1}
}

message(){
    echo Message file ${1}
}

model(){
    echo Model file ${1}
}

multipart(){
    echo Multipart file ${1}
}



main(){
    if [ -z ${1} ]; then
        echo "Please specify the destination directory."
        exit
    fi
    # first param is the destination dir
    dest=${1}

    FILE_COMMAND='file -b --mime-type '
    FILE_LIST=`find ${SRC} -type f`
    for file in ${FILE_LIST}; do
        mime=`$FILE_COMMAND ${file}`
        main=`echo ${mime} | cut -f1 -d/`
        details=`echo ${mime} | cut -f2 -d/`
        case "${main}" in
            "text")
                text ${file}
                ;;
            *)
                echo $mime $main $details
                ;;
        esac
    done
}

