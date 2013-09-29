CIRCLean
========

![Cleaner in action](http://circl.lu/files/circlean_step5.jpg)

How To
======

[Graphical how-to and pre-build image](http://circl.lu/projects/CIRCLean/).

Why/What
========

This project aims to be used in case you got an USB key you do not know what is
contains but still want to have a look.

Work in progress, contributions welcome:

The content of the first key will be copyed or/and converted to the second key
following theses rules (based on the mime type):
- direct copy of plain text files (mime type: text/*)
- direct copy of audio files (mime type: audio/*)
- direct copy of image files (mime type: image/*)
- direct copy of video files (mime type: video/*)
- direct copy of example files (mime type: example/*)
- direct copy of message files (mime type: message/*)
- direct copy of model files (mime type: model/*)
- direct copy of multipart files (mime type: multipart/*)
- Copying or converting the application files this way (mime type: application/*):
  - pdf => HTML
  - msword|vnd.openxmlformats-officedocument.*|vnd.ms-*|vnd.oasis.opendocument* => pdf => html
  - *xml* => copy as a text file
  - x-dosexec (executable) => prepend and append DANGEROUS to the filename
  - x-gzip|x-tar|x-7z-compressed => compressed file
  - octet-stream => direct copy

Compressed files (zip|x-rar|x-bzip2|x-lzip|x-lzma|x-lzop|x-xz|x-compress|x-gzip|x-tar|*compressed):
- Unpacking of archives
- Recursively run the rules on the unpacked files

Usage
=====

0. Power off the device
1. Plug the untrusted key in the top usb slot of the Raspberry Pi
2. Plug your own key in the bottom usb slot
    
    *Note*: This key should be bigger than the original one because the archives
          will be copyed

3. Optional: connect the HDMI cable to a screen to see what happen
4. Connect the power to the micro USB

    *Note*: 5V, 700mA regulated power supply

5. Wait until you do not see any blinking green light on the board, or if you
   connected the HDMI cable, check the screen
   it's slow and can take 30-60 minutes depending on how many document
   conversions take place
6. Power off the device and disconnect the drives

Helper scripts
==============

You should use them as example when you are creating a new image and probably not
run them blindly as you will most probably have to change constraints accordingly to
your configuration.

IN ALL CASES, PLEASE READ THE COMMENTS IN THE SCRIPTS AT LEAST ONCE.

* proper_chroot.sh: uses qemu to chroot into a raspbian instance (.img or SD Card)
* prepare_rPI_builder.sh: update the system, add the repositories and install all
    the dependencies needed to compile poppler and pdf2htmlEX on a rPi
* update_builder.sh: compile the latest version of poppler from debian experimental,
    pull and compile the latest version of pdf2htmlEX from the git repository
* prepare_rPI.sh: update the system, install the dependencies of poppler and pdf2htmlEX,
    install poppler and pdf2htmlEX (the deb packages compiled in the builder)
* create_user.sh: create the user who will run the scripts, assign the proper sudo rights.
* copy_to_final.sh: populate the content of the directory fs/ in the image,
    contains a sample of dd command to write the image on the SD card.
    *TAKE CARE NOT USING THE WRONG DESTINATION*



