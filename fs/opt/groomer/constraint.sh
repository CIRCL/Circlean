DEV_SRC='/dev/sda'
DEV_DST='/dev/sdb1'
# User allowed to do the following commands without password
USERNAME='kitten'
HOME="/home/${USERNAME}"

# Paths used in multiple scripts
SRC="${HOME}/src"

DST="${HOME}/dst"
TEMP="${DST}/temp"
ZIPTEMP="${DST}/ziptemp"
LOGS="${DST}/logs"


# commands
SUDO='/usr/bin/sudo'
ID=`/usr/bin/id -u`
SYNC='/bin/sync'

# root commands.
# To avoid the risk that an attacker use -o remount on mount and other nasty
# commands, we use our own scripts to invoke mount and umount.
MOUNT_DST="${HOME}/kitten_mount_dst"
MOUNT_SRC="${HOME}/kitten_mount_src"
UMOUNT="${HOME}/kitten_umount"
