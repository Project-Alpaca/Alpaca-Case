include <ext/lasercut/lasercut.scad>
include <footprints.scad>
include <imperial.scad>
use <models.scad>

/* [Viewer Options] */
// Set this to true to get a 3D preview of the assembled controller
PREVIEW = true;
_PREVIEW = $preview == undef || $preview == true ? PREVIEW : false;

// Set this to true when PREVIEW=false generates layer for laser engraving (mainly for position of screw holes so they can be drilled later)
ENGRAVE = false;

// box1, box2, box3 are intended to be cut from plywood, panel1 is intended to be cut from acrylic (or PC)
SHEET = "box1"; // [box1, box2, box3, panel1]

// Size of panel sheet and box sheets (for reference only)
SHEET_PANEL = [in(24), in(18)];
SHEET_BOX = [in(24), in(16)];

/* [Preview Visibility] */
// Sets visibility of objects in preview

PREVIEW_FRONT_WALL = true;
PREVIEW_BACK_WALL = true;
PREVIEW_LEFT_WALL = true;
PREVIEW_RIGHT_WALL = true;
PREVIEW_TOP_COVER = true;
PREVIEW_TOP_PANEL = true;
PREVIEW_BOTTOM = true;
PREVIEW_MOUNTING = true;
PREVIEW_PIVOT = true;

/* [Hidden] */

// Dimension settings

// Thickness of sheets
BOX_THICKNESS = in(1/4);
PANEL_THICKNESS = mil(80);

// Size of the controller
OUTER_SIZE = [in(23), 225, 95];

FINGER_COUNT = [10, 5, 4];

MAIN_BUTTON_DIST = 125;
MAIN_BUTTON_OFFSET_X = 130;
MAIN_BUTTON_OFFSET_Y = 75;

// Controller model (SPM = SoftPot, LKP = Capacitive)
CONTROLLER_MODEL = "SPM";

// Internal use only. Do not change.

FRONT_WALL = 0;
BACK_WALL = 1;
LEFT_WALL = 2;
RIGHT_WALL = 3;
TOP_COVER = 4;
TOP_PANEL = 5;
BOTTOM = 6;
MOUNTING = 7;
PIVOT = 8;

module corner_screw_holes(x, y) {
    //translate([0, 0, 0]) circle(d=3.2);
    translate([x, 0, 0]) circle(d=3.2);
    translate([0, y, 0]) circle(d=3.2);
}

// Botton side (vector cutting layer)
module box_bottom() {
    pivot_tab_x = OUTER_SIZE.x/2-BOX_THICKNESS/2;
    pivot_tab_y = OUTER_SIZE.y;
    lasercutoutSquare(thickness=BOX_THICKNESS,
                      x=OUTER_SIZE.x,
                      y=OUTER_SIZE.y,
                      bumpy_finger_joints=[
                          [UP, 1, FINGER_COUNT.x],
                          [DOWN, 1, FINGER_COUNT.x],
                          [LEFT, 1, FINGER_COUNT.y],
                          [RIGHT, 1, FINGER_COUNT.y]
                      ],
                      simple_tabs=[
                          [UP, -BOX_THICKNESS/2, OUTER_SIZE.y],
                          [DOWN, OUTER_SIZE.x+BOX_THICKNESS/2, 0],
                          [LEFT, 0, -BOX_THICKNESS/2],
                          [RIGHT, OUTER_SIZE.x, BOX_THICKNESS/2+OUTER_SIZE.y],
                      ],
                      simple_tab_holes=[
                          [MID, pivot_tab_x, pivot_tab_y/6-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*2/6-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*3/6-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*4/6-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*5/6-BOX_THICKNESS/2]
                      ]);
}

// Bottom side (engraving layer)
module eng_box_bottom() {
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([OUTER_SIZE.x-15, OUTER_SIZE.y-15, 0]) corner_screw_holes(-15, -15);
    translate([OUTER_SIZE.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([15, OUTER_SIZE.y-15, 0]) corner_screw_holes(15, -15);
}

// Top side (vector cutting layer)
module box_top() {
    cut_x = (635-OUTER_SIZE[0])/2;
    pivot_tab_x = OUTER_SIZE.x/2-BOX_THICKNESS/2;
    pivot_tab_y = OUTER_SIZE.y;
    difference() {
        lasercutoutSquare(thickness=BOX_THICKNESS,
                          x=OUTER_SIZE.x,
                          y=OUTER_SIZE.y,
                          simple_tab_holes=[
                              [MID, pivot_tab_x, pivot_tab_y/6-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*2/6-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*3/6-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*4/6-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*5/6-BOX_THICKNESS/2]
                          ],
                          circles_remove=[
                              [ARCADE_BUTTON_100MM_HOLE_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x, MAIN_BUTTON_OFFSET_Y],
                              [ARCADE_BUTTON_100MM_HOLE_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x+MAIN_BUTTON_DIST, MAIN_BUTTON_OFFSET_Y],
                              [ARCADE_BUTTON_100MM_HOLE_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x+MAIN_BUTTON_DIST*2, MAIN_BUTTON_OFFSET_Y],
                              [ARCADE_BUTTON_100MM_HOLE_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x+MAIN_BUTTON_DIST*3, MAIN_BUTTON_OFFSET_Y],
                              // TODO make this parametric
                              [ARCADE_BUTTON_100MM_NOTCH_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x, MAIN_BUTTON_OFFSET_Y+ARCADE_BUTTON_100MM_HOLE_DIA/2],
                              [ARCADE_BUTTON_100MM_NOTCH_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x, MAIN_BUTTON_OFFSET_Y-ARCADE_BUTTON_100MM_HOLE_DIA/2],
                              [ARCADE_BUTTON_100MM_NOTCH_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x+MAIN_BUTTON_DIST, MAIN_BUTTON_OFFSET_Y+ARCADE_BUTTON_100MM_HOLE_DIA/2],
                              [ARCADE_BUTTON_100MM_NOTCH_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x+MAIN_BUTTON_DIST, MAIN_BUTTON_OFFSET_Y-ARCADE_BUTTON_100MM_HOLE_DIA/2],
                              [ARCADE_BUTTON_100MM_NOTCH_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x+MAIN_BUTTON_DIST*2, MAIN_BUTTON_OFFSET_Y+ARCADE_BUTTON_100MM_HOLE_DIA/2],
                              [ARCADE_BUTTON_100MM_NOTCH_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x+MAIN_BUTTON_DIST*2, MAIN_BUTTON_OFFSET_Y-ARCADE_BUTTON_100MM_HOLE_DIA/2],
                              [ARCADE_BUTTON_100MM_NOTCH_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x+MAIN_BUTTON_DIST*3, MAIN_BUTTON_OFFSET_Y+ARCADE_BUTTON_100MM_HOLE_DIA/2],
                              [ARCADE_BUTTON_100MM_NOTCH_DIA/2, MAIN_BUTTON_OFFSET_X-cut_x+MAIN_BUTTON_DIST*3, MAIN_BUTTON_OFFSET_Y-ARCADE_BUTTON_100MM_HOLE_DIA/2]
                          ]);
        translate([-cut_x, 0, 0])
            translate([MAIN_BUTTON_OFFSET_X, MAIN_BUTTON_OFFSET_Y, 0])
            translate([1.5*MAIN_BUTTON_DIST, 115, 0])
            %square([510, 64], true);
            //translate([0, 10-32-6, 0])
            //linear_extrude(BOX_THICKNESS) {
            //    footprint_softpot_mount(invert=true, holes=false);
            //}
    }
}

// Top side (engraving layer)
module eng_box_top() {
    cut_x = (635-OUTER_SIZE[0])/2;
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([OUTER_SIZE.x-15, OUTER_SIZE.y-15, 0]) corner_screw_holes(-15, -15);
    translate([OUTER_SIZE.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([15, OUTER_SIZE.y-15, 0]) corner_screw_holes(15, -15);

    translate([-cut_x, 0, 0])
        translate([MAIN_BUTTON_OFFSET_X, MAIN_BUTTON_OFFSET_Y, 0])
        translate([1.5*MAIN_BUTTON_DIST, 115, 0]) {
            // Slider position reference
            %square([510, 64], true);
            // SoftPot reference
            translate([0, 10-32-6, 0]) {
                //%square([500, 20], true);
                footprint_softpot_mount(invert=true, tail_cut=false);
            }
        }
}

// Left/right side (vector cutting layer)
module box_side_lr() {
    lasercutoutSquare(thickness=BOX_THICKNESS,
                      x=OUTER_SIZE.z,
                      y=OUTER_SIZE.y,
                      bumpy_finger_joints=[
                          [UP, 1, FINGER_COUNT.z],
                          //[RIGHT, polarity_lr, FINGER_COUNT.y]
                      ],
                      finger_joints=[
                          [DOWN, 1, FINGER_COUNT.z],
                          [LEFT, 0, FINGER_COUNT.y],
                      ]);
}

// Left/right side (engraving layer)
module eng_box_side_lr() {
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([OUTER_SIZE.z-PANEL_THICKNESS-BOX_THICKNESS-15, OUTER_SIZE.y-15, 0]) corner_screw_holes(-15, -15);
    translate([OUTER_SIZE.z-PANEL_THICKNESS-BOX_THICKNESS-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([15, OUTER_SIZE.y-15, 0]) corner_screw_holes(15, -15);
}

// Front side (vector cutting layer)
module box_side_f() {
    // TODO auxiliary control panel
    pivot_tab_x = OUTER_SIZE.x/2-BOX_THICKNESS/2;
    pivot_tab_y = OUTER_SIZE.z-PANEL_THICKNESS-BOX_THICKNESS;
    difference() {
        lasercutoutSquare(thickness=BOX_THICKNESS,
                          x=OUTER_SIZE.x,
                          y=OUTER_SIZE.z,
                          bumpy_finger_joints=[
                              [LEFT, 1, FINGER_COUNT.z],
                          ],
                          finger_joints=[
                              [DOWN, 0, FINGER_COUNT.x],
                              [RIGHT, 1, FINGER_COUNT.z]
                          ],
                          simple_tab_holes=[
                              [MID, pivot_tab_x, pivot_tab_y/4-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*2/4-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*3/4-BOX_THICKNESS/2],
                          ]);
        translate([5/8*OUTER_SIZE.x, OUTER_SIZE.z/2, 0])
            linear_extrude(BOX_THICKNESS) {
                footprint_1602();
                translate([70+3, -1.5]) footprint_re();
            }
        translate([55/64*OUTER_SIZE.x, OUTER_SIZE.z/2, 0])
            linear_extrude(BOX_THICKNESS)
            footprint_control();
    }
}

// Front side (engraving layer)
module eng_box_side_f() {
    translate([5/8*OUTER_SIZE.x, OUTER_SIZE.z/2, 0]) {
        footprint_1602_eng();
        translate([70+3, -1.5]) footprint_re_eng();
    }
    translate([OUTER_SIZE.x-15, OUTER_SIZE.z-PANEL_THICKNESS-BOX_THICKNESS-15, 0]) corner_screw_holes(-15, -15);
    translate([15, OUTER_SIZE.z-PANEL_THICKNESS-BOX_THICKNESS-15, 0]) corner_screw_holes(15, -15);
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([OUTER_SIZE.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([55/64*OUTER_SIZE.x, OUTER_SIZE.z/2, 0])
        footprint_control_eng();
}

// Back side (vector cutting layer)
module box_side_b() {
    pivot_tab_x = OUTER_SIZE.x/2-BOX_THICKNESS/2;
    pivot_tab_y = OUTER_SIZE.z-PANEL_THICKNESS-BOX_THICKNESS;
    difference() {
        lasercutoutSquare(thickness=BOX_THICKNESS,
                          x=OUTER_SIZE.x,
                          y=OUTER_SIZE.z,
                          bumpy_finger_joints=[
                              [RIGHT, 0, FINGER_COUNT.z]
                          ],
                          finger_joints=[
                              [DOWN, 1, FINGER_COUNT.x],
                              [LEFT, 0, FINGER_COUNT.z],
                              
                          ],
                          simple_tab_holes=[
                              [MID, pivot_tab_x, pivot_tab_y/4-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*2/4-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*3/4-BOX_THICKNESS/2],
                          ]);
        translate([OUTER_SIZE.x/4*3, OUTER_SIZE.z/3]) {
            linear_extrude(BOX_THICKNESS) footprint_back_panel_cutout();
        }
    }
}

// Back side (engraving layer)
module eng_box_side_b() {
    translate([OUTER_SIZE.x-15, OUTER_SIZE.z-PANEL_THICKNESS-BOX_THICKNESS-15, 0]) corner_screw_holes(-15, -15);
    translate([15, OUTER_SIZE.z-PANEL_THICKNESS-BOX_THICKNESS-15, 0]) corner_screw_holes(15, -15);
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([OUTER_SIZE.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([OUTER_SIZE.x/4*3, OUTER_SIZE.z/3]) {
        footprint_back_panel_cutout_eng();
    }
}

// Pivot (legacy)
module box_pivot() {
    x = OUTER_SIZE.z-PANEL_THICKNESS-BOX_THICKNESS;
    y = OUTER_SIZE.y;
    lasercutoutSquare(thickness=BOX_THICKNESS,
                      x=x,
                      y=y,
                      simple_tabs=[
                          [UP, x/4, y],
                          [UP, x*2/4, y],
                          [UP, x*3/4, y],
                          [DOWN, x/4, 0],
                          [DOWN, x*2/4, 0],
                          [DOWN, x*3/4, 0],
                          [LEFT, 0, y/6],
                          [LEFT, 0, y*2/6],
                          [LEFT, 0, y*3/6],
                          [LEFT, 0, y*4/6],
                          [LEFT, 0, y*5/6],
                          // TODO this does not work well, bug in lasercut
                          // library?
                          [RIGHT, x, y/6],
                          [RIGHT, x, y*2/6],
                          [RIGHT, x, y*3/6],
                          [RIGHT, x, y*4/6],
                          [RIGHT, x, y*5/6]
                      ],
                      circles_remove=[
                          [20, x/2, y/2]
                      ]);
}

// Horizontal pivot (between slider and main buttons)
module box_pivot_h() {
    
}

// Vertical pivot (between main buttons)
module box_pivot_v_button() {
    
}

// Support platform for capacitive slider module
module box_lkp_platform() {
    
}

// Stock panel shape. Build using this may be more challenging than using the
// simplified rectangular panel
module stock_ft_panel() {
    polygon([
        [0, 0],
        [635, 0],
        [710, 150],
        [710, 225],
        [-75, 225],
        [-75, 150]
    ]);
}

// TODO more integrations to the new system
module rect_ft_panel() {
    _l = 635;
    _h = 225;

    // TODO move screw holes to drill layer
    //module _screw_holes(x, y) {
    //    translate([x, 0, 0]) circle(d=3.5);
    //    translate([0, y, 0]) circle(d=3.5);
    //}
    //difference() {
        square([_l, _h]);
    //    translate([15, 15, 0]) _screw_holes(15, 15);
    //    translate([_l-15, _h-15, 0]) _screw_holes(-15, -15);
    //    translate([_l-15, 15, 0]) _screw_holes(-15, 15);
    //    translate([15, _h-15, 0]) _screw_holes(15, -15);
    //}
}

module cuts() {
    for (i=[0:MAIN_BUTTON_DIST:MAIN_BUTTON_DIST*3]) {
        translate([i, 0, 0]) {
            // Button position reference
            //%circle(d=ARCADE_BUTTON_100MM_DIA);
            footprint_arcade_button_100mm();
        }
        
    }
    //translate([1.5*MAIN_BUTTON_DIST, 115, 0]) {
    //    // Slider position reference
    //    %square([510, 64], true);
        // SoftPot reference
    //    translate([0, 10-32-6, 0]) {
    //        //%square([500, 20], true);
    //        footprint_softpot_mount(invert=true);
    //    }
    //}
}

module softpot_mount() {
    footprint_softpot_mount();
}

module panel_base() {
    translate([-MAIN_BUTTON_OFFSET_X, -MAIN_BUTTON_OFFSET_Y, 0]) {
        // Panel reference
        %stock_ft_panel();
        rect_ft_panel();
    }
}

module panel() {
    cut_x = (635-OUTER_SIZE.x)/2;
    cut_y = (225-OUTER_SIZE.y);
    translate([-cut_x, 0, 0]) difference() {
        translate([MAIN_BUTTON_OFFSET_X, MAIN_BUTTON_OFFSET_Y, 0]) difference() {
            panel_base();
            cuts();
            translate([1.5*MAIN_BUTTON_DIST, 115, 0]) translate([0, 10-32-6, 0]) footprint_softpot_mount(holes=false);
        }
        square([(635-OUTER_SIZE[0])/2, 225]);
        translate([635-cut_x, 0, 0]) square([(635-OUTER_SIZE[0])/2, 225]);
        if (cut_y > 0) {
            translate([0, 225-cut_y, 0]) square([635, cut_y]);
        }
    }
}

module eng_panel() {
    cut_x = (635-OUTER_SIZE[0])/2;

    translate([-cut_x, 0, 0]) {
        translate([MAIN_BUTTON_OFFSET_X, MAIN_BUTTON_OFFSET_Y, 0]) translate([1.5*MAIN_BUTTON_DIST, 115, 0]) {
            // Slider position reference
            %square([510, 64], true);
            // SoftPot reference
            translate([0, 10-32-6, 0]) {
                %square([500, 20], true);
                footprint_softpot_mount(invert=true, tail_cut=false);
            }
        }
    }
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([OUTER_SIZE.x-15, OUTER_SIZE.y-15, 0]) corner_screw_holes(-15, -15);
    translate([OUTER_SIZE.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([15, OUTER_SIZE.y-15, 0]) corner_screw_holes(15, -15);
}

module inv_panel() {
    cut_x = (635-OUTER_SIZE[0])/2;
    translate([-cut_x, 0, 0])
        translate([MAIN_BUTTON_OFFSET_X, MAIN_BUTTON_OFFSET_Y, 0])
        translate([1.5*MAIN_BUTTON_DIST, 115, 0])
        translate([0, 10-32-6, 0]) {
            square([520-1, 40-1], center=true);
        }
}

module panel1_2d() {
    %square(SHEET_PANEL);
    if (ENGRAVE) {
        eng_panel();
    } else {
        panel();
    }
}

module box1_2d() {
    %square(SHEET_BOX);
    if (ENGRAVE) {
        eng_box_top();
        translate([BOX_THICKNESS, BOX_THICKNESS*2+OUTER_SIZE.y])
            eng_box_side_f();
    } else {
        projection() {
            box_top();
            translate([BOX_THICKNESS, BOX_THICKNESS*2+OUTER_SIZE.y])
                box_side_f();
            //translate([BOX_THICKNESS, BOX_THICKNESS*2+OUTER_SIZE.y, 0]) box_bottom();
        }
    }
}

module box2_2d() {
    %square(SHEET_BOX);
    if (ENGRAVE) {
        // TODO
        translate([BOX_THICKNESS, BOX_THICKNESS])
            eng_box_bottom();
        translate([BOX_THICKNESS, BOX_THICKNESS*3+OUTER_SIZE.y])
            eng_box_side_b();
    } else {
        projection() {
            translate([BOX_THICKNESS, BOX_THICKNESS]) box_bottom();
            translate([BOX_THICKNESS, BOX_THICKNESS*3+OUTER_SIZE.y])
                box_side_b();
        }
    }
}

module box3_2d() {
    %square(SHEET_BOX);
    if (ENGRAVE) {
        translate([BOX_THICKNESS*2+OUTER_SIZE.y, 0])
        rotate([0, 0, 90]) {
            translate([BOX_THICKNESS, BOX_THICKNESS]) eng_box_side_lr();
            translate([BOX_THICKNESS*3+OUTER_SIZE.z, BOX_THICKNESS])
                eng_box_side_lr();
        }
    } else {
        translate([BOX_THICKNESS*2+OUTER_SIZE.y, 0])
        rotate([0, 0, 90]) {
            translate([BOX_THICKNESS, BOX_THICKNESS]) projection() box_side_lr();
            translate([BOX_THICKNESS*3+OUTER_SIZE.z, BOX_THICKNESS]) {
                projection() box_side_lr();
                translate([BOX_THICKNESS*2+OUTER_SIZE.z, 0])
                    projection() box_pivot();
            }
        }
    }
}

if (_PREVIEW) {
    //echo("WARNING: This is just a preview. Set PREVIEW=false to get laser cuttable shapes.");
    if (PREVIEW_BOTTOM) {
        color("Green",0.5) difference() {
            box_bottom();
            linear_extrude(BOX_THICKNESS) eng_box_bottom();
        }
    }

    if (PREVIEW_PIVOT) {
        color("Red", 0.5)
            translate([OUTER_SIZE.x/2+BOX_THICKNESS/2,0,BOX_THICKNESS])
            rotate([0, -90, 0])
                box_pivot();
    }

    if (PREVIEW_MOUNTING) {
        translate([0, 0, OUTER_SIZE.z-PANEL_THICKNESS])
            rotate([-90, 0, 0])
            mounting_bracket();
        translate([0, OUTER_SIZE.y, OUTER_SIZE.z-PANEL_THICKNESS])
            rotate([-90, 0, -90])
            mounting_bracket();
        translate([OUTER_SIZE.x, 0, OUTER_SIZE.z-PANEL_THICKNESS])
            rotate([-90, 0, -270])
            mounting_bracket();
        translate([OUTER_SIZE.x, OUTER_SIZE.y, OUTER_SIZE.z-PANEL_THICKNESS])
            rotate([-90, 0, -180])
            mounting_bracket();
    }

    if (PREVIEW_LEFT_WALL) {
        color("Magenta",0.5)
            translate([0,0,BOX_THICKNESS])
            rotate([0, -90, 0])
            difference() {
                box_side_lr();
                linear_extrude(BOX_THICKNESS) eng_box_side_lr();
            }
    }

    if (PREVIEW_RIGHT_WALL) {
        color("Cyan",0.5)
            translate([OUTER_SIZE.x,OUTER_SIZE.y,BOX_THICKNESS])
            rotate([0, -90, 180])
            difference() {
                box_side_lr();
                linear_extrude(BOX_THICKNESS) eng_box_side_lr();
            }
    }

    if (PREVIEW_FRONT_WALL) {
        color("Orange", 0.5)
            translate([0,0,BOX_THICKNESS])
            rotate([90, 0, 0])
            difference() {
                box_side_f();
                linear_extrude(BOX_THICKNESS) eng_box_side_f();
            }
    }

    if (PREVIEW_BACK_WALL) {
        color("Purple", 0.5)
            translate([0,OUTER_SIZE.y+BOX_THICKNESS,BOX_THICKNESS])
            rotate([90, 0, 0])
            difference() {
                box_side_b();
                linear_extrude(BOX_THICKNESS) eng_box_side_b();
            }
    }

    if (PREVIEW_TOP_COVER) {
        color("Yellow", 0.5)
            translate([0, 0, OUTER_SIZE.z-PANEL_THICKNESS])
            difference() {
                box_top();
                linear_extrude(BOX_THICKNESS) eng_box_top();
            }
    }

    if (PREVIEW_TOP_PANEL) {
        color("Grey", 0.5)
            translate([0, 0, OUTER_SIZE.z+BOX_THICKNESS-PANEL_THICKNESS])
            linear_extrude(PANEL_THICKNESS) {
                difference() {
                    panel();
                    eng_panel();
                    inv_panel();
                }
                difference() {
                    inv_panel();
                    panel();
                    eng_panel();
                }
            }
    }

} else {
    if (SHEET == "panel1") {
        panel1_2d();
    } else if (SHEET == "box1") {
        box1_2d();
    } else if (SHEET == "box2") {
        box2_2d();
    } else if (SHEET == "box3") {
        box3_2d();
    } else {
        echo("SHEET is undefined or invalid.");
        echo("Valid options: panel1, box1, box2, box3.");
        echo("No shape will be generated.");
    }
}

