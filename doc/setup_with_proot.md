Building the image from scratch
===============================

There is always a prebuilt image available for download and installation as
described in the [README](../README.md). If you'd like to build the project yourself,
there are several steps involved:

* Downloading a generic Raspbian Lite image
* Resizing the image and partition
* Downloading and building the dependencies
* Modifying the image configuration
* Copying the project filesystem into the image

This procedure will only work on Ubuntu or Debian Linux. If you use MacOS or
Windows, the best option is to install Linux in a virtual machine using
something like VirtualBox.

It is recommended that you make a copy of image_setup_checklist.md and √ items off
on the list as you go.

Preparation
===========

* Make sure your development environment is up to date:
```
    apt-get update
    apt-get dist-upgrade
```
* Install qemu, qemu-user-static, and proot if not already installed:
```
    apt-get install qemu qemu-user-static proot
```

Download the Raspbian image
==============================

* Get the most recent version of Raspbian Jessie Lite from https://downloads.raspberrypi.org/raspbian_lite/images/:

```
   wget https://downloads.raspberrypi.org/raspbian_lite_latest
```
* Verify the hash of the downloaded file and compare it to the hash on the server:
```
    shasum XXXX-XX-XX-raspbian-jessie-lite.zip
```
* Unpack it:
```
    unzip XXXX-XX-XX-raspbian-jessie-lite.zip
```

Add space to the image
=========================

* Use dd to add 2GB (2048 blocks of 1024k each). Using /dev/zero as the input
file yields an unlimited number of "0x00" bytes.
```
    > dd if=/dev/zero bs=1024k count=2048 >> XXXX-XX-XX-raspbian-jessie-lite.img
```
* Expand the root (second) partition using fdisk. The first partition listed is the boot
partition, which shouldn't be changed. In the new partition, the "First sector" should be
the value that was the "start" sector of the old root partition (137216 in the example
below, but this varies depending on the version of the Raspbian image). The "Last sector"
should be the default, and it should be significantly larger than it was before (6909951 vs.
2715647 in the example).

```
    > fdisk XXXX-XX-XX-raspbian-jessie-lite.img

    Command (m for help): *p*
    Disk XXXX-XX-XX-raspbian-jessie-lite.img: 3.3 GiB, 3537895424 bytes, 6909952 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x244b8248

    Device                               Boot  Start     End Sectors  Size Id Type
    XXXX-XX-XX-raspbian-jessie-lite.img1        8192  137215  129024   63M  c W95 FAT32 (LBA)
    XXXX-XX-XX-raspbian-jessie-lite.img2      137216 2715647 2578432  1.2G 83 Linux

    Command (m for help): *d*
    Partition number (1,2, default 2): *2*

    Partition 2 has been deleted.

    Command (m for help): *n*
    Partition type
       p   primary (1 primary, 0 extended, 3 free)
       e   extended (container for logical partitions)
    Select (default p):

    Using default response p.
    Partition number (2-4, default 2):
    First sector (2048-6852607, default 2048): *137216*
    Last sector, +sectors or +size{K,M,G,T,P} (131216-6909951, default 6909951):

    Created a new partition 2 of type 'Linux' and of size 3.2 GiB.

    Command (m for help): *w*
    The partition table has been altered.
    Syncing disks.
```
* Mount the image in loop mode: first, edit shell_utils/basic_mount_image.sh to use the
proper values for $BOOT_START and $ROOT_START, which you can obtain using fdisk and "p"
as in the previous step. You must also change $IMAGE to the correct path. Then run:
```
    sudo ./shell_utils/basic_mount_image.md
```
* Verify the path to the mounted partitions in /dev, and resize the root (larger) filesystem
to fill the new larger partition using resize2fs:
```
    > df | grep /mnt/arm

    /dev/loop0                3927752   1955672   1794172  53% /mnt/rpi-root
    /dev/loop1                  57288     18960     38328  34% /mnt/rpi-boot

    > sudo resize2fs /dev/loop0
```

Installing the dependencies
===========================

* Copy circlean_fs/root_partition/systemd/system/rc-local.service into the equivalent location in the image.
```
    cp circlean_fs/root_partition/systemd/system/rc-local.service /mnt/rpi-root/etc/systemd/system/rc-local.service
```
* Use [proot](https://proot-me.github.io/) to enter the equivalent of a chroot inside
the mounted image.
```
    sudo proot -q qemu-arm -S /mnt/rpi-root -b /mnt/rpi-boot:/boot /bin/bash
```
* Change your locales (remove "en_GB.UTF-8 UTF-8", add "en_US.UTF-8 UTF-8"). The
arrow keys move the cursor, spacebar selects/deselects a locale, tab moves the cursor
to a different context, and enter lets you select "ok". This step might take some time,
be patient:
```
    dpkg-reconfigure locales
```
* In the image, make sure everything is up-to-date and remove old packages. You may have to
run dist-upgrade and autoremove several times for everything to be installed, and a few
raspbian-sys-mods related installs may fail - you can ignore them:
```
    apt-get update
    apt-get dist-upgrade
    apt-get autoremove
```
* Install the linux dependencies (see CONTRIBUTING.md for more details):
```
    apt-get install timidity git p7zip-full python3 python3-pip python3-lxml pmount ntfs-3g libjpeg-dev libtiff-dev libwebp-dev tk-dev python-tk liblcms2-dev tcl-dev
```
* Compile p7zip-rar from source. First, uncomment out the second line in /etc/apt/sources.list. Then:
```
    cd /home/pi
    mkdir rar && cd rar/
    apt-get build-dep p7zip-rar
    dpkg -i ${path to p7zip-rar .deb file}
```
* Install the Python dependencies for PyCIRCLean/filecheck.py. PyCIRCLean is 3.3+
compatible, so use pip -V to make sure you're using the right version of pip. You might
have to edit your PATH variable or use pip3 to get the correct pip. You also might want to
verify that these dependencies are current by checking in the PyCIRCLean git repo.
```
    pip install -U pip
    pip install oletools exifread Pillow
    pip install git+https://github.com/decalage2/oletools.git
    pip install git+https://github.com/Rafiot/officedissector.git
    pip install git+https://github.com/CIRCL/PyCIRCLean.git
```
* Create a new user named "kitten":
```
    useradd -m kitten
    chown -R kitten:kitten /home/kitten
```
* Symlinking /proc/mounts to /etc/mtab is necessary because /etc/mtab cannot be edited by
pmount if root is read-only. /proc/mounts is maintained by the kernel and is guaranteed to
be accurate.
```
    ln -s /proc/mounts /etc/mtab
```
* Enable rc.local, which ensures that the code in /etc/rc.local is run on boot.
This is what triggers CIRCLean to run.
```
    systemctl enable rc-local.service
```
* Clean up:
```
    apt-get clean
    apt-get autoremove
    apt-get autoclean
```
* Exit proot, and copy the files from your repository into the mounted
image. Adding a -n flag will make rsync do a dry run instead of copying. See the rsync
manpage for more details. Make sure to include the trailing slashes on the paths:
```
    exit
    sudo rsync -vri circlean_fs/boot/ /mnt/rpi-boot/
    sudo rsync -vri circlean_fs/root_partition/ /mnt/rpi-root/
    cp -rf midi /mnt/rpi-root/opt/
```
* If have an external hardware led and you're using the led functionality, copy
the led files from diode_controller/ as well.

Write the image on a SD card
============================

* Plug your SD card into the computer. Then, find where it is mounted using lsblk or df:
```
    lsblk
    df -h
```
* If it has been automatically mounted, unmount the SD card (use the path you
found in the previous step):
```
    umount $PATH_TO_YOUR_SD
```
* Write the image to the card. Newer versions of dd include a status option to monitor the
copying process:
```
    sudo dd bs=4M if=$PATH_TO_YOUR_IMAGE of=$PATH_TO_YOUR_SD status=progress
```
* Use fsck to verify the root partition:
```
    sudo e2fsck -f /dev/sd<number>2
```
