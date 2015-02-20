Daughter board schematic
========================


Note
======
the schematic has been created using GNU gEDA


Bill of material
================
Part list
- 3mm diameter low power LED Green
- 3mm diameter low power LED Yellow
- 3mm diameter low power LED Red
- PCB mounted SPST normally open push-button
- 26 (or 40) DIL poles pin-header female connector
- resistors (values are not critical)
    510 Ohm (3)
    16  KOhm
    1.3 KOhm

Mechanical design
=================
coordinate (0,0) is located at the PCB corner near the power supply connector.
the X axis is along the longest side.

hole_x1  =  3.50 ;		// hole center x offset from PCB edge (uSD side)
LedBtn_y = device_y - hole_y - 2.5 * 2.54 + tolerance ; // Y axis center position of LEDs and button(s)
R_Led_x  = hole_x1 + 29 + 2.54 + tolerance ;	// X axis center position of red LED
Y_Led_x  = R_Led_x - 3 * 2.54 ;				    // X axis center position of yellow LED
G_Led_x  = R_Led_x - 6 * 2.54 ;				    // X axis center position of green LED
Btn_x	 = R_Led_x + 4.5 * 2.54 ; 			    // X axis center position of button

The LEDs and the push-button are positioned on the 2.54 mm (0.1 inch) grid
Relative to he GPIO connector pin 1
along the X axis : -2 * 2.54 mm
along the Y axis (in multiples of 2.54 mm)
Green LED center : 4.5
Yellow LED center : 7.5
Red LED center : 10.5
Push-button center : 15.0

The LEDs have a 3 mm diameter
The top of the LEDs are 11 mm above the PCB





