include <footprints.scad>
use <ext/LKP-Assy/hsi.scad>

$fn = ($preview ? undef : 32);

// Item selection
ITEM = "none"; // ["none", "printed_io_shield", "mounting_bracket", "corner_support", "pivot_holder", "oled_holder"]


/* [Legacy mounting bracket parameters] */
// Thickness of the mounting bracket
MOUNTING_WALL_THICKNESS = 8;


/* [Heat set inserts (HSI) parameters] */

// Diameter of the hole. Should be slightly smaller than the outer diameter of HSI.
HSI_D_MIN = 3.8;

// Depth of the hole or total length of the HSI.
HSI_DEPTH = 3.6;

// Hole depth multiplier for compensating oozing material during insertion. 1.5 should be good for most of the cases.
HSI_DEPTH_MULTIPLIER = 1.5;

// Diameter of the taper (set this and HSI_DEPTH_TAPER to -1 to disable taper)
HSI_D_TAPER = 4.3;

// Depth of the taper (set this and HSI_D_TAPER to-1 to disable taper)
HSI_DEPTH_TAPER = 1.0;


/* [Controller dimension parameters] */

// Thickness of the box
BOX_THICKNESS = 6.35;

// Thickness of the panel
PANEL_THICKNESS = 2.032;

// Outer height
OUTER_HEIGHT = 95;


/* [OLED module parameters] */

// Width of the OLED module
OLED_MODULE_WIDTH = 27.3;

// Height of the OLED module
OLED_MODULE_HEIGHT = 27.8;

// Screen-to-PCB thickness of the OLED module.
OLED_MODULE_THICKNESS = 4;

// PCB thickness of the OLED module.
OLED_MODULE_PCB_THICKNESS = 1.6;

// X offset of the mounting
OLED_MOUNTING_OFFSET_X = 2.15;

// Y offset of the mounting
OLED_MOUNTING_OFFSET_Y = 2.15;

// Distance between the 2 horizontal mounting holes.
OLED_MOUNTING_DIST_X = 23.0;

// Distance between the 2 vertical mounting holes.
OLED_MOUNTING_DIST_Y = 23.5;

// Mounting hole diameter
OLED_MOUNTING_DIA = 2.1;

// Clearance between the OLED module and the back plate. Account for screw head, angled pin header (if used) and components on the back of the OLED module here.
OLED_BOTTOM_CLEARANCE = 4;

// Expansion rate of the mounting pole contact point on the back plate. The mounting pole diameter is taken and multiplied by this number to calculate the diameter for mounting poles' contact point on the back plate.
POLE_CONTACT_EXPANSION_RATE = 3;

/* [Hidden] */

// Inner height
INNER_HEIGHT = OUTER_HEIGHT - BOX_THICKNESS - PANEL_THICKNESS;
OLED_EDGE_DIM = [OLED_MODULE_WIDTH, OLED_MODULE_HEIGHT];
OLED_MOUNTING_DIST = [OLED_MOUNTING_DIST_X, OLED_MOUNTING_DIST_Y];
OLED_MOUNTING_OFFSET = [OLED_MOUNTING_OFFSET_X, OLED_MOUNTING_OFFSET_Y];


module printed_io_shield() {
    $fn=25;
    linear_extrude(2) difference() {
        footprint_back_panel();
        footprint_back_panel_eng();
    }
}

module mounting_bracket() {
    module quadrant(r) {
        difference() {
            circle(r=r);
            polygon([
                [0, 0],
                [0, r],
                [-r, r],
                [-r, -r],
                [r, -r],
                [r, 0]
            ]);
        }
    }
    module _2d(nut=false) {
        difference() {
            quadrant(45);
            translate([15, 15]) {
                translate([15, 0]) {
                    if (nut) {
                        circle(d=6*(1/cos(30)), $fn=6);
                    } else {
                        circle(d=3.2);
                    }
                }
                translate([0, 15]) {
                    if (nut) {
                        circle(d=6*(1/cos(30)), $fn=6);
                    } else {
                        circle(d=3.2);
                    }
                }
            }
        }
    }
    
    module _single_wall() {
        union() {
            linear_extrude(MOUNTING_WALL_THICKNESS) _2d(true);
            linear_extrude(MOUNTING_WALL_THICKNESS/2) _2d();
        }
    }
    $fn=40;
    intersection() {
        union() {
            _single_wall();
            rotate([0, 0, 90])
                rotate([90, 0, 0]) _single_wall();
            mirror([0, 1, 0])
                rotate([90, 0, 0]) _single_wall();
        }
        sphere(r=45);
    }
}

module corner_support(inner_height=INNER_HEIGHT, profile="3d", hsi_d_min=HSI_D_MIN, hsi_depth=HSI_DEPTH*HSI_DEPTH_MULTIPLIER, hsi_d_taper=HSI_D_TAPER, hsi_depth_taper=HSI_DEPTH_TAPER) {
    triangle_side = 30;
    triangle_center = triangle_side / 4;
    if (profile == "3d") {
        difference() {
            linear_extrude(INNER_HEIGHT) polygon([
                [0, 0],
                [triangle_side, 0],
                [0, triangle_side],
            ]);
            translate([triangle_center, triangle_center]) {
                translate([0, 0, inner_height]) hsi(hsi_d_min, hsi_depth, hsi_d_taper, hsi_depth_taper);
                mirror([0, 0, 1]) hsi(hsi_d_min, hsi_depth, hsi_d_taper, hsi_depth_taper);
            }
            rotate([0, -90, 0]) {
                translate([inner_height / 4, triangle_side / 2, 0]) #hsi(hsi_d_min, hsi_depth, hsi_d_taper, hsi_depth_taper);
                translate([inner_height * 3 / 4, triangle_side / 2, 0]) #hsi(hsi_d_min, hsi_depth, hsi_d_taper, hsi_depth_taper);
            }
            rotate([90, 0, 0]) {
                translate([triangle_side / 2, inner_height / 4, 0]) #hsi(hsi_d_min, hsi_depth, hsi_d_taper, hsi_depth_taper);
                translate([triangle_side / 2, inner_height * 3 / 4, 0]) #hsi(hsi_d_min, hsi_depth, hsi_d_taper, hsi_depth_taper);
            }
        }
    } else if (profile == "drill-side") {
        translate([triangle_side / 2, inner_height / 4]) circle(d=3.4);
        translate([triangle_side / 2, inner_height * 3 / 4]) circle(d=3.4);
    } else if (profile == "drill-side-h") {
        translate([inner_height / 4, triangle_side / 2]) circle(d=3.4);
        translate([inner_height * 3 / 4, triangle_side / 2]) circle(d=3.4);
    } else if (profile == "drill-top") {
        translate([triangle_center, triangle_center]) circle(d=3.4);
    } else if (profile == "profile") {
        polygon([
            [0, 0],
            [triangle_side, 0],
            [0, triangle_side],
        ]);
    }
}

module pivot_holder(thickness=BOX_THICKNESS, profile="3d", hsi_d_min=HSI_D_MIN, hsi_depth=HSI_DEPTH*HSI_DEPTH_MULTIPLIER, hsi_d_taper=HSI_D_TAPER, hsi_depth_taper=HSI_DEPTH_TAPER, align_y="c") {
    module _x_clamp() {
        translate([-thickness/2, 0, -hsi_cube_size.y/2])
                rotate([0, -90, 0]) {
            linear_extrude(1) difference() {
                square(hsi_cube_size.y, center=true);
                circle(d=3.4);
            }
            translate([0, -hsi_cube_size.y/2+1, hsi_cube_size.y/4+1]) rotate([90, 0, 0]) linear_extrude(1) polygon([
                [hsi_cube_size.y/2, hsi_cube_size.y/4],
                [hsi_cube_size.y/2, -hsi_cube_size.y/4],
                [-hsi_cube_size.y/2, -hsi_cube_size.y/4],
            ]);
            translate([0, hsi_cube_size.y/2, hsi_cube_size.y/4+1]) rotate([90, 0, 0]) linear_extrude(1) polygon([
                [hsi_cube_size.y/2, hsi_cube_size.y/4],
                [hsi_cube_size.y/2, -hsi_cube_size.y/4],
                [-hsi_cube_size.y/2, -hsi_cube_size.y/4],
            ]);
        }
    }
    m3_nut_width_min = 5.5;
    hsi_y = max(hsi_d_min+2, m3_nut_width_min+0.5+2*1);
    hsi_cube_size = [max(hsi_d_min+2, thickness + 2*1 + hsi_y), hsi_y, hsi_depth+2];
    y_offset = align_y == "+" ? hsi_y / 2 : (align_y == "-" ? (-hsi_y / 2) : 0);

    if (profile == "3d") {
        translate([0, y_offset, 0]) {
            difference() {
                mirror([0, 0, 1]) linear_extrude(hsi_cube_size.z) square([hsi_cube_size.x, hsi_cube_size.y], center=true);
                hsi(hsi_d_min, hsi_depth, hsi_d_taper, hsi_depth_taper);
            }
            translate([0, 0, -hsi_cube_size.z]) _x_clamp();
            mirror([1, 0, 0]) translate([0, 0, -hsi_cube_size.z]) _x_clamp();
        }
    } else if (profile == "cut") {
        translate([-y_offset, -hsi_cube_size.z / 2]) square([hsi_cube_size.y, hsi_cube_size.z], center=true);
    } else if (profile == "drill") {
        translate([-y_offset, -hsi_cube_size.z - hsi_cube_size.y / 2]) circle(d=3.4);
    } else if (profile == "drill_vmount") {
        translate([0, y_offset]) circle(d=3.4);
    }
}

module adafruit_1185_dummy_shim() {
    import("ext/adafruit-1185.stl");
}

module oled_module_edges() {
    square(OLED_EDGE_DIM, center=true);
}

module oled_holder(thickness=BOX_THICKNESS, profile="3d", hsi_d_min=HSI_D_MIN, hsi_depth=HSI_DEPTH*HSI_DEPTH_MULTIPLIER, hsi_d_taper=HSI_D_TAPER, hsi_depth_taper=HSI_DEPTH_TAPER) {
    module _oled_mounting_pole() {
        cylinder(
            h=OLED_BOTTOM_CLEARANCE,
            r1=OLED_MOUNTING_DIA*POLE_CONTACT_EXPANSION_RATE/2,
            r2=OLED_MOUNTING_DIA/2
        );
        translate([0, 0, OLED_BOTTOM_CLEARANCE]) cylinder(h=OLED_MODULE_PCB_THICKNESS, d=OLED_MOUNTING_DIA);
    }

    holder_thickness = 2;
    parts_clearance = 4;

    mounting_center_clearance = [OLED_MOUNTING_DIA * POLE_CONTACT_EXPANSION_RATE, OLED_MOUNTING_DIA * POLE_CONTACT_EXPANSION_RATE] + [1, 1];
    mounting_size = OLED_MOUNTING_DIST + mounting_center_clearance;
    assy_thickness = holder_thickness + parts_clearance + OLED_MODULE_THICKNESS;
    echo(oled_assy_thickness=assy_thickness);
    sink = max(0, assy_thickness - thickness);
    echo(oled_sink=sink);

    module _oled_holder() {
        translate([0, 0, -holder_thickness]) linear_extrude(holder_thickness) {
            difference() {
                square(mounting_size, center=true);
                circle(d=3.2);
            }
        }
        translate([-OLED_MOUNTING_DIST.x/2, -OLED_MOUNTING_DIST.y/2])
            _oled_mounting_pole();
        translate([OLED_MOUNTING_DIST.x/2, -OLED_MOUNTING_DIST.y/2])
            _oled_mounting_pole();
        translate([OLED_MOUNTING_DIST.x/2, OLED_MOUNTING_DIST.y/2])
            _oled_mounting_pole();
        translate([-OLED_MOUNTING_DIST.x/2, OLED_MOUNTING_DIST.y/2])
            _oled_mounting_pole();
    }
    if (profile == "3d") {
        translate([0, 0, holder_thickness]) _oled_holder();
    } else if (profile == "3d-assy") {
        translate([0, 0, -sink]) {
            translate([0, 0, holder_thickness]) _oled_holder();
            pivot_holder(thickness=thickness, hsi_d_min=hsi_d_min, hsi_depth=hsi_depth, hsi_d_taper=hsi_d_taper, hsi_depth_taper=hsi_depth_taper);
        }
    } else if (profile == "cut") {
        translate([0, -sink/2]) {
            square([mounting_size.y, sink], center=true);
            translate([0, -sink/2]) {
                pivot_holder(profile="cut", hsi_d_min=hsi_d_min, hsi_depth=hsi_depth, hsi_d_taper=hsi_d_taper, hsi_depth_taper=hsi_depth_taper);
            }
        }
    } else if (profile == "drill") {
        translate([0, -sink]) pivot_holder(profile="drill");
    } else if (profile == "cut-top") {
        // TODO account for OLED module (if necessary)
        square(mounting_size, center=true);
    }
}


if (ITEM == "printed_io_shield") {
    printed_io_shield();
} else if (ITEM == "mounting_bracket") {
    mounting_bracket();
} else if (ITEM == "corner_support") {
    corner_support();
} else if (ITEM == "pivot_holder") {
    pivot_holder();
} else if (ITEM == "oled_holder") {
    oled_holder();
} else {
    echo("Usage: openscad -DITEM=model -o output.stl models.scad");
    echo("Accepted model: printed_io_shield, mounting_bracket, corner_support, pivot_holder");
}
