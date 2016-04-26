Install Qemu and Expect
============

Install the necessary packages:

```
    sudo apt-get install qemu qemu-user-static expect
```

Create a new image from scratch
===============================

* Download the most recent version of Raspbian Jessie lite:
    https://downloads.raspberrypi.org/raspbian_lite_latest

* Unpack it:

```
    unzip 2016-03-18-raspbian-jessie-lite.zip
```

Prepare the base image
======================

It will be used for the build environment and the final image.

* [Add empty space to the image](resize_img.md)

* Chroot in the image

```
    sudo ./proper_chroot.sh
```

* Change your user to root (your global variables may be broken)

```
    su root
```

* The locales may be broken, fix it (remove `en_GB.UTF-8 UTF-8`, set `en_US.UTF-8 UTF-8`):

```
    dpkg-reconfigure locales
```

* In the image, make sure everything is up-to-date, and remove the old packages

```
    apt-get update
    apt-get dist-upgrade
    apt-get autoremove
```

Setup two images
================

* Create two separate images: one will be used to build the deb packages that are not available in wheezy

```
    mv raspbian-wheezy.img BUILDENV-raspbian-wheezy.img
    cp BUILDENV-raspbian-wheezy.img FINAL-raspbian-wheezy.img
```

Build environment specifics
===========================

* Create a symlink to the build image

```
    ln -s  BUILDENV-raspbian-wheezy.img raspbian-wheezy.img
```

* Chroot in the image

```
    sudo ./proper_chroot.sh
```

* Change your user to root (your global variables may be broken)

```
    su root
```

* Add Wheezy backports source packages to build a poppler version compatible with pdf2htmlEX

```
    echo 'deb-src http://ftp.debian.org/debian/ wheezy-backports main' >> /etc/apt/sources.list
    apt-get instal debian-keyring debian-archive-keyring
    apt-get update
```

* Get the required build dependencies and the sources

```
    apt-get build-dep poppler
    apt-get source poppler
```

* Compile the package

```
    cd poppler-<VERSION>/
    dpkg-buildpackage
```
At least on Debian 8, you may receive an error about libpoppler-glib-dev missing the gir1.2-poppler requirement; you can ignore it.


* Install the packages required by pdf2htmlEX

```
    apt-get install cmake libfontforge-dev libspiro-dev python-dev default-jre-headless
    cd ..
    dpkg -i libpoppler-dev* libpoppler* libpoppler-private-dev*
```

* Download the sources of pdf2htmlEX (we cannot use anything newer than v0.11 because fontforge>=2.0 is not available)

```
    wget https://github.com/Rafiot/pdf2htmlEX/archive/KittenGroomer.zip
    unzip KittenGroomer.zip
```

* Compile the package

```
    cd pdf2htmlEX-KittenGroomer/
    dpkg-buildpackage -uc -b
```

* Get the packages out of the building image (run it outside of the chroot)

```
    cp /mnt/arm_rPi/libpoppler46_* /mnt/arm_rPi/pdf2htmlex_* deb/
```

Final image specifics
=====================

* Change the link to the image

```
   rm raspbian-wheezy.img
   ln -s FINAL-raspbian-wheezy.img -raspbian-wheezy.img
```

* Chroot in the image

```
    sudo ./proper_chroot.sh
```

* Change your user to root (your global variables may be broken)

```
    su root
```

* Copy the debian packages into the chroot (run it outside of the chroot)

```
    cp deb/*.deb /mnt/arm_rPi/
```

* Install repencencies required by the project

```
    apt-get install libreoffice p7zip-full libfontforge1 timidity freepats pmount ntfs-3g unoconv python-pip
    dpkg -i *.deb
    pip install twiggy python-magic
```

* Create the user, make Libreoffice and mtab working on a RO filesystem

```
    useradd -m kitten
    pushd /home/kitten
    ln -s /tmp/libreoffice
    mkdir .config/
    ln -s /tmp/libreoffice_config .config/libreoffice
    popd
    chown -R kitten:kitten /home/kitten
    ln -s /proc/mounts /etc/mtab
```

* Copy the script to the image

```
    sudo ./copy_to_final.sh
```

* Get the PyCIRCLean modules
```
    pip install git+https://github.com/CIRCL/PyCIRCLean
```


* Exit the chroot

Write the image on a SD card
============================

*WARNING*: Make sure you write on the right filesystem

```
    sudo dd bs=4M if=FINAL-raspbian-wheezy.img of=/dev/<FILESYSTEM>
```

Run the tests
=============

* Get the qemu kernel:
```
   pushd tests; wget https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu; popd
```

* Put some test data from tests/testFiles into tests/content_img_vfat_norm

* Comment out the other tests in tests/run.sh or populate those directories as
  well

* Make sure to set the filename of the image and the kernel in `tests/run.sh`

* Run the tests:
```
    sudo ./run_tests.sh
```

* If the image run processed images correctly but doesn't exit and unmount the
  images cleanly, look at tests/run.exp and make sure it's waiting for the
  string your qemu and kernel actually produce.
