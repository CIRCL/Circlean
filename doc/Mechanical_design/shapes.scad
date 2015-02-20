// Advanced shapes
//
//	v 1.0 - 24/01/2015 - initial release (MD)
//	v 1.1 - 05/02/2014 - added half-sphere (MD)
//

module round_cube(x,y,z,r) {
	hull() {
		translate([r, r, 0]) 		cylinder(h = z, r = r) ; 
		translate([r, y - r, 0]) 		cylinder(h = z, r = r) ; 
		translate([x - r, r, 0]) 		cylinder(h = z, r = r) ; 
		translate([x - r, y - r, 0]) 	cylinder(h = z, r = r) ; 
	}
}

module round_belt(x,y,z,r,t) {
	// x, y, z, r are outer dimensions, thickness t is inwards
	difference() {
		round_cube(x, y, z, r) ;
		translate([t, t, 0]) round_cube(x-2*t, y-2*t, z, r-t) ;
	}
}

module spacers(x1,x2,y1,y2,z,r) {
	translate([x1, y1, 0]) 	cylinder(h = z, r = r) ; 
	translate([x1, y2, 0]) 	cylinder(h = z, r = r) ; 
	translate([x2, y1, 0]) 	cylinder(h = z, r = r) ; 
	translate([x2, y2, 0])	cylinder(h = z, r = r) ; 
}

module truncated_square_pyramid(x1,y1,x2,y2,z) {
	dx = (x1-x2)/2 ;
	dy = (y1-y2)/2 ;
	ax = 90 - atan2(z, dx) ;
	ay = 90 - atan2(z, dy) ;
	
	difference() {
		translate([0, 0, z/2])  cube(size=[x1,y1,z], center=true) ; 
		union() {
			translate([-x1/2, 0, 0]) 	 rotate([0, ax, 0]) 
				translate([-x1/2, 0, z]) cube(size=[x1,y1,2*z], center=true) ; 
			translate([ x1/2, 0, 0]) 	 rotate([0, -ax, 0]) 
				translate([ x1/2, 0, z]) cube(size=[x1,y1,2*z], center=true) ; 
			translate([0, -y1/2, 0]) 	 rotate([-ay, 0, 0]) 
				translate([0, -y1/2, z]) cube(size=[x1,y1,2*z], center=true) ;
			translate([0,  y1/2, 0]) 	 rotate([ ay, 0, 0]) 
				translate([0,  y1/2, z]) cube(size=[x1,y1,2*z], center=true) ;
		}
	}
}

module halfsphere( r) {
	difference() {
		sphere (r = r) ; 
		translate([0, 0, -r/2]) 
			cube(size=[2*r, 2*r, r], center=true) ;
	}	
}

// --- end of file ---
