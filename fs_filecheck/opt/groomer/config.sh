DEV_SRC='/dev/sda'
DEV_SRC_ONE='/dev/sda1'
DEV_DST='/dev/sdb'
DEV_DST_ONE='/dev/sdb1'

# User allowed to do the following commands without password
USERNAME='kitten'
MUSIC="/opt/midi/"

ID=`/usr/bin/id -u`

# Paths used in multiple scripts
SRC="src"
DST="dst"
SRC_MNT="/media/src"
DST_MNT="/media/dst"
TEMP="${DST_MNT}/temp"
ZIPTEMP="${DST_MNT}/ziptemp"
LOGS="${DST_MNT}/logs"
GROOM_LOG="/tmp/groom_log.txt"

# commands
SYNC='/bin/sync'
TIMIDITY='/usr/bin/timidity'
MOUNT='/bin/mount'
PMOUNT='/usr/bin/pmount -A -s'
PUMOUNT='/usr/bin/pumount'
