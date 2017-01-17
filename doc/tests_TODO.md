Expectations
============

Having a way to run after each commit a test on a list of samples and check if
the output and the logs are the ones expected by.
Easy way to check it on the rPi itself before releases.


What to think about
===================

* Exhaustive list of files, edge cases
* Check the logfiles

Ideas
=====

Source keys:
[DONE] Working documents, one / multiple partitions
- Non working documents: one / multiple partitions
- different FS on different partitions
- Non working FS
- Malicious documents (very slow, might break the conversions)

Destinations keys
[DONE] empty, big enough
- empty, too small
- broken
- not empty
- unmountable (wrong/broken fs)

Things to try out
=================

[DONE] Run the image in qemu, process USB keys from there

