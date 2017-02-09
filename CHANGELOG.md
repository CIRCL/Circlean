Version 2.1 - 2017-02-02
- Updated to the newest version of Raspbian Jessie lite (January 11th 2017 release)
- NTFS files can now be mounted as source or destination keys
- Added udev rules that ensure the USB ports map deterministically to source and destination keys
- New debug flag and debug logging functionality to make working on Circlean without a monitor easier
- Turned off automatic display sleep

Version 2.0.2 - 2016-05-12
- Improve filename encoding

Version 2.0.1 - 2016-04-26
- Re-add [timidity](http://timidity.sourceforge.net/) so the MIDI files are played properly

Version 2.0 - 2016-04-26
- No critical bugs have been identified, this release uses the latest version of Raspbian Jessie lite, with all system updates

Version 2.0-BETA - 2015-11-06
- There a new beta version of CIRCLean which is a significant improvement from the latest version in term of speed and efficiency on low-end hardware like the first version of the Raspberry Pi. The new code base of CIRCLean is now based on [PyCIRCLean](https://github.com/CIRCL/PyCIRCLean)

Version 1.3 - 2015-05-27
- Fix a [critical security bug](https://www.circl.lu/projects/CIRCLean/security/advisory-01) related to [polyglot files](https://github.com/CIRCL/Circlean/issues/9) - thanks to the reporters ([Jann Horn](https://github.com/thejh), [seclab-solutions](http://www.seclab-solutions.com/))
- Use [PyCIRCLean](https://github.com/CIRCL/PyCIRCLean) for conversion
- Convert PDF files to PDF/A before converting to HTML

Version 1.2 - 2015-03-10

- Rollback the migration to Jessie and use Wheezy again: the only important dependency from Jessie was poppler, which is available in the backports
- Use the most recent security patches
- Do not wait for user input in case of password protected archive

Version 1.1.1 - 2014-10-26

- General upgrade of Debian to avoid the system to fail in case there is no HDMI cable connected.

Version 1.1 - 2014-10-01

- NTFS support added for USB key
- Updated to Debian Jessie including patches for [bash vulnerabilities CVE-2014-6271 - CVE-2014-7169](/pub/tr-27/)
- CIRCLean user are now removed from the sudoer

Version 1.0 - 2014-05-20

- Based on Raspbian Jessie
- Fully automated tests with Qemu
- Mimetype: support of PDF, Office documents, archives, windows executables
- Filesystem: USB keys have to be formated in vfat
- Support of multiple partitions
- Renaming of autorun.inf on the source key
- Operating system is read only
- Use pdf2htmlEX v0.11
