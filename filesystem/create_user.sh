#!/bin/bash

useradd -m kitten

echo "Cmnd_Alias GROOMER_CMDS = /home/kitten/kitten_mount_src, \
    /home/kitten/kitten_mount_dst, /home/kitten/kitten_umount" >> /etc/sudoers
echo "kitten  ALL=(ALL) NOPASSWD: GROOMER_CMDS" >> /etc/sudoers
