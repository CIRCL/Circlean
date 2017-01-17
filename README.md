CIRCLean
========
![CIRCLean logo](https://www.circl.lu/assets/images/logos/circlean.png)
![Cleaner in action](http://www.circl.lu/assets/images/CIRCLean/CIRCLean.png)

How To
======

[Graphical how-to and pre-built image](http://circl.lu/projects/CIRCLean/).

To prepare the SD card on Windows, you can use [Win32DiskImager](http://sourceforge.net/projects/win32diskimager/).

And the linux way is in the command line, via dd (see in copy_to_final.sh)

If you'd like to contribute to the project or build the image yourself, see
[contributing](CONTRIBUTING.md) and the [setup readme](README_setup.md).

Why/What
========

This project aims to be useful when you get/find a USB key that you can't trust,
and you want to have a look at its contents without taking the risk of plugging it into your
main computer directly.

This is a work in progress - contributions are welcome:

The content of the first key will be copied or/and converted to the second key
following these rules (based on the mime type, as determined by libmagic):
- Direct copy of:
  - Plain text files (mime type: text/*)
  - Audio files (mime type: audio/*)
  - Video files (mime type: video/*)
  - Example files (mime type: example/*)
  - Multipart files (mime type: multipart/*)
  - *xml* files, after being converted to text files
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
1. Plug the untrusted key in the top USB slot of the Raspberry Pi.
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

Helper scripts
==============

You should use them as examples when you are creating a new image and probably not
run them blindly as you will most probably have to change parameters accordingly to
your configuration.

IN ALL CASES, PLEASE READ THE COMMENTS IN THE SCRIPTS AT LEAST ONCE.

* proper_chroot.sh: uses qemu to chroot into a raspbian instance (.img or SD Card)
* prepare_rPI.sh: update the system, some configuration
* create_user.sh: create the user who will run the scripts, assign the proper sudo rights.
* copy_to_final.sh: populate the content of the directory fs/ in the image,
    contains a sample of dd command to write the image on the SD card.
    NOTE: TAKE CARE NOT TO USE THE WRONG DESTINATION
