include <ext/lasercut/lasercut.scad>
include <footprints.scad>
include <imperial.scad>

PREVIEW = false;
ENGRAVE = false;
SHEET = "box1";
SHEET_PANEL = [in(24), in(18)];
SHEET_BOX = [in(48), in(24)];

BOX_THICKNESS = in(1/4);
PANEL_THICKNESS = mil(80);
OUTER_SIZE = [in(24), 225, 120];
FINGER_COUNT = [10, 5, 4];

MAIN_BUTTON_DIST = 125;
MAIN_BUTTON_OFFSET_X = 130;
MAIN_BUTTON_OFFSET_Y = 75;

X = 0;
Y = 1;
Z = 2;

module box_bottom() {
    pivot_tab_x = OUTER_SIZE[X]/2-BOX_THICKNESS/2;
    pivot_tab_y = OUTER_SIZE[Y];
    lasercutoutSquare(thickness=BOX_THICKNESS,
                      x=OUTER_SIZE[X],
                      y=OUTER_SIZE[Y],
                      bumpy_finger_joints=[
                          [UP, 1, FINGER_COUNT[X]],
                          [DOWN, 1, FINGER_COUNT[X]],
                          [LEFT, 1, FINGER_COUNT[Y]],
                          [RIGHT, 1, FINGER_COUNT[Y]]
                      ],
                      simple_tabs=[
                          [UP, -BOX_THICKNESS/2, OUTER_SIZE[Y]],
                          [DOWN, OUTER_SIZE[X]+BOX_THICKNESS/2, 0],
                          [LEFT, 0, -BOX_THICKNESS/2],
                          [RIGHT, OUTER_SIZE[X], BOX_THICKNESS/2+OUTER_SIZE[Y]],
                      ],
                      simple_tab_holes=[
                          [MID, pivot_tab_x, pivot_tab_y/6-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*2/6-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*3/6-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*4/6-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*5/6-BOX_THICKNESS/2]
                      ]);
}

module box_top() {
    // TODO inner button footprint, SoftPot cutout
    cut_x = (635-OUTER_SIZE[0])/2;
    pivot_tab_x = OUTER_SIZE[X]/2-BOX_THICKNESS/2;
    pivot_tab_y = OUTER_SIZE[Y];
    difference() {
        lasercutoutSquare(thickness=BOX_THICKNESS,
                          x=OUTER_SIZE[X],
                          y=OUTER_SIZE[Y],
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
            translate([0, 10-32-6, 0])
            linear_extrude(BOX_THICKNESS) {
                footprint_softpot_mount(invert=true, holes=false);
            }
    }
}

module eng_box_top() {
    cut_x = (635-OUTER_SIZE[0])/2;
    translate([-cut_x, 0, 0]) translate([MAIN_BUTTON_OFFSET_X, MAIN_BUTTON_OFFSET_Y, 0])
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

module box_side_lr(polarity_ud=1, polarity_lr=0) {
    lasercutoutSquare(thickness=BOX_THICKNESS,
                      x=OUTER_SIZE[Z],
                      y=OUTER_SIZE[Y],
                      bumpy_finger_joints=[
                          [UP, polarity_ud, FINGER_COUNT[Z]],
                          [DOWN, polarity_ud, FINGER_COUNT[Z]],
                          [LEFT, polarity_lr, FINGER_COUNT[Y]],
                          //[RIGHT, polarity_lr, FINGER_COUNT[Y]]
                      ]);
}

module box_side_f() {
    // TODO LCD display, auxiliary control panel
    pivot_tab_x = OUTER_SIZE[X]/2-BOX_THICKNESS/2;
    pivot_tab_y = OUTER_SIZE[Z]-PANEL_THICKNESS-BOX_THICKNESS;
    difference() {
        lasercutoutSquare(thickness=BOX_THICKNESS,
                          x=OUTER_SIZE[X],
                          y=OUTER_SIZE[Z],
                          bumpy_finger_joints=[
                              //[UP, 0, FINGER_COUNT[X]],
                              [DOWN, 0, FINGER_COUNT[X]],
                              [LEFT, 1, FINGER_COUNT[Z]],
                              [RIGHT, 1, FINGER_COUNT[Z]]
                          ],
                          simple_tab_holes=[
                              [MID, pivot_tab_x, pivot_tab_y/4-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*2/4-BOX_THICKNESS/2],
                              [MID, pivot_tab_x, pivot_tab_y*3/4-BOX_THICKNESS/2],
                          ]);
        translate([3/4*OUTER_SIZE[X], OUTER_SIZE[Z]/2, 0])
            linear_extrude(BOX_THICKNESS) {
                footprint_1602();
            }
    }
}

module eng_box_side_f() {
    translate([3/4*OUTER_SIZE[X], OUTER_SIZE[Z]/2, 0])
        linear_extrude(BOX_THICKNESS) {
            footprint_1602_eng();
        }
}

module box_side_b() {
    // TODO USB, power port
    pivot_tab_x = OUTER_SIZE[X]/2-BOX_THICKNESS/2;
    pivot_tab_y = OUTER_SIZE[Z]-PANEL_THICKNESS-BOX_THICKNESS;
    lasercutoutSquare(thickness=BOX_THICKNESS,
                      x=OUTER_SIZE[X],
                      y=OUTER_SIZE[Z],
                      bumpy_finger_joints=[
                          //[UP, 1, FINGER_COUNT[X]],
                          [DOWN, 1, FINGER_COUNT[X]],
                          [LEFT, 0, FINGER_COUNT[Z]],
                          [RIGHT, 0, FINGER_COUNT[Z]]
                      ],
                      simple_tab_holes=[
                          [MID, pivot_tab_x, pivot_tab_y/4-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*2/4-BOX_THICKNESS/2],
                          [MID, pivot_tab_x, pivot_tab_y*3/4-BOX_THICKNESS/2],
                      ]);
}

module box_pivot() {
    x = OUTER_SIZE[Z]-PANEL_THICKNESS-BOX_THICKNESS;
    y = OUTER_SIZE[Y];
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
                          [RIGHT, x, y/6],
                          [RIGHT, x, y*2/6],
                          [RIGHT, x, y*3/6],
                          [RIGHT, x, y*4/6],
                          [RIGHT, x, y*5/6]
                      ]);
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
    //    translate([x, 0, 0]) circle(d=3.5, center=true);
    //    translate([0, y, 0]) circle(d=3.5, center=true);
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
        //%stock_ft_panel();
        rect_ft_panel();
    }
}

module panel() {
    cut_x = (635-OUTER_SIZE[0])/2;
    translate([-cut_x, 0, 0]) difference() {
        translate([MAIN_BUTTON_OFFSET_X, MAIN_BUTTON_OFFSET_Y, 0]) difference() {
            panel_base();
            cuts();
            translate([1.5*MAIN_BUTTON_DIST, 115, 0]) translate([0, 10-32-6, 0]) footprint_softpot_mount(holes=false);
        }
        square([(635-OUTER_SIZE[0])/2, 225]);
        translate([635-cut_x, 0, 0]) square([(635-OUTER_SIZE[0])/2, 225]);
    }
}

module eng_panel() {
    cut_x = (635-OUTER_SIZE[0])/2;
    translate([-cut_x, 0, 0]) translate([MAIN_BUTTON_OFFSET_X, MAIN_BUTTON_OFFSET_Y, 0]) translate([1.5*MAIN_BUTTON_DIST, 115, 0]) {
        // Slider position reference
        %square([510, 64], true);
        // SoftPot reference
        translate([0, 10-32-6, 0]) {
            %square([500, 20], true);
            footprint_softpot_mount(invert=true, tail_cut=false);
        }
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
    } else {
        projection() {
            box_top();
            translate([BOX_THICKNESS, BOX_THICKNESS*2+OUTER_SIZE[Y], 0]) box_bottom();
        }
    }
}

if (PREVIEW) {
    color("Green",0.5) box_bottom();

    color("Cyan",0.5)
        translate([0,0,BOX_THICKNESS])
        rotate([0, -90, 0])
            box_side_lr();

    color("Cyan",0.5)
        translate([OUTER_SIZE[X]+BOX_THICKNESS,0,BOX_THICKNESS])
        rotate([0, -90, 0])
            box_side_lr(polarity_ud=0, polarity_lr=1);

    color("Orange", 0.5)
        translate([0,0,BOX_THICKNESS])
        rotate([90, 0, 0])
        difference() {
            box_side_f();
            eng_box_side_f();
        }

    color("Purple", 0.5)
        translate([0,OUTER_SIZE[Y]+BOX_THICKNESS,BOX_THICKNESS])
        rotate([90, 0, 0])
            box_side_b();

    color("Red", 0.5)
        translate([OUTER_SIZE[X]/2+BOX_THICKNESS/2,0,BOX_THICKNESS])
        rotate([0, -90, 0])
            box_pivot();

    color("Yellow", 0.5)
        translate([0, 0, OUTER_SIZE[Z]-PANEL_THICKNESS])
        difference() {
            box_top();
            linear_extrude(BOX_THICKNESS) eng_box_top();
        }

    color("Grey", 0.5)
        translate([0, 0, OUTER_SIZE[Z]+BOX_THICKNESS-PANEL_THICKNESS])
        linear_extrude(PANEL_THICKNESS)
        difference() {
            panel();
            eng_panel();
        }
} else {
    if (SHEET == "panel1") {
        panel1_2d();
    } else if (SHEET == "box1") {
        box1_2d();
    }

}

