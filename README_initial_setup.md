Create a new image from scratch
===============================

* Download the most recent Raspbian version:
    http://downloads.raspberrypi.org/raspbian_latest

* Unpack it:

```
    unzip 2015-02-16-raspbian-wheezy.zip
```

Prepare the base image
======================

It will be used for the build environment and the final image.

* [Add empty space to the image](resize_img.md)

* Edit `mount_image.sh` and change the `IMAGE` variable accordingly

```
    IMAGE='2015-02-16-raspbian-wheezy.img'
```

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
    mv 2015-02-16-raspbian-wheezy.img BUILDENV_2015-02-16-raspbian-wheezy.img
    cp BUILDENV_2015-02-16-raspbian-wheezy.img FINAL_2015-02-16-raspbian-wheezy.img
```

Build environment specifics
===========================

* Create a symlink to the build image

```
    ln -s  BUILDENV_2015-02-16-raspbian-wheezy.img 2015-02-16-raspbian-wheezy.img
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
    gpg --keyserver pgpkeys.mit.edu --recv-key  8B48AD6246925553
    gpg -a --export 8B48AD6246925553 | sudo apt-key add -
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
   rm 2015-02-16-raspbian-wheezy.img
   ln -s FINAL_2015-02-16-raspbian-wheezy.img 2015-02-16-raspbian-wheezy.img
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

Write the image on a SD card
============================

*WARNING*: Make sure you write on the right filesystem

```
    sudo dd bs=4M if=FINAL_2015-02-16-raspbian-wheezy.img of=/dev/<FILESYSTEM>
```

Run the tests
=============

Make sure to set the filename of the image in `tests/run.sh`

```
    sudo ./run_tests.sh
```

