Modifying an already-built image
================================
One way to debug the project or test changes quickly is to modify an already built
version of the project. Once you've got an image set up on an SD card, you can mount
the image and make changes to the files directly or copy changes you've made locally
onto the mounted image. The only requirement is a linux distro such as Debian or Ubuntu.
If you're using MacOS, you can download and install VirtualBox.

Mounting an image
=================
* The steps listed in mount_image.sh are only necessary if you'd like to chroot
into and run executables from the image locally.
* To mount the image for the purpose of reading/writing to it, the process is much
* Plug the SD card into the computer.
* If you're on Virtualbox, you'll probably have to unmount the image on the host OS
(on MacOS this involves ejecting it or using diskutil unmountDisk) and then mount it
on the virtualized OS. You might have to select it under "Devices" first.
* Then, in linux, use sudo fdisk -l to find the location of the image.
* sudo mount $PATH_TO_IMAGE $PATH_TO_CHOSEN_MOUNT_POINT will mount the image.
* The path to the image will need to be the path to the partition with the OS on it,
which should be the second partition. So /dev/sdb2, not just dev/sdb.
* When you're done, sudo umount $PATH_TO_MOUNT_POINT will unmount it.
* If you get a warning about "No caching mode page found," it's safe to skip it
by pressing enter.
