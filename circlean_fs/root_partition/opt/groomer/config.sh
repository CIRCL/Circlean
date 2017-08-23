#!/bin/bash

set -eu

readonly USERNAME="kitten"
readonly ID=$(/usr/bin/id -u)

# Paths used in multiple scripts
readonly DEV_SRC="/dev/source_key"
readonly SRC_MNT="/media/src"

readonly DEV_DST="/dev/dest_key"
readonly DST_MNT="/media/dst"

readonly TEMP="${DST_MNT}/temp"
readonly LOGS_DIR="${DST_MNT}/logs"
readonly DEBUG_LOG="/tmp/groomer_debug_log.txt"
readonly MUSIC_DIR="/opt/midi/"

# Commands
readonly SYNC="/bin/sync"
readonly TIMIDITY="/usr/bin/timidity"
readonly MOUNT="/bin/mount"
readonly PMOUNT="/usr/bin/pmount -A -s"
readonly PUMOUNT="/usr/bin/pumount"

# Config flags
readonly DEBUG=false
readonly MUSIC=true
