include <footprints.scad>

MOUNTING_WALL_THICKNESS = 8;

ITEM = undef;

module printed_panel() {
    $fn=25;
    linear_extrude(2) difference() {
        footprint_back_panel();
        footprint_back_panel_eng();
    }
}

module mounting_bracket() {
    module quadrant(r) {
        difference() {
            circle(r=r, center=true);
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
                        circle(d=3.2, center=true);
                    }
                }
                translate([0, 15]) {
                    if (nut) {
                        circle(d=6*(1/cos(30)), $fn=6);
                    } else {
                        circle(d=3.2, center=true);
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

if (ITEM == "printed_panel") {
    printed_panel();
} else if (ITEM == "mounting_bracket") {
    mounting_bracket();
} else {
    echo("Usage: openscad -D <model> -o <output.stl> models.scad");
    echo("Accepted model: printed_panel, mounting_bracket");
}
