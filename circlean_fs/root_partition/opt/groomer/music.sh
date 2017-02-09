#!/bin/bash

set -e
#set -x

source ./config.sh

killed(){
    echo 'Music stopped.'
}

trap killed EXIT TERM INT

# Force output on analog
amixer cset numid=3 1

files=(${MUSIC}*)

while true; do
    # -id flags set interface to "dumb" and -qq silences most/all terminal output
    $TIMIDITY -idqq ${files[RANDOM % ${#files[@]}]}
done
