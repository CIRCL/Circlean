DEV_SRC='/dev/sdf'
DEV_DST='/dev/sdg1'
HOME='/home/kitten'
# User allowed to do the following commands without password
USERNAME='kitten'

# commands
SUDO='/usr/bin/sudo'
ID='/usr/bin/id -u'

# root commands
MOUNT='/bin/mount'
UMOUNT='/bin/umount'
SYNC='/bin/sync'
SHUTDOWN='/sbin/shutdown'


# To put in /etc/sudoers
# Cmnd alias specification
#Cmnd_Alias GROOMER_CMDS = /bin/mount, /bin/umount, /bin/sync
#kitten  ALL=(ALL) NOPASSWD: GROOMER_CMDS
