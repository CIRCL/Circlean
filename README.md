CIRCLean
========

[![Chatroom](https://badges.gitter.im/CIRCLean/Lobby.svg)](https://gitter.im/CIRCLean/Lobby)

![CIRCLean logo](https://www.circl.lu/assets/images/logos/circlean.png)
![Cleaner in action](http://www.circl.lu/assets/images/CIRCLean/CIRCLean.png)

How To Install
==============

[Graphical how-to and pre-built image download](http://circl.lu/projects/CIRCLean/).

To prepare the SD card on Windows, you can use [Win32DiskImager](http://sourceforge.net/projects/win32diskimager/). On linux/macOS, use dd (see the how-to link for
instructions).

The current prebuilt image is based on the 1-11-17 release of Raspbian Jessie Lite.
The smallest SD card that Circlean can fit on is currently 4GB.

If you'd like to contribute to the project or build the image yourself, see
[contributing.md](CONTRIBUTING.md) and the [setup instructions](doc/setup_with_proot.md).
This is a work in progress - contributions are welcome.

FAQ
===

**Question**: I can't login, what is the password? 

**Answer**: For security reasons, it is **not possible** to login on the default image runinng CIRCLean/KittenGroomer (an attacker could exploit that functionality). 

The only thing the default image does is booting, processing the content of the source key, copying over the files to the destination key, and finally shutting down.



Why/What
========

This project aims to be useful when you get/find a USB key that you can't trust,
and you want to look at its contents without taking the risk of plugging it into
your computer directly. The official project page can be found at [https://www.circl.lu/projects/CIRCLean/]

The Raspberry Pi Foundation has a [blog post](https://www.raspberrypi.org/blog/kittengroomercirclean-data-security-for-journalists-and-activists/) with more information
about an older version of the project and details of the inspiration behind it.

CIRCLean is currently tested to work with USB keys that have FAT32, NTFS, or
ext2/3/4 filesystems (ext* filesystems can only be used as source keys, not destination
keys). Currently, exFAT is not supported due to lack of support for this format in pmount.
The vast majority of USB keys will be FAT32 or NTFS.

The content of the untrusted key will be copied or/and converted to the second
(blank) key following these rules (based on the mime type as determined by libmagic):
- Direct copy of:
  - Plain text files (mime type: text/*)
  - Audio files (mime type: audio/*)
  - Video files (mime type: video/*)
  - Example files (mime type: example/*)
  - Multipart files (mime type: multipart/*)
  - xml files, after being converted to text files
  - Octet-stream files
- Copied after verification:
  - Image files after verifying that they are not compression bombs (mime type: image/*)
  - PDF files, after marking as dangerous if they contain malicious content
  - msword|vnd.openxmlformats-officedocument.*|vnd.ms-*|vnd.oasis.opendocument*, after
    parsing with oletools/olefile and marking as dangerous if the parsing fails.
- Copied but marked as dangerous (DANGEROUS_filename_DANGEROUS)
  - Message files (mime type: message/*)
  - Model files (mime type: model/*)
  - x-dosexec (executable)
- Compressed files (zip|x-rar|x-bzip2|x-lzip|x-lzma|x-lzop|x-xz|x-compress|x-gzip|x-tar|*compressed):
  - Archives are unpacked, with the unpacking process stopped after 2 levels of archives
    to prevent archive bombs.
  - The above rules are applied recursively to the unpacked files.

Usage
=====

0. Power off the device and unplug all connections.
1. Plug the untrusted key in the top left USB slot of the Raspberry Pi.
2. Plug your own key in the bottom USB slot (or use any of the other slots if
there are more than 2).

    *Note*: This key should be bigger than the original one because any archives
          present on the source key will be expanded and copied.

3. Optional: connect the HDMI cable to a screen to monitor the process.
4. Connect the power to the micro USB port.

    *Note*: Use a 5V, 700mA+ regulated power supply

5. Wait until you do not see any blinking green light on the board, or if you
   connected the HDMI cable, check the screen. The process is slow and can take
   30-60 minutes depending on how many document conversions take place.
6. Power off the device and disconnect the drives.
