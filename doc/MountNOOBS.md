How to mount a SD card created by NOOBS on Ubuntu 15.04
=======================================================

Related to [this bug](https://github.com/raspberrypi/noobs/issues/262)

TL;DR
=====

```
    [122615.777412] usb-storage 4-1.2:1.0: USB Mass Storage device detected
    [122615.778614] scsi host26: usb-storage 4-1.2:1.0
    [122616.778643] scsi 26:0:0:0: Direct-Access     SD/MMC   Card  Reader     1.00 PQ: 0 ANSI: 0
    [122616.779319] sd 26:0:0:0: Attached scsi generic sg1 type 0
    [122617.072900] sd 26:0:0:0: [sdc] 30392320 512-byte logical blocks: (15.5 GB/14.4 GiB)
    [122617.075210] sd 26:0:0:0: [sdc] Write Protect is off
    [122617.075221] sd 26:0:0:0: [sdc] Mode Sense: 03 00 00 00
    [122617.077407] sd 26:0:0:0: [sdc] No Caching mode page found
    [122617.077424] sd 26:0:0:0: [sdc] Assuming drive cache: write through
    [122617.090405]  *sdc: [CUMANA/ADFS] sdc1 [ADFS] sdc1*
    [122617.101930] sd 26:0:0:0: [sdc] Attached SCSI removable disk
```


```
    $ fdisk -l  /dev/sdb

    Disk /dev/sdb: 14.5 GiB, 15560867840 bytes, 30392320 sectors
    Units: sectors of 1 * 512 = *512* bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0x000aa00f

    Device     Boot    Start      End  Sectors   Size Id Type
    /dev/sdb1           *8192*  1679687  1671496 816.2M  e W95 FAT16 (LBA)
    /dev/sdb2        1687552 30326783 28639232  13.7G 85 Linux extended
    /dev/sdb3       30326784 30392319    65536    32M 83 Linux
    /dev/sdb5        1695744  2744319  1048576   512M 83 Linux
    /dev/sdb6        2752512  2875391   122880    60M  c W95 FAT32 (LBA)
    /dev/sdb7        2883584 30326783 27443200  13.1G 83 Linux

    Partition table entries are not in disk order.
```

```
    mount -oloop,offset=$((512*8192)) /dev/sdb1 /mnt/sd/
```
