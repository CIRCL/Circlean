#!/bin/bash

set -x

cp circlean/root_partition/opt/groomer/init.sh /mnt/rpi/opt/groomer/init.sh
cp circlean/root_partition/opt/groomer/groomer.sh /mnt/rpi/opt/groomer/groomer.sh
cp circlean/root_partition/opt/groomer/config.sh /mnt/rpi/opt/groomer/config.sh
cp circlean/root_partition/opt/groomer/mount_dest.sh /mnt/rpi/opt/groomer/mount_dest.sh
cp circlean/root_partition/etc/rc.local /mnt/rpi/etc/rc.local
# cp circlean/root_partition/opt/groomer/music.sh /mnt/rpi/opt/groomer/music.sh
# cp circlean/root_partition/etc/pmount.allow /mnt/rpi/etc/pmount.allow
# cp circlean/root_partition/etc/udev/rules.d/10-usb.rules /mnt/rpi/etc/udev/rules.d/10-usb.rules
