#!/bin/bash

set -e
#set -x

source ./constraint.sh

# Force output on analog
amixer cset numid=3 1

files=(${MUSIC}*)

while true; do
    $TIMIDITY ${files[RANDOM % ${#files[@]}]}
done
