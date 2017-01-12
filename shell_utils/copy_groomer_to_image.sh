#!/bin/bash

set -e
set -x

# mount /dev/sdb2 /mnt/rpi

cp /media/sf_ubuntu-shared/Circlean-Ubuntu/fs_filecheck/opt/groomer/init.sh /mnt/rpi/opt/groomer/init.sh
cp /media/sf_ubuntu-shared/Circlean-Ubuntu/fs_filecheck/opt/groomer/groomer.sh /mnt/rpi/opt/groomer/groomer.sh
cp /media/sf_ubuntu-shared/Circlean-Ubuntu/fs_filecheck/opt/groomer/constraint.sh /mnt/rpi/opt/groomer/constraint.sh
cp /media/sf_ubuntu-shared/Circlean-Ubuntu/fs_filecheck/etc/rc.local /mnt/rpi/etc/rc.local