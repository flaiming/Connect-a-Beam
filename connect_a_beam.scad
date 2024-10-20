/* Connect-aBeam by Vojtěch Oram (vojtech@oram.cz)
 * licenced under MIT licence
 * © 2024 by Vojtěch Oram
 */

/*
 * Changelog
 * - 2024-04-13: v1.0 - Initial version
 *
 * - 2024-10-20: v1.1 - Refactored connector thickness
*/

/* [Base params] */

// Base size for the parts
base_size=20;

part_type = "beam"; // ["beam":Beam, "beam_curved": Curved beam, "connector":Connector, "2connect":Connector of connectors, "rod":Rod, "rod_spacer":Rod spacer, "wheel":Simple rounded wheel, "wheel_zipline":Zipline wheel, "differential_case": DIfferential case]
peg_space = base_size/10;
hole_spacing = base_size/5;
hole_d = base_size - hole_spacing*2;
clip_bevel = peg_space/3;
connector_wall_thickness = base_size/10;
tolerance = 0.25;
rounding = base_size/5;
$fn=60;

/* [Beam] */

beam_size_x = 3;
beam_size_y = 1;
beam_size_z = 1;
beam_holes_x = true;
beam_holes_y = true;
cylindric_edges = false;
beam_half_size=false;

connector_is_fixed = true;
connector_45_rotation = false;
connector_length_multiplier = 1;
connector_half_size=false;
connector_tight_fit=false;
connector_thickness=connector_wall_thickness + (connector_tight_fit ? 0.12 : 0);

/* [Wheel] */

ring_rounding = base_size/5;
wheel_type = "normal"; // ["small", "smaller", "normal"]
wheel_have_holes = true;
wheel_hole_fixed = false;

/* [Rod] */

rod_length = 60;
rod_hole_d = base_size / 5; // 4 mm for now

/* [Rod spacer] */

rod_spacer_fixed = 0;
rod_spacer_half = 0;

/* [Cog] */

cog_clearance=tolerance;
size_with_clearance=base_size - cog_clearance;

if (part_type == "connector") {
    rotate([90, 0, 0])
    connector(half_size=connector_half_size, fixed=connector_is_fixed);
    
} else if (part_type == "2connect") {

    2connect_wall = base_size/5;
    difference() {
        cylinder(h=base_size, d=hole_d + 2connect_wall);

        inner_cylinder(fix_cut_top=false, fix_cut_bottom=false, top_cut=false, fixed=false, half_size=true);
        
        translate([0, 0, base_size/2])
        inner_cylinder(fix_cut_top=false, fix_cut_bottom=false, top_cut=false, fixed=false, half_size=true);
      
    }

} else if (part_type == "beam") {
    difference() {
        beam_base(
            size_x=beam_size_x, 
            size_y=beam_size_y, 
            size_z=beam_size_z, 
            holes_x=beam_holes_x, 
            holes_y=beam_holes_y,
            half_size=beam_half_size
        );
    }

} else if (part_type == "rod") {
    difference() {
        rotate([0, 90, 0])
        rotate([0, 0, 90])
        rod(rod_length, rod_tolerance=-tolerance*2, do_holes=true);
    }

} else if (part_type == "rod_spacer") {
    rod_spacer(fixed=rod_spacer_fixed, half_size=rod_spacer_half);

} else if (part_type == "wheel") {
    if (wheel_type == "small") {
        wheel(base_size - tolerance*2, rounding=ring_rounding, hole_fixed=wheel_hole_fixed);
    } else if (wheel_type == "smaller") {
        wheel(base_size*0.8 - tolerance*2, rounding=ring_rounding, hole_fixed=wheel_hole_fixed);
    } else if (wheel_type == "normal") {
        wheel(base_size*1.5, rounding=ring_rounding, have_holes=wheel_have_holes, hole_fixed=wheel_hole_fixed);
    }

} else if (part_type == "wheel_zipline") {
    wheel(base_size - tolerance*2, rounding=ring_rounding, is_zipline=true);
     
} else if (part_type == "differential_case") {
    
    diff_x = base_size * 3;
    diff_y = diff_x;
    difference() {
        // body
        cube([diff_x, diff_y, base_size]);
        
        // hole in body
        translate([base_size/2, base_size/2, 0])
        cube([diff_x - base_size, diff_y - base_size, base_size]);

        // round holes
        for (x = [0:3]) {
            // left holes
            translate([0, base_size/2 + base_size * x, base_size/2])
            rotate([0, 90, 0])
            inner_cylinder(half_size=true, fix_cut_top=false);
            
            // right holes
            translate([diff_y - base_size/2, base_size/2 + base_size * x, base_size/2])
            rotate([0, 90, 0])
            inner_cylinder(half_size=true, fix_cut_bottom=false);
            
            // near holes
            translate([base_size/2 + base_size * x, base_size/2, base_size/2])
            rotate([90, 0, 0])
            inner_cylinder(half_size=true, fix_cut_bottom=false);
            
            // far holes
            translate([base_size/2 + base_size * x, diff_y, base_size/2])
            rotate([90, 0, 0])
            inner_cylinder(half_size=true, fix_cut_top=false);
        }
        
        
        // round corners
        two_corners_rounding();
        
        translate([diff_x, 0, 0])
        rotate([0, 0, 90])
        two_corners_rounding();
        
        translate([0, diff_y, 0])
        rotate([0, 0, -90])
        two_corners_rounding();
        
        translate([diff_x, diff_y, 0])
        rotate([0, 0, 180])
        two_corners_rounding();
    }

} else if (part_type == "beam_curved") {
    
    intersection() {
        difference() {
            cylinder(h=beam_size_z * base_size, d=beam_size_x * base_size * 2, $fn=100);

            // inner cylinder
            cylinder(h=beam_size_z * base_size, d=(beam_size_x-1) * base_size * 2, $fn=100);

            // holes for connectors
            for (i = [0: 5]) {
                rotate([0, 0, 22.5/2 + i * 22.5]) {
                    // connector Z
                    translate([beam_size_x * base_size - base_size/2, 0, 0])
                    inner_cylinder();

                    // connector X-Y
                    //translate([beam_size_x * base_size - base_size - 1, 0, base_size/2])
                    //rotate([90, 0, 90])
                    //inner_cylinder();
                }

            }

            // connector Y
            translate([beam_size_x*base_size - base_size/2, 0, base_size/2])
            rotate([-90, 0, 0])
            inner_cylinder();

            // connector X
            translate([0, beam_size_x*base_size - base_size/2, base_size/2])
            rotate([0, 90, 0])
            inner_cylinder();

            // corner rounding bottom right
            translate([(beam_size_x-1) * base_size, 0, 0])
            two_corners_rounding(size_z=beam_size_z);

            translate([beam_size_x * base_size, 0, 0])
            rotate([0, 0, 90])
            two_corners_rounding(size_z=beam_size_z);
            
            // left top corner rounding
            translate([0, (beam_size_x-1) * base_size, 0])
            two_corners_rounding(size_z=beam_size_z);
            
            translate([0, beam_size_x * base_size, 0])
            rotate([0, 0, -90])
            two_corners_rounding(size_z=beam_size_z);
        }

        cube([beam_size_x * base_size * 2, beam_size_x * base_size * 2, beam_size_z * base_size]);
    }
}

module inner_cylinder(fix_cut_top=true, fix_cut_bottom=true, top_cut=false, bevel=true, half_size=false, fixed=false) {
    cylinder_height=half_size ? base_size/2 : base_size;
    
    intersection() {
        union() {
            //botom wider part
            cylinder(h=peg_space/2 + (bevel ? 0 : clip_bevel/2), d=hole_d + peg_space);
            
            if (bevel){
                // bevel
                translate([0, 0, peg_space/2])
                cylinder(h=clip_bevel, d1=hole_d + peg_space, d2=hole_d);
            }

            cylinder(h=cylinder_height, d=hole_d);
        
            if (bevel) {
                //bevel again
                translate([0, 0, cylinder_height - peg_space/2 - clip_bevel])
                cylinder(h=clip_bevel, d1=hole_d, d2=hole_d + peg_space);
            }
            
            // top wider part
            translate([0, 0, cylinder_height - peg_space/2 - (bevel ? 0 : clip_bevel/2)])
            cylinder(h=peg_space/2 + (bevel ? 0 : clip_bevel/2), d=hole_d + peg_space);
            
            if (fix_cut_bottom) {
                // bottom stopper cut
                rotate([0, 0, 45])
                cylinder(h=peg_space, d=hole_d + peg_space*2, $fn=4);
                
                if (bevel) {
                    // bottom cut bevel
                    rotate([0, 0, 45])
                    translate([0, 0, peg_space])
                    cylinder(h=peg_space*3, d1=hole_d + peg_space*2, d2=0, $fn=4);    
                }
            }
            if (fix_cut_top) {
                if (bevel) {
                    // top cut bevel
                    translate([0, 0, cylinder_height - peg_space*3])
                    rotate([0, 0, 45])
                    cylinder(h=peg_space*2, d1=0, d2=hole_d + peg_space*2, $fn=4);
                }
                
                // top stopper cut
                translate([0, 0, cylinder_height - peg_space])
                rotate([0, 0, 45])
                cylinder(h=peg_space, d=hole_d + peg_space*2, $fn=4);
            }
            
            if (top_cut) {
                translate([0, (hole_d - peg_space)/2, 0])
                cylinder(h=base_size, d=peg_space*3, $fn=4);
            }
        }

        if (fixed) {
            translate([0, 0, base_size/2])
            cube([
                base_size, 
                hole_d - peg_space + tolerance*2, 
                base_size
            ], center=true);
        }
    }
}


module corner_rounding() {
    difference() {
        cube([rounding, rounding, rounding]);

        translate([rounding, rounding, rounding])
        sphere(d=2*sqrt(pow(rounding, 2) + pow(rounding, 2)), $fn=35);
    }
}

module two_corners_rounding(size_z=1) {
    // bottom
    corner_rounding();

    // top
    translate([0, 0, base_size*size_z])
    rotate([0, 90, 0])
    corner_rounding();

}

module left_side_rounding() {
    // closer left side rounding
    two_corners_rounding();

    // far left side rounding
    translate([0, base_size, 0])
    rotate([0, 0, -90])
    two_corners_rounding();
}


module beam_base(size_x=1, size_y=1, size_z=1, holes_x=true, holes_y=true, half_size=false) {
    base_height=half_size ? base_size/2 : base_size;
    difference() {
        if (cylindric_edges) {
            translate([base_size/2, base_size/2, 0])
            hull() {
                cylinder(h=base_height*size_z, d=base_size);
                translate([base_size * (size_x-1), 0, 0])
                cylinder(h=base_height*size_z, d=base_size);

                if (size_y > 1) {
                    translate([0, base_size * (size_y-1), 0]) {
                        cylinder(h=base_height*size_z, d=base_size);
                        translate([base_size * (size_x-1), 0, 0])
                        cylinder(h=base_height*size_z, d=base_size);
                    }
                }
            }
        } else {
            cube([base_size*size_x, base_size*size_y, base_height*size_z]);
        }

        if (!cylindric_edges) {
            corner_size_z = half_size ? size_z/2 : size_z;
        
            // closer left side rounding
            two_corners_rounding(size_z=corner_size_z);
            
            // far left side rounding
            translate([0, base_size * size_y, 0])
            rotate([0, 0, -90])
            two_corners_rounding(size_z=corner_size_z);
            
            // closer right side rounding
            translate([base_size * size_x, 0, 0])
            rotate([0, 0, 90])
            two_corners_rounding(size_z=corner_size_z);
            
            // far right side rounding
            translate([base_size * size_x, base_size * size_y, 0])
            rotate([0, 0, 180])
            two_corners_rounding(size_z=corner_size_z);
        }
        
        translate([base_size/2, base_size/2, 0])
        for (xx = [0:size_x - 1]) {
            for (yy = [0:size_y-1]) {
                for (zz = [0:size_z-1]) {
                    // Z hole
                    translate([base_size*xx, base_size*yy, base_size*zz])
                    inner_cylinder(half_size=half_size);

                    if (xx > 0 && xx < size_x-1 && yy > 0 && yy < size_y-1 && zz > 0 && zz < size_z-1) {
                        // Y hole without cut
                        if (holes_y) {
                            translate([base_size*xx, base_size/2 + base_size*yy, base_size*zz + base_size/2])
                            rotate([90, 0, 0])
                            inner_cylinder(top_cut=true, bevel=false, fix_cut_top=false, fix_cut_bottom=false);
                        }

                        // X hole without cut
                        if (holes_x) {
                            translate([base_size*xx - base_size/2, base_size*yy, base_size*zz + base_size/2])
                            rotate([90, 0, 90])
                            inner_cylinder(top_cut=true, bevel=false, fix_cut_top=false, fix_cut_bottom=false);
                        }
                    } else {
                        // Y hole
                        if (holes_y) {
                            translate([base_size*xx, base_size/2 + base_size*yy, base_size*zz + base_size/2])
                            rotate([90, 0, 0])
                            inner_cylinder(top_cut=true, bevel=false);
                        }

                        // X hole
                        if (holes_x) {
                            translate([base_size*xx - base_size/2, base_size*yy, base_size*zz + base_size/2])
                            rotate([90, 0, 90])
                            inner_cylinder(top_cut=true, bevel=false);
                        }
                    }
                } // end for zz 
            } // end for yy
        } // end for xx
        
    }

}


module connector_half(fixed=false, fixed_with_45_rotation=false, bottom_stopper=true, top_stopper=true, half_size=false) {

    connector_length = half_size ? base_size / 2 : base_size;
    difference() {
        union() {
            if (bottom_stopper) {
                // bottom stopper
                rotate_extrude(angle=360)
                translate([hole_d/2 - connector_wall_thickness - tolerance, 0, 0])
                rotate([180, 0, 90])
                polygon([
                    // A
                    [0, 0],
                    // B
                    [
                        0, 
                        bottom_stopper ? connector_wall_thickness + peg_space/2 : connector_thickness],
                    // C
                    [
                        peg_space/2 - tolerance/2, 
                        bottom_stopper ? connector_wall_thickness + peg_space/2 : connector_wall_thickness + tolerance/2],
                    // D
                    [
                        peg_space/2 + clip_bevel - tolerance/2, 
                        connector_thickness],
                    // E
                    [peg_space/2 + clip_bevel - tolerance/2, 0],
                ]);
            }
            
            // body
            rotate_extrude(angle=360)
            translate([hole_d/2 - connector_wall_thickness - tolerance, 0, 0])
            rotate([180, 0, 90])
            polygon([
                [0, 0],
                // D
                [
                    0, 
                    connector_thickness],
                // E
                [
                    top_stopper ? connector_length - peg_space/2 - clip_bevel + tolerance/2 : connector_length, 
                    connector_thickness],
                [
                    top_stopper ? connector_length - peg_space/2 - clip_bevel + tolerance/2 : connector_length, 
                    0
                ],
            ]);
            
            if (top_stopper) {
                // top stopper
                rotate_extrude(angle=360)
                translate([hole_d/2 - connector_wall_thickness - tolerance, 0, 0])
                rotate([180, 0, 90])
                polygon([
                    [
                        connector_length - peg_space/2 - clip_bevel + tolerance/2, 
                        0
                    ],
                    // E
                    [connector_length - peg_space/2 - clip_bevel + tolerance/2, connector_thickness],
                    // F
                    [connector_length - peg_space/2 - tolerance/2, connector_wall_thickness + peg_space/3],
                    // G
                    [connector_length - peg_space/4, connector_wall_thickness + peg_space/3],
                    // H
                    [connector_length, connector_wall_thickness/2],
                    // I
                    [connector_length, 0],
                ]);
            }
        }
        
        // side holes
        translate([0, 0, base_size/2 + peg_space*2])
        cube([base_size/6, 100, base_size], center=true);
    
    
    }
    if (fixed) {
        if (fixed_with_45_rotation) {
            rotate([0, 0, 45])
            cylinder(h=peg_space - tolerance, d=hole_d + peg_space*2 - tolerance, $fn=4);
        } else {
            cylinder(h=peg_space - tolerance, d=hole_d + peg_space*2 - tolerance, $fn=4);
        }
    }

    // full cylinder in the middle
    cylinder(h=base_size/6, d=hole_d - tolerance*2);
}


module connector(half_size=false, fixed=false) {
    intersection() {
        union() {

            if (connector_half_size) {
                connector_half(fixed=fixed);
                
            } else if (connector_length_multiplier > 0) {
                //connector_half(fixed=fixed, bottom_stopper=true, top_stopper=false);
            
                for (i = [0: connector_length_multiplier-1]) {
                    translate([0, 0, base_size * i])
                    connector_half(
                        bottom_stopper=i == 0, 
                        top_stopper=i == connector_length_multiplier-1, 
                        fixed=i == 0 ? fixed : false
                    );
                }

            }
            mirror([0, 0, 1])
            connector_half(fixed=fixed, fixed_with_45_rotation=connector_45_rotation, half_size=half_size);
            
        }
        cube([base_size*2, base_size - base_size/2, base_size*(connector_length_multiplier+1)*2], center=true);
    }

}


module ring(size, rounding) {
    hull()
    rotate_extrude(convexity = 10, $fn=100)
    translate([
        size - rounding,
        0, 
        0,
    ])
    circle(r = rounding , $fn=100);
}

module wheel(size, rounding, have_holes=false, is_zipline=false, hole_fixed=false) {
    difference() {
        hull() {
            translate([0, 0, rounding])
            ring(size, rounding);

            translate([0, 0, base_size - rounding])
            ring(size, rounding);
        }    
        
        inner_cylinder(fix_cut_top=false, fix_cut_bottom=false, fixed=hole_fixed);
        
        if (have_holes) {
            for (i = [0: 5]) {
                rotate([0, 0, i * 60])
                translate([base_size, 0, 0])
                inner_cylinder(fix_cut_top=false, fix_cut_bottom=false);
            }
        } 

        if (is_zipline) {
            // only for "small" wheel!
            translate([0, 0, base_size/2])
            rotate_extrude(convexity = 10, $fn=100)
            translate([
                base_size, 
                0, 
                0,
            ])
            circle(r = base_size*0.4 , $fn=100);
        }
    }
}

module wheel_zipline() {
    difference() {
        wheel();

        translate([0, 0, base_size/2])
        rotate_extrude(convexity = 10, $fn=100)
        translate([
            base_size, 
            0, 
            0,
        ])
        circle(r = base_size*0.4 , $fn=100);
    }
}


module rod_end_rounding() {
    difference() {
        translate([-hole_d/2, -hole_d/2, 0])
        cube([hole_d, hole_d, hole_d]);

        translate([0, 0, hole_d*3 / 2])
        sphere(d=hole_d*3, $fn=50);
    }
}


module rod(length, rod_tolerance=0, do_rounding=true, do_holes=true) {
    difference() {
        intersection() {
            cylinder(h=length, d=hole_d + rod_tolerance, $fn=50);
            translate([0, 0, length/2])
            cube([base_size*2, base_size - base_size/2 + tolerance, length], center=true);
        }
        
        if (do_holes) {
            // holes
            for (i = [1: length / base_size]) {
                translate([0, 0, base_size * i - base_size/2])
                rotate([0, 0, -90])
                rotate([0, 90, 0])
                cylinder(h=hole_d, d=rod_hole_d, center=true);
                
                translate([0, 0, base_size * i - base_size/4])
                rotate([0, 0, -90])
                rotate([0, 90, 0])
                cylinder(h=hole_d, d=rod_hole_d, center=true);
                
                translate([0, 0, base_size * i - base_size + base_size/4])
                rotate([0, 0, -90])
                rotate([0, 90, 0])
                cylinder(h=hole_d, d=rod_hole_d, center=true);
            }
        }
        
        if (do_rounding) {
            // bottom rounding
            rod_end_rounding();
            
            // top rounding
            translate([0, 0, length])
            rotate([180, 0, 0])
            rod_end_rounding();
        }
    }
}


module rod_spacer(fixed=false, half_size=false) {
    difference() {
        // body
        if (half_size) {
            cylinder(h=size_with_clearance/2, d=base_size*0.8);
        } else {
            cylinder(h=size_with_clearance, d=base_size*0.8);
        }
        
        // inner hole
        inner_cylinder(fix_cut_top=false, fix_cut_bottom=false, top_cut=false, bevel=true, half_size=half_size, fixed=fixed);
        
        // screw hole
        if (half_size) {
            // half stopper, 1 screw hole
            translate([0, 0, size_with_clearance/4])
            rotate([0, 90, 0])
            cylinder(h=size_with_clearance, d=rod_hole_d, center=true);
        } else {
            // full stopper, 3 screw holes
            translate([0, 0, size_with_clearance - size_with_clearance/4])
            rotate([0, 90, 0])
            cylinder(h=size_with_clearance, d=rod_hole_d, center=true);
            
            translate([0, 0, size_with_clearance - size_with_clearance/2])
            rotate([0, 90, 0])
            cylinder(h=size_with_clearance, d=rod_hole_d, center=true);
            
            translate([0, 0, size_with_clearance/4])
            rotate([0, 90, 0])
            cylinder(h=size_with_clearance, d=rod_hole_d, center=true);
        }

    }
}
