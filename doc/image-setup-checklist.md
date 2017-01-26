* Download qemu and qemu-user-static if not already installed
* Download the newest raspbian-lite image from raspberrypi.org
* Verify the sha1 hash of the downloaded .zip file
* Unzip the image
* Expand the image by 2GB using dd
* Expand the root partition using fdisk
* Mount both partitions in loop mode using /shell_utils/simple_mount_image.sh
* Use df to find the larger partition, and resize the filesystem to fill it
* Use proot to enter a chroot in the image: sudo proot -q qemu-arm -S /mnt/rpi-root -b /mnt/rpi-boot:/boot /bin/bash
* Run dpkg-reconfigure locales (this step + others using proot + qemu can be slow, be patient)
* apt-get update
* apt-get dist-upgrade (might have to run this and autoremove several times)
* apt-get autoremove
* apt-get install the linux dependencies:
    - timidity  # for playing music
    - git  # for installing python dependencies from github
    - p7zip-full
    - pmount ntfs-3g  # for mounting, including ntfs
    - python3 python3-pip
    - python3-lxml
    - libjpeg-dev libtiff-dev libwebp-dev liblcms2-dev tcl-dev  # dependencies for building pillow
* Compile p7zip-rar from source
    - Change your source.list file
    - Make a new directory and cd to it
    - apt-get build-dep p7zip-rar
    - dpkg -i <p7zip-rar .deb file path>
* Make sure the right pip executable is called by `pip3`, change your path if necessary
* Upgrade pip: pip3 install -U pip
* pip3 install python dependencies
    - exifread
    - pillow
    - olefile
    - git+https://github.com/decalage2/oletools.git
    - git+https://github.com/grierforensics/officedissector.git
    - git+https://github.com/CIRCL/PyCIRCLean.git
* Add a user named "kitten"
* Symlink /proc/mounts to /etc/mtab
* Copy circlean_fs/root_partition/systemd/system/rc-local.service into the equivalent location
* Turn on rc-local.service `systemctl enable rc.local`
    - If it doesn't work, read these instructions: https://www.linuxbabe.com/linux-server/how-to-enable-etcrc-local-with-systemd
* Copy all of the project files from circlean_fs/ into the two partitions:
    - rsync -vnri <source> <destination> will do a dry run of what will be copied, remove the -n to copy. See the rsync manpage for details.
    - diode_controller/ if you're using the led functionality and have an external led
    - midi/ files into /opt/midi/
    - you might want to double check all of the permissions of the new files/directories
* apt-get autoclean
* apt-get autoremove
* Exit the chroot
* Copy the image over to the SD card: sudo dd bs=4M if=<image> of=/dev/sd<letter>
    - In newer versions of dd, you can add status=progress
* Mount the image
* Optional: fsck the root partition (sudo e2fsck -f /dev/sd<letter>2).
* Test with an rpi
    - FAT32 partition
    - NTFS partition
