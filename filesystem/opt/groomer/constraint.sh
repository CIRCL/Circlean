DEV_SRC='/dev/sdb'
DEV_DST='/dev/sdc1'
# User allowed to do the following commands without password
USERNAME='kitten'
HOME="/home/${USERNAME}"

# commands
SUDO='/usr/bin/sudo'
ID=`/usr/bin/id -u`
SYNC='/bin/sync'

# root commands.
# To avoid the risk that an attacker use -o remount on mount and other nasty
# commands, we use our own scripts to invoke mount and umount.
# NOTE: sync is safe, isn't it? Please prove me wrong.
MOUNT_DST="${HOME}/kitten_mount_dst"
MOUNT_SRC="${HOME}/kitten_mount_src"
UMOUNT="${HOME}/kitten_umount"
