Various qemu startup commands
=============================

From https://www.raspberrypi.org/forums/viewtopic.php?f=29&t=37386
qemu-system-arm -kernel ~/qemu_vms/kernel-qemu-4.4.13-jessie -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1" -hda ~/qemu_vms/2016-09-23-raspbian-jessie-lite.img -redir tcp:5022::22


From https://github.com/dhruvvyas90/qemu-rpi-kernel
qemu-system-arm -kernel ~/qemu_vms/kernel-qemu-4.4.13-jessie -cpu arm1176 -m 256 -M versatilepb -serial stdio -append "root=/dev/sda2 rootfstype=ext4 rw" -hda ~/qemu_vms/2016-09-23-raspbian-jessie-lite.img


From http://pub.phyks.me/respawn/mypersonaldata/public/2014-05-20-11-08-01/
qemu-system-arm -kernel <<<path to kernel>>> -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw init=/bin/bash" -hda <<<path to disk image>>>


Others:
qemu-system-arm -kernel ~/qemu_vms/kernel-qemu-3.10.25-wheezy -cpu arm1176 -m 256 -M versatilepb -serial stdio -append "root=/dev/sda2 rootfstype=ext4 rw" -hda ~/qemu_vms/2015-02-16-raspbian-wheezy.img

qemu-system-arm -kernel qemu-rpi-kernel/kernel-qemu-3.10.25-wheezy -cpu arm1176 -m 256 -M versatilepb -serial stdio -append "root=/dev/sda2 rootfstype=ext4 rw" -hda 2015-02-16-raspbian-wheezy.img



Places to get raspbian base images:
===================================

For Raspbian Wheezy image:
wget https://downloads.raspberrypi.org/raspbian/images/raspbian-2015-02-17/2015-02-16-raspbian-wheezy.zip

For Raspbian Jessie Lite image:
wget https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2016-09-28/2016-09-23-raspbian-jessie-lite.zip




Traceback of the qemu failure on digitalocean
=============================================

pulseaudio: pa_context_connect() failed
pulseaudio: Reason: Connection refused
pulseaudio: Failed to initialize PA contextaudio: Could not init `pa' audio driver
ALSA lib confmisc.c:768:(parse_card) cannot find card '0'
ALSA lib conf.c:4259:(_snd_config_evaluate) function snd_func_card_driver returned error: No such file or directory
ALSA lib confmisc.c:392:(snd_func_concat) error evaluating strings
ALSA lib conf.c:4259:(_snd_config_evaluate) function snd_func_concat returned error: No such file or directory
ALSA lib confmisc.c:1251:(snd_func_refer) error evaluating name
ALSA lib conf.c:4259:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
ALSA lib conf.c:4738:(snd_config_expand) Evaluate error: No such file or directory
ALSA lib pcm.c:2239:(snd_pcm_open_noupdate) Unknown PCM default
alsa: Could not initialize DAC
alsa: Failed to open `default':
alsa: Reason: No such file or directory
ALSA lib confmisc.c:768:(parse_card) cannot find card '0'
ALSA lib conf.c:4259:(_snd_config_evaluate) function snd_func_card_driver returned error: No such file or directory
ALSA lib confmisc.c:392:(snd_func_concat) error evaluating strings
ALSA lib conf.c:4259:(_snd_config_evaluate) function snd_func_concat returned error: No such file or directory
ALSA lib confmisc.c:1251:(snd_func_refer) error evaluating name
ALSA lib conf.c:4259:(_snd_config_evaluate) function snd_func_refer returned error: No such file or directory
ALSA lib conf.c:4738:(snd_config_expand) Evaluate error: No such file or directory
ALSA lib pcm.c:2239:(snd_pcm_open_noupdate) Unknown PCM default
alsa: Could not initialize DAC
alsa: Failed to open `default':
alsa: Reason: No such file or directory
audio: Failed to create voice `lm4549.out'
Could not initialize SDL(No available video device) - exiting


Notes
=====
- The error message: it is probably not a big deal - can make them not being blocking by modifying https://github.com/CIRCL/Circlean/blob/master/tests/run.exp#L10
- https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=760365
- Could not initialize SDL(No available video device) - exiting <= this one is blocking
- I guess it is the vnc switch - requires x11 installed
- If you use a cloud instance, you will need to get qemu to open a port you can connect to with vnc
- The good thing of having VNC is that you can see what explodes when you're running the image
