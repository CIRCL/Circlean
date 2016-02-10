Notes
=====

* don't plug in USB devices with a hub because there's no way to tell it which
  is source and target - its the first drive enumerated (top port) that is the
  source and the second (bottom port) is the target
* don't turn it off without shutting down the system, when grooming is done it
  shuts down automatically: losing power while it's running can trash the OS
  on the SD cards because SD cards don't always like dirty shutdowns (ie power loss)
* Using a target usb stick that has a status light as long as the device has
  power is a really useful thing as there the other status lights on the groomer
  are less than indicative at times: because the 'OK' led on the rPi toggles on activity
  it can be off for a long time while processing something and only comes back
  on when that process finishes - hence why a USB that has some sort of LED activity
  when just plugged in (even if not reading or writing but while the USB port is
  powered) is helpful in determining when the process is finished - when
  the rPI is shutdown, the USB port power is shut off and that LED will also
  then be off on the USB device
* Use a larger target device as all zip files get unpacked and processed onto
  the target
* if you have an hdmi monitor plugged in you can watch what's happening for about
  30 minutes until the rPI's power saving kicks in and turns off the monitor
* if only one usb stick is present at power up, it doesn't groom and looks like
  a normal rPi
* if you want to ssh into the rPi username is 'pi' password 'raspberry' as per defaults


Technical notes
===============

* groomer script is in /opt/groomer/ with the other required files
* dependencies are libre-office and OpenJRE
* and the ip address is 192.168.1.89
* the groomer process is kicked off in /etc/rc.local
* the heavy lifting takes place or is dispatched from /opt/groomer/groomer.sh
  in that script file is what file types get processed (or if not listed there,
  get ignored)
* there are two ways pdf's can get handled -right now they have their text extracted
  to the target device, the other way copies it and extracts the text
* the pdf text extraction isn't perfect and is the slowest part of it, but should
  be able to handle unicode stuff and currently doesn't do image extraction from
  pdf's but could do that too


Discussion
==========

* however image exports of pdf pages only have the images and no text so it's not
  like saving each page to a jpg which would be a really handy and safe way of
  converting pdf's
* spread sheets and presentations get converted to pdfs to kill off any embedded
  macros and it's assumed that it's not producing evil pdf's on export but does
  nothing to sanitize any embedded links within those documents
* for spreadsheets, if they are longer than a page, only a page worth from that
  sheet is exported right from the middle of the sheet (ie the top and bottom of
  that sheet will get cut off and only the contents in the middle exported to pdf)
  dumb but i figure if you want to go back to the source because it's interesting
  enough on the groomed side of it, then you can take the extra precautions
* the groomed target only copies "safe" files, and does its best to convert any
  potential unsafe files to a safer format
* safe files being one that I know of that can't contain malicious embedded macros
  or other crap like that, and those than can get converted to something that wont
  contain code after conversion
