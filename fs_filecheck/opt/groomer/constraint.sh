DEV_SRC='/dev/sda'
DEV_DST='sdb1'

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
TIMIDITY='/usr/bin/timidity'
MOUNT='/bin/mount'
PMOUNT='/usr/bin/pmount -A -s'
PUMOUNT='/usr/bin/pumount'
