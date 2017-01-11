DEV_SRC='/dev/sda'
DEV_SRCONE='dev/sda1'
DEV_DST='/dev/sdb1'

# User allowed to do the following commands without password
USERNAME='kitten'
MUSIC="/opt/midi/"

ID=`/usr/bin/id -u`

# Paths used in multiple scripts
SRC="src"
DST="dst"
TEMP="/media/${DST}/temp"
ZIPTEMP="/media/${DST}/ziptemp"
LOGS="/media/${DST}/logs"
GROOM_LOG="/var/tmp/groomer_log.txt"

# commands
SYNC='/bin/sync'
MOUNT='/bin/mount'
PMOUNT='/usr/bin/pmount -A -s'
PUMOUNT='/usr/bin/pumount'
