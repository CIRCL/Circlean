// raspberry pi model b+ case
//
//	v 1.3 - 29/01/2015 - initial release + corrections (Marc Durvaux)
//  v 1.4 - 06/02/2015 - reduced Z clearance, hole opening for audio connector (audio_y),
//						added spacers on cover (MD)
//	v 1.5 - 08/02/2015 - fine tuning of connector hole Z position
//	v 1.7 - 10/02/2015 - fine tuning of holes, cutouts, spacers
//  v 1.8 - 21/07/2015 - bug correction : inverted riser parameters
//

// design control
test_fit = 0 ;		// set to one for test fit
top_bottom = 0 ;		// 0 = bottom only, 1 = top only, 2 = top & bottom
print = 1 ;			// set to one for printing configuration 

// parameters
$fn = 30 ;
tolerance = 0.50 ;		// 
wall_thickness  = 3.00 ;	// box wall thickness
rounding_radius = 5.00 ;	// box external wall corner rounding radius
cover_thickness = 3.00 ;	// box cover overall thickness at the edge
cover_inside_t  = 2.00 ;	// box cover material thickess
cover_overlap   = 5.00 ; // cover edge overlap height
edge_thickness  = 1.00 ;	// cover edge thickness (reduction in wall thickness)
clearance_z 	   = 2.00 ; // clearance on Z axis for daughter board
Top_spacer_r   = 3.00 ;  // radius of spacers on cover

//	Raspberry Pi dimensions (from mechanical specs, when available)
//		positions on PCB are from lower right corner (near power connector)
device_x = 85.00 ;		// pcb size exluding protruding connectors
device_y = 56.00 ;
device_z = 16.80 ;		// overall size, excluding bottom solders and USB connector top edge
riser_z  =  2.00 ;		// riser to cope with PCP bottom solders, located under PCB hole
riser_r  =  2.50 ; 		// riser radius (PCB mask hole radius = 3.1)
hole_x1  =  3.50 ;		// hole center x offset from PCB edge (uSD side)
hole_x2  = 58.00 + hole_x1 ; 	// hole center x offset from PCB edge (uSD side)
hole_y   =  3.50 ; 		// hole center y offset from PCB edge
uSD_x    =  2.70 ; 		// uSD card protrusion
uSD_w	 = 11.00 ;		// uSD card width
uSD_y	 = device_y/2;	// uSD center y offset
PWR_w	 =  8.00 ;		// micro-USB power connector width
PWR_z	 =  3.00 ;		// micro-USB power connector height over PCB
PWR_x	 = 10.60 ;		// micro-USB power connector center X offset from PCB edge
PWRplug_w = 11.00 ;		// micro-USB power plug width (used for outside wall stamping)
PWRplug_h =  8.00 ; 		// micro-USB power plug height (used for outside wall stamping)
PWRplug_d =  2.00 ;		// micro-USB power plug outside wall stamping depth
//audio_y  =  2.70 ;		// audio connector protrusion (masked audio)
audio_y  =  2*wall_thickness ;	// open audio connector
audio_w  =  5.80 ;		// audio connector external diameter (width)
audio_z  =  6.50 ; 		// audio connector height over PCB
audio_x  = 53.50 ;   	// audio connector center X offset from PCB edge
hdmi_y   =  1.00 ;		// hdmi connector protrusion
hdmi_w	 = 15.00 ;		// hdmi connector width
hdmi_z   =  7.00	;		// hdmi connector height over PCB
hdmi_x   = 32.00 ;		// hdmi connector center X offset from PCB edge
Ether_x  =  2.60 ;		// Ethernet connector protrusion
Ether_w  = 15.60 ;		// Ethernet connector width
Ether_z  = 15.00 ;		// Ethernet connector height over PCB lower side
Ether_y  = 10.25 ; 		// Ethernet connector center Y offset from PCB edge
USB_x    =  2.60 ; 		// USB connectors protrusion
USB_w    = 15.10 ;		// USB connectors width
USB_z	 = 16.60 ;  		// USB connecotrs height over PCB
USBl_y	 = 29.00 ;  		// left USB connector center Y offset from PCB edge (near Ethernet connector) 
USBr_y	 = 47.00 ;  		// right USB connector center Y offset from PCB edge
LedBtn_y = device_y - hole_y - 2.5 * 2.54 + tolerance ;	// Y axis center position of LEDs and button(s)
R_Led_x  = hole_x1 + 29 + 2.54 + tolerance ;				// X axis center position of red LED
Y_Led_x  = R_Led_x - 3 * 2.54 ;				// X axis center position of yellow LED
G_Led_x  = R_Led_x - 6 * 2.54 ;				// X axis center position of green LED
Btn_x	 = R_Led_x + 4.5 * 2.54 ; 			// X axis center position of button
Led_r	 =  1.50 ;		// LED radius + margin
Btn_r    =  4.00 ;		// push button radius
PCB_z    = 12.00 ;		// Daughter board top side to main PCB bottom side


// inside box dimension
in_x = device_x + uSD_x + USB_x + 2 * tolerance ;
in_y = device_y + 3 * tolerance ;
in_z = device_z + riser_z + clearance_z ;	
in_r = rounding_radius - wall_thickness ;
pcb_top = riser_z + device_z - USB_z ; 	// the USB connector is the highest component
spacer_z = pcb_top + 2*tolerance ;		// spacer on uSD side

// outside box dimension
box_x = in_x + 2 * wall_thickness ;
box_y = in_y + 2 * wall_thickness ;
box_z = in_z + wall_thickness ;		// without cover
cover_z = cover_thickness + cover_overlap ;		// box cover height
edge_offset = wall_thickness - edge_thickness ;	// box cover edge offset
USB_sep = USBr_y - USBl_y - USB_w + tolerance ;	// separation between USB connectors
mask_z = clearance_z - 2 * tolerance ;			// USB connector mask, cover side

// cover spacer to hold PCB in place
USB_spacer   = cover_thickness + clearance_z ;
Eth_spacer   = cover_thickness + clearance_z + device_z - Ether_z - tolerance ;
Con_spacer_x = wall_thickness + uSD_x + (device_x + hole_x2) / 2 ; 	// USB and Ethernet connectors
PCB_spacer   = cover_thickness + clearance_z + device_z - PCB_z - tolerance ;
PCB_spacer_x = wall_thickness + uSD_x + (G_Led_x + hole_x1) / 2 ; 

// print dimensions for control
echo(box_x = box_x) ;
echo(box_y = box_y) ;
echo(box_z = box_z) ;
echo(cover_z = cover_z) ;
echo(in_x = in_x) ;
echo(in_y = in_y) ;
echo(in_z = in_z) ;
echo(G_Led_x = G_Led_x) ;
echo(USB_sep = USB_sep) ;
echo(cover_z = cover_z) ;
echo(USB_spacer = USB_spacer) ;
echo(Eth_spacer = Eth_spacer) ;
echo(Con_spacer_x = Con_spacer_x) ;
echo(PCB_spacer = PCB_spacer) ;
echo(PCB_spacer_x = PCB_spacer_x) ;


// create device
if (test_fit == 1) {
	// test fit
	box_bottom() ;
	translate([0, 0, box_z - cover_overlap]) box_top() ;
} else {
	if (top_bottom < 1) {
		box_bottom() ; 
	} else {
		if (print == 1) { translate([0, box_y, cover_z]) rotate([180,0,0]) box_top() ; }
		else { box_top() ; }
		if (top_bottom > 1) {
			translate([0, -100, 0]) 
				box_bottom() ;
		}
	}
}

// modules
include <shapes.scad>

module right_cutouts() {		// position from PCB lower left corner
	bezel = 4*PWRplug_d ;	// to limit overhang angle for manufacturing

	translate([ PWR_x - tolerance - PWR_w/2, 0, tolerance]) 
		cube([ PWR_w + 2*tolerance, wall_thickness + tolerance, PWR_z + 4*tolerance]); 	// power
	translate([PWR_x, 0, PWR_z/2 + 3*tolerance])	rotate ([-90, 0,0]) 	// stamping for power plug	
		truncated_square_pyramid(PWRplug_w + bezel,PWRplug_h + bezel,PWRplug_w,PWRplug_h,PWRplug_d) ;

	translate([ hdmi_x - tolerance - hdmi_w/2, wall_thickness - hdmi_y -2*tolerance, 3*tolerance]) 
		cube([ hdmi_w + 2*tolerance, hdmi_y + 3*tolerance, hdmi_z + tolerance]) ;		// hdmi
	translate([audio_x, wall_thickness + tolerance, audio_z - audio_w/2 + 2*tolerance]) { 
		rotate ([90, 0, 0]) 	cylinder(h = audio_y, r = audio_w/2 + 3*tolerance) ; } 	// audio
}

module back_cutouts() {		// position on back side from PCB on Y axis
	translate([0, USBl_y - USB_w/2, USB_z/2])			// upper-left USB
		cube([wall_thickness +tolerance, USB_w +USB_sep, 2*USB_z]) ;	// Z size large enough!
	
	translate([0, USBr_y - USB_w/2, 0])				// lower-right USB
		cube([wall_thickness +tolerance, USB_w + 3*tolerance, 2*USB_z]) ;	// Z size large enough!
}

module box_bottom() {
	difference () {
		union() {	// box + added structures
			// basic box
			difference(){	
				round_cube(box_x, box_y, box_z, rounding_radius) ;
				translate([wall_thickness, wall_thickness, wall_thickness])
					round_cube(in_x, in_y, in_z, in_r) ;
			}
		
			// add inside structure
			translate([wall_thickness, wall_thickness, wall_thickness]) union() {
				// add uSD side wall spacer
				difference() {	
					cube([uSD_x, in_y, spacer_z]) ;
					translate([0, uSD_y - uSD_w, 0])
						cube([uSD_x, 2*uSD_w, spacer_z]) ;
				}
	
				// add PCB spacers
				translate([uSD_x, 0, 0])
					spacers(hole_x1 + tolerance, hole_x2 + tolerance, 
							hole_y + tolerance, device_y - hole_y + tolerance, 
							riser_z, riser_r) ;
			}
		}
	
		// substract cutouts
		union() {
			translate([wall_thickness + uSD_x, 0, wall_thickness + pcb_top]) 
				right_cutouts() ;
			translate([box_x - wall_thickness, wall_thickness, wall_thickness + pcb_top + 3*tolerance])
				back_cutouts() ;
			translate([edge_offset, edge_offset, box_z - cover_overlap])
				round_cube(box_x - 2*edge_offset, box_y - 2*edge_offset, cover_overlap, 
																rounding_radius - edge_offset) ;
		}
	}
}

module box_top() {
	difference () {
		union() {
			// basic cover
			difference(){	
				round_cube(box_x, box_y, cover_z, rounding_radius) ;
				union() {
					translate([wall_thickness, wall_thickness, 0])
						round_cube(in_x, in_y, cover_z - cover_inside_t, in_r) ;
					translate([0, 0, 0])
						round_belt(box_x, box_y, cover_overlap, rounding_radius, edge_offset) ;
					// USB connector cut-out
					translate([box_x - wall_thickness, wall_thickness + USBl_y - USB_w/2, 0])		
						cube([wall_thickness, USBr_y - USBl_y + tolerance, cover_overlap]) ;
				}
			}

			// add connector covers
			translate([box_x - wall_thickness, wall_thickness, cover_overlap]) 
			//translate([box_x - wall_thickness, wall_thickness, 0]) 
				union() {
					translate([0, USBl_y - USB_w/2 + 0.5*tolerance, -mask_z])
						cube([wall_thickness, USBr_y - USBl_y + USB_w + tolerance, mask_z]) ;
					translate([0, USBl_y + USB_w/2 + tolerance, -(mask_z + USB_z/2)  + 1.5*tolerance])
						cube([wall_thickness, USB_sep + USB_w + 0.5*tolerance, mask_z + USB_z/2]) ;
				}

			// add spacers
			translate([Con_spacer_x, wall_thickness + Ether_y, cover_z - Eth_spacer]) 
				cylinder(h = Eth_spacer, r = Top_spacer_r) ;
			translate([Con_spacer_x, wall_thickness + USBr_y, cover_z - USB_spacer]) 
				cylinder(h = USB_spacer, r = Top_spacer_r) ;
			translate([PCB_spacer_x, wall_thickness + LedBtn_y, cover_z - PCB_spacer]) 
				cylinder(h = PCB_spacer, r = Top_spacer_r) ;
			
		}

		// substract cutouts (holes for LEDs and push-button)
		translate([wall_thickness + uSD_x, wall_thickness, 0]) union() {
			translate([G_Led_x, LedBtn_y, 0])
				cylinder(h = cover_z, r = Led_r + tolerance) ;
			translate([Y_Led_x, LedBtn_y, 0])
				cylinder(h = cover_z, r = Led_r + tolerance) ;
			translate([R_Led_x, LedBtn_y, 0])
				cylinder(h = cover_z, r = Led_r + tolerance) ;
			translate([Btn_x,   LedBtn_y, 0])
				cylinder(h = cover_z, r = Btn_r + tolerance/2) ;
		}
	}
}

// --- end of file ---

