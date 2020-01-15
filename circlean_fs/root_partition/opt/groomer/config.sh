#!/bin/bash

set -eu

readonly USERNAME="kitten"
readonly ID=$(/usr/bin/id -u)

# Paths used in multiple scripts
readonly SRC_DEV="/dev/source_key"

readonly DST_DEV="/dev/dest_key"
readonly DST_MNT="/media/kitten/dest_key"

readonly TEMP="${DST_MNT}/temp"
readonly LOGS_DIR="${DST_MNT}/logs"
readonly DEBUG_LOG="/tmp/groomer_debug_log.txt"
readonly MUSIC_DIR="/opt/midi/"

# Commands
readonly SYNC="/bin/sync"
readonly TIMIDITY="/usr/bin/timidity"
readonly MOUNT="udisksctl mount"
readonly UMOUNT="udisksctl unmount"

# Config flags
readonly DEBUG=false
readonly MUSIC=true
