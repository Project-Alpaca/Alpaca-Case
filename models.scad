include <footprints.scad>

// Item selection
ITEM = "none"; // ["none", "printed_io_shield", "mounting_bracket", "corner_support", "pivot_holder"]

// Thickness of the mounting bracket
MOUNTING_WALL_THICKNESS = 8;

// Thickness of the box
BOX_THICKNESS = 6.35;

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

module corner_support() {
    
}

module pivot_holder() {
    
}

if (ITEM == "printed_io_shield") {
    printed_io_shield();
} else if (ITEM == "mounting_bracket") {
    mounting_bracket();
} else if (ITEM == "corner_support") {
    corner_support();
} else if (ITEM == "pivot_holder") {
    pivot_holder();
} else {
    echo("Usage: openscad -DITEM=model -o output.stl models.scad");
    echo("Accepted model: printed_io_shield, mounting_bracket, corner_support, pivot_holder");
}
