#!/bin/bash

killed(){
    echo 'Music stopped.'
}

run_timidity() {
    # Force output on analog
    amixer cset numid=3 1
    files=(${MUSIC_DIR}*)
    while true; do
        # -id flags set interface to "dumb" and -qq silences most/all terminal output
        "${TIMIDITY}" -idqq "${files[RANDOM % ${#files[@]}]}"
    done
}

main() {
    set -eu  # exit when a line returns non-0 status, treat unset variables as errors
    trap killed EXIT TERM INT  # run clean when the script ends or is interrupted
    source ./config.sh  # get config values
    run_timidity
}

main
