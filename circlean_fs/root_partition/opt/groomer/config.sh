USERNAME="kitten"
ID=`/usr/bin/id -u`


# Paths used in multiple scripts
SRC="src"
DEV_SRC="/dev/source_key"
SRC_MNT="/media/src"

DST="dst"
DEV_DST="/dev/dest_key"
DST_MNT="/media/dst"

TEMP="${DST_MNT}/temp"
ZIPTEMP="${DST_MNT}/ziptemp"
LOGS="${DST_MNT}/logs"
DEBUG_LOG="/tmp/groomer_debug_log.txt"
MUSIC="/opt/midi/"


# Commands
SYNC="/bin/sync"
TIMIDITY="/usr/bin/timidity"
MOUNT="/bin/mount"
PMOUNT="/usr/bin/pmount -A -s"
PUMOUNT="/usr/bin/pumount"

# Config flags
DEBUG=true
