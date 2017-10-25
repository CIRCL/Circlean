Usage Notes
===========

* Don't plug in USB devices with a hub because there's no way to tell it which
  is source and target - its the first drive detected (top port) that is the
  source and the second (bottom port) is the target
* Don't turn it off without shutting down the system, when grooming is done it
  shuts down automatically: losing power while it's running can trash the OS
  on the SD cards because SD cards don't always like dirty shutdowns (ie power loss)
* Using a target usb stick that has a status light as long as the device has
  power is a really useful thing as there the other status lights on the groomer
  are less than indicative at times: because the 'OK' led on the RPi toggles on activity
  it can be off for a long time while processing something and only comes back
  on when that process finishes - hence why a USB that has some sort of LED activity
  when just plugged in (even if not reading or writing but while the USB port is
  powered) is helpful in determining when the process is finished - when
  the rPI is shutdown, the USB port power is shut off and that LED will also
  then be off on the USB device
* Use a larger target device as all zip files get unpacked and processed onto
  the target
* If you have an hdmi monitor plugged in you can watch what's happening for about
  30 minutes until the rPI's power saving kicks in and turns off the monitor
* If only one usb stick is present at power up, it doesn't groom and looks like
  a normal rPi
* If you want to ssh into the RPi username is 'pi' password 'raspberry' as per defaults


Technical notes
===============

* Groomer script is in /opt/groomer/ with the other required files and the ip
  address is 192.168.1.89
* The groomer process is kicked off in /etc/rc.local
* The heavy lifting is dispatched from /opt/groomer/groomer.sh
* All files processing is in filecheck.py


USB Ports
=========

If you connect multiple keys to the RPi, they will be detected in this order:

First: Top left
Second: Top right
Third: Bottom left
Forth: Bottom right

* As long as the source key (sda) is connected to the top left port, the
destination (sdb) can be connected on any other port.
