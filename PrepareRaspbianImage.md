Prerequisites
=============

Get the latest image: http://www.raspberrypi.org/downloads (the recommended one)
And write it on the SD Card:
dd bs=4M if=~/2013-02-09-wheezy-raspbian.img of=/dev/mmcblk0

Note: I had to unplug/replug the sd card in order to see the second partition.

On a debian/ubuntu host:
- http://burstcoding.blogspot.com/2012/12/qemu-user-mode-arm-for-raspbian-chroot.html (not tested)
On a gentoo host:
- app-emulation/qemu-user

Choot
=====

chroot


