Building the project
====================

To get started contributing to Circlean, first, fork the project and `git clone`
your fork. Then, follow the instructions in [README_setup.md](README_setup.md)
to build an image.

The issue tracker
=================

If you find a bug or see a problem with PyCIRCLean, please open an issue in the Github
repo. We'll do our best to respond as quickly as possible. Also, feel free to contribute a solution
to any of the open issues - we'll do our best to review your pull request in a timely manner.
This project is in active development, so any contributions are welcome!

Running the tests
=================

To emulate the Raspberry Pi hardware for testing, we'll be using
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
