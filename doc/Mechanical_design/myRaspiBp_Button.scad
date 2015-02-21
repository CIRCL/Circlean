// raspberry pi model b+ case top button
//
//	v 1.2 - 06/02/2015 - initial release (MD)
//

// parameters
$fn = 50 ;

// parameters copied from myRaspiBp.scad
cover_inside_t = 2.00 ;	// box cover material thickess
clearance_z 	   = 2.00 ; // clearance on Z axis for daughter board
Btn_r    	   = 4.00 ;	// push button radius
foot_z         = 2.00 ;	// foot thickness 

// specific parameters
Btn_protrusion = 2.00 ;
Btn_foot_r_extension = 1.50 ;
Btn_top_rounding = 8 ;

// derived parameters
z_size = cover_inside_t + clearance_z + Btn_protrusion ;	// button z dimension
foot_r = Btn_r + Btn_foot_r_extension ;	// button foot radius 

// modules
include <shapes.scad>

// create device
union() {
	cylinder(h= foot_z, r= foot_r) ;

	difference() {
		translate([0, 0, z_size - Btn_top_rounding])  
			intersection() {
				cylinder(h = Btn_top_rounding, r = Btn_r) ;
				halfsphere (Btn_top_rounding) ; 
			}
		translate([0, 0, -foot_r/2]) 
			cube( size = [2*foot_r, 2*foot_r, foot_r], center=true) ;
	}
}




// --- end of file ---
