Building the image from scratch
===============================

There is always a prebuilt image available for download and installation as
described in the [README](README.md). If you'd like to build the project yourself,
there are several steps:

* Downloading a generic Raspbian Lite image.
* Adding space to the downloaded image.
* Downloading and building the dependencies.
* Copying the project filesystem into the image.

This procedure will not work unless you are running Ubuntu or Debian linux. If you
only have access to MacOS or Windows, the best option is to install linux in a
VM, using something like VirtualBox.

Downloading the Raspbian image
==============================

* Get the most recent version of Raspbian Jessie Lite:

```
   wget https://downloads.raspberrypi.org/raspbian_lite_latest
```

* Unpack it:

```
    unzip XXXX-XX-XX-raspbian-jessie-lite.zip
```

Adding space to the image
=========================

* Use dd to add 2GB (2048 blocks at 1024k each). Using /dev/zero as the input
file yields an unlimited number of "0x00" bytes.

```
    > dd if=/dev/zero bs=1024k count=2048 >> XXXX-XX-XX-raspbian-jessie-lite.img
```

* Grow the root partition using fdisk. The "p" command prints the current partition
table. The first partition listed is the boot partition, which shouldn't be changed.
The "d" command, when given the parameter "2", deletes the current root partition.
The "n" command then makes a new partition. It can take the default for "type"
and "number". The "First sector" should be the value that was the "start" sector of the root
partition (131072 in the example below, but this varies depending on the version of the
Raspbian image). The "Last sector" should be the default, and it should be significantly
larger than it was before (6852607 vs. 2658303 in the example).


```
    > fdisk XXXX-XX-XX-raspbian-jessie-lite.img

    Command (m for help): *p*
    Disk XXXX-XX-XX-raspbian-jessie-lite.img: 3.3 GiB, 3508535296 bytes, 6852608 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x6f92008e

    Device                               Boot  Start     End Sectors  Size Id Type
    XXXX-XX-XX-raspbian-jessie-lite.img1        8192  131071  122880   60M  c W95 FAT32 (LBA)
    XXXX-XX-XX-raspbian-jessie-lite.img2      131072 2658303 2527232  1.2G 83 Linux

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
    First sector (2048-6852607, default 2048): *131072*
    Last sector, +sectors or +size{K,M,G,T,P} (131072-6852607, default 6852607):

    Created a new partition 2 of type 'Linux' and of size 3.2 GiB.

    Command (m for help): *w*
    The partition table has been altered.
    Syncing disks.
```

* Mount the image in loop mode. Edit /mount_image.sh to contain the proper values
for $OFFSET_BOOT and $OFFSET_ROOTFS, which you can obtain using fdisk and "p" as
shown above. You must also change $IMAGE to the correct string. Then run:

```
    sudo ./proper_chroot.sh
```

* After mounting the image, the above script will chroot into the mounted image.
While in a chroot, the / directory is treated like it is the / directory (thus
the name, change root). To exit the chroot, run "exit" in the root directory.
Then, verify the path to the mounted partitions, and resize the filesystem
to fill the new larger partition using resize2fs:

```
    > df | grep /mnt/arm

    /dev/loop0                3927752   1955672   1794172  53% /mnt/arm_rPi
    /dev/loop1                  57288     18960     38328  34% /mnt/arm_rPi/boot

    > sudo resize2fs /dev/loop0
```

Installing the dependencies
===========================

* To install the dependencies, you'll have to reenter the chroot again:

```
    sudo chroot /mnt/arm_rPi
```

* Change your user to root (your global variables may be broken as a result):

```
    su root
```

* Change the locales (remove "en_GB.UTF-8 UTF-8", add "en_US.UTF-8 UTF-8"). The
arrow keys move the cursor, spacebar selects/deselects a locale, tab moves the cursor
to a different context, and enter lets you select "ok":

```
    dpkg-reconfigure locales
```

* In the image, make sure everything is up-to-date and remove the old packages:

```
    apt-get update
    apt-get dist-upgrade
    apt-get autoremove
    apt-get install timidity git p7zip-full python-dev python-pip python-lxml pmount libjpeg-dev libtiff-dev libwebp-dev liblcms2-dev tcl-dev tk-dev python-tk libxml2-dev libxslt1-dev
```

* Install the Python dependencies for PyCIRCLean. Currently, PyCIRCLean is
Python 2.7 and 3.3+ compatible, but Python 2 support might be dropped at some point.

```
    pip install oletools olefile exifread Pillow
    pip install git+https://github.com/Rafiot/officedissector.git
    pip install git+https://github.com/CIRCL/PyCIRCLean.git
```

* Create a new user and make mounting work with a read-only filesystem. 

```
    useradd -m kitten
    chown -R kitten:kitten /home/kitten
    ln -s /proc/mounts /etc/mtab
```

* Enable rc.local, which ensures that the code in /etc/rc.local is run on boot.
This is what triggers CIRCLean to run.

```
    systemctl enable rc-local.service
```

* Exit the chroot again, and copy the files from your repository into the mounted
image.

```
    sudo ./copy_to_final.sh /mnt/arm_rPi/
```

Write the image on a SD card
============================

* Plug your SD card into the computer. Then, find where it is mounted using df:

```
    df -h
```

* If it has been automatically mounted, unmount the SD card (use the path you
found in the previous step:

```
    umount $PATH_TO_YOUR_SD
```

* Write the image to the card:

```
    sudo dd bs=4M if=$PATH_TO_YOUR_IMAGE of=$PATH_TO_YOUR_SD
```
