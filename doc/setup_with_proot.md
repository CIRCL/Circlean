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
    apt-get install qemu qemu-user-static qemu-user proot
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

* Expand the root (second) partition using sfdisk:
```
	> echo ", +" | sfdisk -N 2 XXXX-XX-XX-raspbian-jessie-lite.img
	Checking that no-one is using this disk right now ... OK

	Disk 2017-11-29-raspbian-stretch-lite.img: 3.7 GiB, 4005560320 bytes, 7823360 sectors
	Units: sectors of 1 * 512 = 512 bytes
	Sector size (logical/physical): 512 bytes / 512 bytes
	I/O size (minimum/optimal): 512 bytes / 512 bytes
	Disklabel type: dos
	Disk identifier: 0x37665771

	Old situation:

	Device                                Boot Start     End Sectors  Size Id Type
	2017-11-29-raspbian-stretch-lite.img1       8192   93236   85045 41.5M  c W95 FAT32 (LBA)
	2017-11-29-raspbian-stretch-lite.img2      94208 3629055 3534848  1.7G 83 Linux

	2017-11-29-raspbian-stretch-lite.img2:
	New situation:
	Disklabel type: dos
	Disk identifier: 0x37665771

	Device                                Boot Start     End Sectors  Size Id Type
	2017-11-29-raspbian-stretch-lite.img1       8192   93236   85045 41.5M  c W95 FAT32 (LBA)
	2017-11-29-raspbian-stretch-lite.img2      94208 7823359 7729152  3.7G 83 Linux

	The partition table has been altered.
	Syncing disks.
```

* Edit `shell_utils/basic_mount_image.sh` to use the correct image path ($IMAGE)
* Run the script
```
shell_utils/basic_mount_image.sh
```


Installing the dependencies
===========================

* Copy circlean_fs/root_partition/etc/systemd/system/rc-local.service into the equivalent location in the image.
```
    sudo cp circlean_fs/root_partition/etc/systemd/system/rc-local.service /mnt/rpi-root/etc/systemd/system/rc-local.service
```
* Use [proot](https://proot-me.github.io/) to enter the equivalent of a chroot inside
the mounted image.
```
    sudo proot -q qemu-arm -0 -r /mnt/rpi-root -b /mnt/rpi-boot:/boot -b /etc/resolv.conf:/etc/resolv.conf \
		-b /dev/:/dev/ -b /sys/:/sys/ -b /proc/:/proc/ -b /run/shm:/run/shm  /bin/bash
```

**WARNING**: if you have a permission error, make sure the `/tmp` directory is mointed with the `exec` flag.

* Change your locales (remove "en_GB.UTF-8 UTF-8", add "en_US.UTF-8 UTF-8"). The
arrow keys move the cursor, spacebar selects/deselects a locale, tab moves the cursor
to a different context, and enter lets you select "ok". This step might take some time,
be patient:
```
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
    sed -i -e 's/en_GB.UTF-8 UTF-8/# en_US.UTF-8 UTF-8/g' /etc/locale.gen
    locale-gen en_US.UTF-8
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
```
* In the image, make sure everything is up-to-date and remove old packages. You may have to
run dist-upgrade and autoremove several times for everything to be installed, and a few
raspbian-sys-mods related installs may fail - you can ignore them:
```
    apt-get update
    apt-get dist-upgrade
    apt-get autoremove
```
* Install the linux dependencies (see CONTRIBUTING.md for more details). If you see warnings that
from qemu about "Unsupported syscall: 384", you can ignore them. `getrandom(2)` was implemented in
kernel 3.17 and apt will use /dev/urandom when it fails:
```
    apt-get install timidity git p7zip-full python3 python3-pip python3-lxml pmount ntfs-3g libjpeg-dev libtiff-dev libwebp-dev tk-dev python3-tk liblcms2-dev tcl-dev libopenjp2-7
```
* Compile p7zip-rar from source. First, uncomment out the second line in /etc/apt/sources.list. Then:
```
    cd /home/pi
    mkdir rar && cd rar/
    apt-get update
    apt-get build-dep p7zip-rar
    apt-get source -b p7zip-rar
    dpkg -i ${path to p7zip-rar .deb file}
```
* Install the Python dependencies for `PyCIRCLean/filecheck.py`. PyCIRCLean is 3.5+
compatible, so use `pip -V` to make sure you're using the right version of pip. You might
have to edit your PATH variable or use pip3 to get the correct pip. You also might want to
verify that these dependencies are current by checking in the PyCIRCLean git repo.
```
    pip3 install -U pip
    hash -r
    pip3 install olefile oletools exifread Pillow
    pip3 install git+https://github.com/Rafiot/officedissector.git
    pip3 install git+https://github.com/CIRCL/PyCIRCLean.git
```
* Create a new user named "kitten":
```
    useradd -m kitten
    chown -R kitten:kitten /home/kitten
```
* (if needed) Symlinking `/proc/mounts` to `/etc/mtab` is necessary because `/etc/mtab` cannot be edited by
`pmount` if root is read-only. `/proc/mounts` is maintained by the kernel and is guaranteed to
be accurate.
```
    ln -s /proc/mounts /etc/mtab
```
* Enable `rc.local`, which ensures that the code in `/etc/rc.local` is run on boot.
This is what triggers CIRCLean to run.
```
    systemctl enable rc-local.service
```
* Turn off several networking related services. This speeds up boot and reduces the attack surface:
```
    systemctl disable networking.service
    systemctl disable bluetooth.service
    systemctl disable dhcpcd.service
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
    sudo cp -rf midi /mnt/rpi-root/opt/
```
* If have an external hardware led and you're using the led functionality, copy
the led files from diode_controller/ as well.

* Unmount the image
```
sudo umount /mnt/rpi-boot /mnt/rpi-root
```

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
    sudo fsck.vfat -f /dev/<partition>1
    sudo e2fsck -f /dev/<partition>2
```
