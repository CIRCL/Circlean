Install Qemu and Expect
============

Install the necessary packages:

```
    sudo apt-get install qemu qemu-user-static expect
```

Create a new image from scratch
===============================

* Download the most recent Raspbian version:
    http://downloads.raspberrypi.org/raspbian_latest

* Unpack it:

```
    unzip 2015-05-05-raspbian-wheezy.zip
    mv 2015-05-05-raspbian-wheezy.zip raspbian-wheezy.zip
```

Prepare the image
=================

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
    apt-get install p7zip-full python-dev libxml2-dev libxslt1-dev pmount python-setuptools libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev python-tk
```

* Install python requirements

```
    pip install lxml
    pip install oletools olefile
    pip install officedissector
    pip install exifread
    pip install Pillow
    pip install git+https://github.com/Rafiot/python-magic.git@travis
    pip install git+https://github.com/CIRCL/PyCIRCLean.git
```

* Create the user and mtab for a RO filesystem

```
    useradd -m kitten
    chown -R kitten:kitten /home/kitten
    ln -s /proc/mounts /etc/mtab
```

* Copy the files

```
    sudo ./copy_to_final.sh /mnt/arm_rPi/
```

* Enable rc.local

```
    systemctl enable rc-local.service
```

