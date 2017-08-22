Getting started
===============

If you'd like to work on the Python code that processes files for Circlean, you should
take a look at [PyCIRCLean](https://github.com/CIRCL/PyCIRCLean), specifically the
filecheck.py script. To get started contributing to Circlean, first, fork the project and
`git clone` your fork. Then, follow the instructions in [setup_with_proot.md](doc/setup_with_proot.md) to build an image. To make things easier, you can also download a
prebuilt image as mentioned in the README, and then mount and make modifications to this
image to test your changes.

The issue tracker
=================

If you find a bug or see a problem with PyCIRCLean, please open an issue in the Github
repo. We'll do our best to respond as quickly as possible. Also, feel free to contribute a
solution to any of the open issues - we'll do our best to review your pull request in a
timely manner. This project is in active development, so any contributions are welcome!

Dependencies
============
* Timidity for playing midi files
* Git for installing some Python dependencies
* 7Zip for unpacking archives
* Pmount and ntfs-3g for mounting usb key partitions
* Python 3 and pip for installing and running Python dependencies
* Python3-lxml for handling ooxml and other Office files in filecheck.py
* libjpeg-dev, libtiff-dev, libwebp-dev, liblcms2-dev, tcl-dev, tk-dev, and python-tk for various image formats (dependencies for pillow)
* Exifread for file metadata
* Pillow for handling images
* Olefile, oletools, and officedissector for handling various Office filetypes
* PyCIRCLean for main file handling code

Helper scripts
==============

Use the scripts in shell_utils/ as examples - do not run them blindly as you will most
probably have to change some constants/paths accordingly to your configuration.

IN ALL CASES, PLEASE READ THE COMMENTS IN THE SCRIPTS AT LEAST ONCE.

* proper_chroot.sh: uses qemu to chroot into a raspbian instance (.img or SD Card)
* prepare_rPI.sh: update the system, some configuration
* create_user.sh: create the user who will run the scripts, assign the proper sudo rights.
* copy_to_final.sh: populate the content of the directory fs/ in the image,
    contains a sample of dd command to write the image on the SD card.
    NOTE: TAKE CARE NOT TO USE THE WRONG DESTINATION


Running the tests
=================

* If you've made changes to the shell scripts, start by installing and running
[Shellcheck](https://github.com/koalaman/shellcheck).

* To emulate the Raspberry Pi hardware for testing, we'll be using
[Qemu](http://wiki.qemu.org/Main_Page), an open source machine emulator.
The "qemu" package available for Ubuntu/Debian includes all of the required
packages (including qemu-system-arm) except for qemu-user-static, which must
be installed separately.

```
    sudo apt-get install qemu qemu-user-static expect
```

* Get the qemu kernel for the image you are using:

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
