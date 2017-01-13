USERNAME="kitten"
ID=`/usr/bin/id -u`


# Paths used in multiple scripts
SRC="src"
DEV_SRC="/dev/sda"
DEV_SRC_ONE="/dev/sda1"
SRC_MNT="/media/src"

DST="dst"
DEV_DST="/dev/sdb"
DEV_DST_ONE="/dev/sdb1"
DST_MNT="/media/dst"

TEMP="${DST_MNT}/temp"
ZIPTEMP="${DST_MNT}/ziptemp"
LOGS="${DST_MNT}/logs"
GROOM_LOG="/tmp/groom_log.txt"
MUSIC="/opt/midi/"


# Commands
SYNC="/bin/sync"
TIMIDITY="/usr/bin/timidity"
MOUNT="/bin/mount"
PMOUNT="/usr/bin/pmount -A -s"
PUMOUNT="/usr/bin/pumount"
