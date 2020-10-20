include <ext/lasercut/lasercut.scad>
include <ext/laserscad/dist/laserscad.scad>
include <footprints.scad>
use <ext/LKP-Assy/lkp-assy-ex.scad>
use <imperial.scad>
use <models.scad>

/* [Viewer Options] */
// Set this to true to get a 3D preview of the assembled controller
PREVIEW_3D = true;
_PREVIEW = $preview == undef || $preview == true ? PREVIEW_3D : false;
$fn = _PREVIEW ? undef : 48;

// Set this to true when PREVIEW_3D=false generates layer for laser engraving (mainly for position of screw holes so they can be drilled later)
ENGRAVE = false;

// box1, box2, box3 are intended to be cut from plywood, panel1 is intended to be cut from acrylic (or PC). lscad enables auto layout with laserscad. (currently not working since laserscad's paging support is not implemented. See https://github.com/mbugert/laserscad/issues/4)
SHEET = "box1"; // [box1, box2, box3, panel1, lscad]
// Output drill layer on cut layer for direct cutting or engrave (eng) layer so that they can be drilled later.
DRILL_AS = "cut"; // [eng, cut]

// Size of panel sheet and box sheets (for reference only)
SHEET_PANEL = [in(24), in(18)];
SHEET_BOX = [in(24), in(16)];

/* [Preview Visibility] */
// Sets visibility of objects in preview

// Front
PREVIEW_FRONT_WALL = true;
// Back
PREVIEW_BACK_WALL = true;
// Left
PREVIEW_LEFT_WALL = true;
// Right
PREVIEW_RIGHT_WALL = true;
// Top cover
PREVIEW_TOP_COVER = true;
// Top panel
PREVIEW_TOP_PANEL = true;
// Bottom
PREVIEW_BOTTOM = true;
// Mounting brackets
PREVIEW_MOUNTING = true;
// Pivots
PREVIEW_PIVOT = true;
// LKP platform
PREVIEW_LKP_PLATFORM = true;
// LKP
PREVIEW_LKP = true;

/* [Hidden] */

// Dimension settings

// Thickness of sheets
BOX_THICKNESS = in(1/4);
PANEL_THICKNESS = mil(80);

// Size of the inner box (without accounting controller panel)
BOX_SIZE = [580, 225, 95];
PANEL_SIZE_REF = [635, 225];

// Size of the outer edge
OUTER_SIZE = [
    BOX_SIZE.x + 2*BOX_THICKNESS,
    BOX_SIZE.y + 2*BOX_THICKNESS,
    // no tabs for z axis
    BOX_SIZE.z + BOX_THICKNESS
];
// Size of the inner box (minus controller panel thickness)
INNER_SIZE = [
    BOX_SIZE.x,
    BOX_SIZE.y,
    BOX_SIZE.z - BOX_THICKNESS - PANEL_THICKNESS
];

FINGER_COUNT = [10, 5, 4];

BUTTON_DIST = 125;
BUTTON_OFFSET_REF = [130, 75];
BUTTON_OFFSET = [
    BUTTON_OFFSET_REF.x - ((PANEL_SIZE_REF.x - BOX_SIZE.x) / 2),
    BUTTON_OFFSET_REF.y - ((PANEL_SIZE_REF.y - BOX_SIZE.y) / 2),
];
BUTTON_R_WITH_NOTCH = (ARCADE_BUTTON_100MM_HOLE_DIA + ARCADE_BUTTON_100MM_NOTCH_DIA) / 2;
SLIDER_SIZE_REF = [500, 40];
// Bottom of the slider, starts from the center of the buttons.
SLIDER_BOTTOM_Y = 75;
SLIDER_OFFSET_REF = [1.5*BUTTON_DIST, SLIDER_BOTTOM_Y + SLIDER_SIZE_REF.y/2];
// Button sits at zero. Therefore teh gap between slider and button (hole) would be (the slider bottom offset - the button radius with notch)
SLIDER_BUTTON_GAP_CENTER = SLIDER_BOTTOM_Y - ((SLIDER_BOTTOM_Y - BUTTON_R_WITH_NOTCH) / 2) + BUTTON_OFFSET.y;
BUTTON_OFFSET_BACKOFF = BUTTON_R_WITH_NOTCH + BUTTON_OFFSET.y + BOX_THICKNESS / 2 + 3;

//SOFTPOT_WIDTH = 20;
//SOFTPOT_DEADZONE_WIDTH = 6;

// Internal use only. Do not change.

EPSILON = .1;

// Automatically generated dimension parameters
_box_side_fb_idim = [BOX_SIZE.x, BOX_SIZE.z];
_box_side_lr_idim = [BOX_SIZE.z, BOX_SIZE.y];
_box_tb_idim = [BOX_SIZE.x, BOX_SIZE.y];
_box_side_f_idim = _box_side_fb_idim;
_box_side_b_idim = _box_side_fb_idim;
_box_bottom_idim = _box_tb_idim;
_box_top_idim = _box_tb_idim;
_box_pivot_v_button_idim = [INNER_SIZE.z, BUTTON_OFFSET_BACKOFF - BOX_THICKNESS / 2];


function account_for_fingers(dim, tb, lr) = [
    dim.x + BOX_THICKNESS * lr,
    dim.y + BOX_THICKNESS * tb,
];

_box_side_fb_xdim = account_for_fingers(_box_side_fb_idim, 1, 2);
_box_side_lr_xdim = account_for_fingers(_box_side_lr_idim, 2, 1);
_box_top_xdim = _box_top_idim;
_box_bottom_xdim = account_for_fingers(_box_bottom_idim, 2, 2);

// 1 group of fingers on the bottom
_box_pivot_h_xdim = account_for_fingers(_box_side_fb_idim, 1, 0);
// 1 group of fingers on the vertical pivot and 1 group on the bottom
_box_pivot_v_button_xdim = account_for_fingers(_box_pivot_v_button_idim, 1, 1);

// Accounting for the thickness for lasercut boards
function as_lcb_center(pos) = pos - BOX_THICKNESS/2;

// Button gap center (-1: Before first button, 0: Gap center between the first and the second button)
function button_gap_center(pos) = BUTTON_DIST * (0.5+pos);

module extrude_box() {
    linear_extrude(BOX_THICKNESS) children();
}

module extrude_panel() {
    linear_extrude(PANEL_THICKNESS) children();
}

// Align box object's outer perimeter to the axis origin
module box_align_to_op(fingered_x=true, fingered_y=true) {
    translate([
        fingered_x ? BOX_THICKNESS : 0,
        fingered_y ? BOX_THICKNESS : 0,
    ]) children();
}

module copy_to_pivot_center() {
    for (i=[-1:3]) {
        translate([BUTTON_OFFSET.x+as_lcb_center(button_gap_center(i)+BOX_THICKNESS/2), 0, BOX_THICKNESS]) children();
    }
}

module extrude_box_cutout() {
    translate([0, 0, -EPSILON])
    linear_extrude(BOX_THICKNESS+2*EPSILON)
        children();
}

module extrude_panel_cutout() {
    translate([0, 0, -EPSILON])
    linear_extrude(PANEL_THICKNESS+2*EPSILON)
        children();
}

module from_button_origin() {
    translate(BUTTON_OFFSET) children();
}

module corner_screw_holes(x, y) {
    //translate([0, 0, 0]) circle(d=3.2);
    translate([x, 0, 0]) circle(d=3.2);
    translate([0, y, 0]) circle(d=3.2);
}

// Bottom side (vector cutting layer)
module _box_bottom() {
    pivot_tab_x = as_lcb_center(_box_bottom_idim.x/2);
    pivot_tab_y = _box_bottom_idim.y;
    lasercutoutSquare(thickness=BOX_THICKNESS,
                      x=_box_bottom_idim.x,
                      y=_box_bottom_idim.y,
                      bumpy_finger_joints=[
                          [UP, 1, FINGER_COUNT.x],
                          [DOWN, 1, FINGER_COUNT.x],
                          [LEFT, 1, FINGER_COUNT.y],
                          [RIGHT, 1, FINGER_COUNT.y]
                      ],
                      // Extended finger joints
                      simple_tabs=[
                          [UP, -BOX_THICKNESS/2, _box_bottom_idim.y],
                          [DOWN, _box_bottom_idim.x+BOX_THICKNESS/2, 0],
                          [LEFT, 0, -BOX_THICKNESS/2],
                          [RIGHT, _box_bottom_idim.x, BOX_THICKNESS/2+_box_bottom_idim.y],
                      ],
                      simple_tab_holes=[
                          //[MID, pivot_tab_x, as_lcb_center(pivot_tab_y/6)],
                          //[MID, pivot_tab_x, as_lcb_center(pivot_tab_y*2/6)],
                          //[MID, pivot_tab_x, as_lcb_center(pivot_tab_y*3/6)],
                          //[MID, pivot_tab_x, as_lcb_center(pivot_tab_y*4/6)],
                          //[MID, pivot_tab_x, as_lcb_center(pivot_tab_y*5/6)]
                      ]);
}

module box_bottom() {
    if (DRILL_AS == "cut") {
        difference() {
            _box_bottom();
            extrude_box_cutout() drl_box_bottom();
        }
    } else {
        _box_bottom();
    }
}

// Bottom side (engraving layer)
module drl_box_bottom() {
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([_box_bottom_idim.x-15, _box_bottom_idim.y-15, 0]) corner_screw_holes(-15, -15);
    translate([_box_bottom_idim.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([15, _box_bottom_idim.y-15, 0]) corner_screw_holes(15, -15);
}

module eng_box_bottom() {
    if (DRILL_AS == "eng") {
        drl_box_bottom();
    }
}

// Top side (vector cutting layer)
module _box_top() {
    difference() {
        square([_box_top_idim.x, _box_top_idim.y]);
        from_button_origin() {
            // Buttons
            panel_button_cuts();
            // Slider reference
            translate(SLIDER_OFFSET_REF)
                lkp_assy_sensor_center() lkp_assy_profile();
        }
    }
}

module box_top() {
    if (DRILL_AS == "cut") {
        difference() {
            _box_top();
            drl_box_top();
        }
    } else {
        _box_top();
    }
}

// Top side (engraving layer)
module drl_box_top() {
    cut_x = (635-_box_top_idim.x)/2;
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([_box_top_idim.x-15, _box_top_idim.y-15, 0]) corner_screw_holes(-15, -15);
    translate([_box_top_idim.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([15, _box_top_idim.y-15, 0]) corner_screw_holes(15, -15);
}

module eng_box_top() {
    if (DRILL_AS == "eng") {
        drl_box_top();
    }
}

// Left/right side (vector cutting layer)
module _box_side_lr() {
    lasercutoutSquare(thickness=BOX_THICKNESS,
                      x=_box_side_lr_idim.x,
                      y=_box_side_lr_idim.y,
                      bumpy_finger_joints=[
                          [UP, 1, FINGER_COUNT.z],
                          //[RIGHT, polarity_lr, FINGER_COUNT.y]
                      ],
                      finger_joints=[
                          [DOWN, 1, FINGER_COUNT.z],
                          [LEFT, 0, FINGER_COUNT.y],
                      ]);
}

module box_side_lr() {
    if (DRILL_AS == "cut") {
        difference() {
            _box_side_lr();
            extrude_box_cutout() drl_box_side_lr();
        }
    } else {
        _box_side_lr();
    }
}

// Left/right side (engraving layer)
module drl_box_side_lr() {
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([_box_side_lr_idim.x-15, _box_side_lr_idim.y-15, 0]) corner_screw_holes(-15, -15);
    translate([_box_side_lr_idim.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([15, _box_side_lr_idim.y-15, 0]) corner_screw_holes(15, -15);
}

module eng_box_side_lr() {
    if (DRILL_AS == "eng") {
        drl_box_side_lr();
    }
}

// Front side (vector cutting layer)
module _box_side_f() {
    // TODO auxiliary control panel
    pivot_tab_x = as_lcb_center(_box_side_f_idim.x/2);
    pivot_tab_y = _box_side_f_idim.y-PANEL_THICKNESS-BOX_THICKNESS;
    difference() {
        lasercutoutSquare(thickness=BOX_THICKNESS,
                          x=_box_side_f_idim.x,
                          y=_box_side_f_idim.y,
                          bumpy_finger_joints=[
                              [LEFT, 1, FINGER_COUNT.z],
                          ],
                          finger_joints=[
                              [DOWN, 0, FINGER_COUNT.x],
                              [RIGHT, 1, FINGER_COUNT.z]
                          ],
                          simple_tab_holes=[
                              //[MID, pivot_tab_x, pivot_tab_y/4-BOX_THICKNESS/2],
                              //[MID, pivot_tab_x, pivot_tab_y*2/4-BOX_THICKNESS/2],
                              //[MID, pivot_tab_x, pivot_tab_y*3/4-BOX_THICKNESS/2],
                          ]);
        translate([5/8*_box_side_f_idim.x, _box_side_f_idim.y/2, 0])
            extrude_box_cutout() {
                footprint_1602();
                translate([70+3, -1.5]) footprint_re();
            }
        translate([55/64*_box_side_f_idim.x, _box_side_f_idim.y/2, 0])
            extrude_box_cutout()
                footprint_control();
    }
}

module box_side_f() {
    if (DRILL_AS == "cut") {
        difference() {
            _box_side_f();
            extrude_box_cutout() drl_box_side_f();
        }
    } else {
        _box_side_f();
    }
}

// Front side (engraving layer)
module drl_box_side_f() {
    translate([5/8*_box_side_f_idim.x, _box_side_f_idim.y/2, 0]) {
        footprint_1602_eng();
        translate([70+3, -1.5]) footprint_re_eng();
    }
    translate([_box_side_f_idim.x-15, _box_side_f_idim.y-15, 0]) corner_screw_holes(-15, -15);
    translate([15, _box_side_f_idim.y-15, 0]) corner_screw_holes(15, -15);
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([_box_side_f_idim.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([55/64*_box_side_f_idim.x, _box_side_f_idim.y/2, 0])
        footprint_control_eng();
}

module eng_box_side_f() {
    if (DRILL_AS == "eng") {
        drl_box_side_f();
    }
}

// Back side (vector cutting layer)
module _box_side_b() {
    pivot_tab_x = _box_side_b_idim.x/2-BOX_THICKNESS/2;
    pivot_tab_y = _box_side_b_idim.y-PANEL_THICKNESS-BOX_THICKNESS;
    difference() {
        lasercutoutSquare(thickness=BOX_THICKNESS,
                          x=_box_side_b_idim.x,
                          y=_box_side_b_idim.y,
                          bumpy_finger_joints=[
                              [RIGHT, 0, FINGER_COUNT.z]
                          ],
                          finger_joints=[
                              [DOWN, 1, FINGER_COUNT.x],
                              [LEFT, 0, FINGER_COUNT.z],
                              
                          ],
                          simple_tab_holes=[
                              //[MID, pivot_tab_x, pivot_tab_y/4-BOX_THICKNESS/2],
                              //[MID, pivot_tab_x, pivot_tab_y*2/4-BOX_THICKNESS/2],
                              //[MID, pivot_tab_x, pivot_tab_y*3/4-BOX_THICKNESS/2],
                          ]);
        translate([_box_side_b_idim.x/4*3, _box_side_b_idim.y/3, 0]) {
            extrude_box_cutout() footprint_back_panel_cutout();
        }
    }
}

module box_side_b() {
    if (DRILL_AS == "cut") {
        difference() {
            _box_side_b();
            extrude_box_cutout() drl_box_side_b();
        }
    } else {
        _box_side_b();
    }
}

// Back side (engraving layer)
module drl_box_side_b() {
    translate([_box_side_b_idim.x-15, _box_side_b_idim.y-15, 0]) corner_screw_holes(-15, -15);
    translate([15, _box_side_b_idim.y-15, 0]) corner_screw_holes(15, -15);
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([_box_side_b_idim.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([_box_side_b_idim.x/4*3, _box_side_b_idim.y/3]) {
        footprint_back_panel_cutout_eng();
    }
}

module eng_box_side_b() {
    if (DRILL_AS == "eng") {
        drl_box_side_b();
    }
}

// Horizontal pivot (between slider and main buttons)
module box_pivot_h() {
    // TODO alignment tabs
    lasercutoutSquare(
        thickness=BOX_THICKNESS,
        x=INNER_SIZE.x,
        y=INNER_SIZE.z
    );
}

// Vertical pivot (between main buttons)
module box_pivot_v_button() {
    // Rotate by Y axis by -90deg
    // local X = global Z, local Y = global Y
    // TODO alignment tabs on bottom and h pivot
    lasercutoutSquare(
        thickness=BOX_THICKNESS,
        x=_box_pivot_v_button_idim.x,
        y=_box_pivot_v_button_idim.y,
        simple_tabs =[
            [UP, _box_pivot_v_button_idim.x / 2, _box_pivot_v_button_idim.y],
            [LEFT, 0, _box_pivot_v_button_idim.y / 2],
        ]
    );
}

// Support platform for capacitive slider module
module box_lkp_platform() {
    lasercutoutSquare(
        thickness=BOX_THICKNESS,
        x=INNER_SIZE.x,
        y=INNER_SIZE.y - BUTTON_OFFSET_BACKOFF - BOX_THICKNESS / 2
    );
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
module rect_ft_panel_fitted() {
    square([BOX_SIZE.x, BOX_SIZE.y]);
}

module panel_button_cuts() {
    for (i=[0:BUTTON_DIST:BUTTON_DIST*3]) {
        translate([i, 0, 0]) {
            // Button position reference
            //%circle(d=ARCADE_BUTTON_100MM_DIA);
            footprint_arcade_button_100mm();
        }
        
    }
    //translate([1.5*BUTTON_DIST, 115, 0]) {
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
    translate([-BUTTON_OFFSET.x, -BUTTON_OFFSET.y, 0]) {
        // Panel reference
        //%stock_ft_panel();
        rect_ft_panel_fitted();
    }
}

module _panel() {
    from_button_origin() {
        difference() {
            panel_base();
            panel_button_cuts();
            // LKP cutout
            translate(SLIDER_OFFSET_REF) {
                difference() {
                    lkp_assy_sensor_center()
                        lkp_assy_profile();
                    lkp_overlay_sensor_center()
                        lkp_overlay_profile();
                }
            }
        }
    }
}

module panel() {
    if (DRILL_AS == "cut") {
        difference() {
            _panel();
            drl_box_bottom();
        }
    } else {
        _box_bottom();
    }
}

module drl_panel() {
    cut_x = (635-BOX_SIZE[0])/2;

    translate([-cut_x, 0, 0]) {
        translate([BUTTON_OFFSET_REF.x, BUTTON_OFFSET_REF.y, 0]) translate([1.5*BUTTON_DIST, 115, 0]) {
            // Slider position reference
            //%square([510, 64], true);
            // SoftPot reference
            //translate([0, 10-32-6, 0]) {
                //%square([500, 20], true);
                // TODO replace with LKP
                //footprint_softpot_mount(invert=true, tail_cut=false);
            //}
        }
    }
    // TODO re-layout
    translate([15, 15, 0]) corner_screw_holes(15, 15);
    translate([BOX_SIZE.x-15, BOX_SIZE.y-15, 0]) corner_screw_holes(-15, -15);
    translate([BOX_SIZE.x-15, 15, 0]) corner_screw_holes(-15, 15);
    translate([15, BOX_SIZE.y-15, 0]) corner_screw_holes(15, -15);
}

module eng_panel() {
    if (DRILL_AS == "eng") {
        drl_panel();
    }
}

module inv_panel() {
    cut_x = (635-BOX_SIZE[0])/2;
    translate([-cut_x, 0, 0])
        translate([BUTTON_OFFSET_REF.x, BUTTON_OFFSET_REF.y, 0])
        translate([1.5*BUTTON_DIST, 115, 0])
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
        translate([BOX_THICKNESS, BOX_THICKNESS*2+BOX_SIZE.y])
            eng_box_side_f();
    } else {
        // Box top is native 2D and projection() is not needed
        box_top();
        projection() {
            translate([BOX_THICKNESS, BOX_THICKNESS*2+BOX_SIZE.y])
                box_side_f();
        }
    }
}

module box2_2d() {
    %square(SHEET_BOX);
    if (ENGRAVE) {
        // TODO
        translate([BOX_THICKNESS, BOX_THICKNESS])
            eng_box_bottom();
        translate([BOX_THICKNESS, BOX_THICKNESS*3+BOX_SIZE.y])
            eng_box_side_b();
    } else {
        projection() {
            translate([BOX_THICKNESS, BOX_THICKNESS]) box_bottom();
            translate([BOX_THICKNESS, BOX_THICKNESS*3+BOX_SIZE.y])
                box_side_b();
        }
    }
}

module box3_2d() {
    %square(SHEET_BOX);
    if (ENGRAVE) {
        translate([BOX_THICKNESS*2+BOX_SIZE.y, 0])
        rotate([0, 0, 90]) {
            translate([BOX_THICKNESS, BOX_THICKNESS]) eng_box_side_lr();
            translate([BOX_THICKNESS*3+BOX_SIZE.z, BOX_THICKNESS])
                eng_box_side_lr();
        }
    } else {
        translate([BOX_THICKNESS*2+BOX_SIZE.y, 0])
        rotate([0, 0, 90]) {
            translate([BOX_THICKNESS, BOX_THICKNESS]) projection() box_side_lr();
            translate([BOX_THICKNESS*3+BOX_SIZE.z, BOX_THICKNESS]) {
                projection() box_side_lr();
                translate([BOX_THICKNESS*2+BOX_SIZE.z, 0])
                    projection() box_pivot();
            }
        }
    }
}

module boxes_lscad() {
    lpart("box_side_f", _box_side_fb_xdim)
        box_align_to_op() box_side_f();
    lpart("box_side_b", _box_side_fb_xdim)
        box_align_to_op() box_side_b();
    lpart("box_side_lr_1", _box_side_lr_xdim)
        box_align_to_op() box_side_lr();
    lpart("box_side_lr_2", _box_side_lr_xdim)
        box_align_to_op() box_side_lr();
    lpart("box_bottom", _box_bottom_xdim)
        box_align_to_op() box_bottom();
    lpart("box_top", _box_top_xdim) linear_extrude(BOX_THICKNESS)
        box_top();
    for (index_pv=[0:4]) {
        lpart(str("box_pivot_v_button_", index_pv), _box_pivot_v_button_xdim) 
            box_align_to_op(fingered_y=false) box_pivot_v_button();
    }
}

if (_PREVIEW) {
    // Orders matter here in order to maintain the transparent illusions
    //echo("WARNING: This is just a preview. Set PREVIEW=false to get laser cuttable shapes.");
    if (PREVIEW_BOTTOM) {
        color("Green",0.5) difference() {
            box_bottom();
            extrude_box_cutout() eng_box_bottom();
        }
    }

    if (PREVIEW_LKP_PLATFORM) {
        color("Blue", 0.5)
        translate([0,
                   BUTTON_OFFSET_BACKOFF + BOX_THICKNESS / 2,
                   BOX_SIZE.z-PANEL_THICKNESS])
            translate([0, 0, lkp_get_assy_zoffset()])
            box_lkp_platform();
    }
    if (PREVIEW_PIVOT) {
        color("Red", 0.5) {
            //translate([BOX_SIZE.x/2+BOX_THICKNESS/2,0,BOX_THICKNESS])
            //rotate([0, -90, 0])
            //    box_pivot();
            // original pos is outside edge
            translate([0, as_lcb_center(BUTTON_OFFSET_BACKOFF+BOX_THICKNESS), BOX_THICKNESS])
            rotate([90, 0, 0])
                box_pivot_h();
            copy_to_pivot_center() translate([BOX_THICKNESS/2, 0, 0]) rotate([0, -90, 0]) box_pivot_v_button();
        }
    }

    if (PREVIEW_MOUNTING) {
        // corners
        translate([0, 0, BOX_THICKNESS]) {
            corner_support();
            translate([INNER_SIZE.x, 0]) rotate([0, 0, 90]) corner_support();
            translate([INNER_SIZE.x, INNER_SIZE.y]) rotate([0, 0, 180]) corner_support();
            translate([0, INNER_SIZE.y]) rotate([0, 0, 270]) corner_support();
        }
        copy_to_pivot_center() translate([0, _box_pivot_v_button_idim.y / 2, INNER_SIZE.z]) pivot_holder();
    }

    if (PREVIEW_LEFT_WALL) {
        color("Magenta",0.5)
            translate([0,0,BOX_THICKNESS])
            rotate([0, -90, 0])
            difference() {
                box_side_lr();
                extrude_box_cutout() eng_box_side_lr();
            }
    }

    if (PREVIEW_RIGHT_WALL) {
        color("Cyan",0.5)
            translate([BOX_SIZE.x,BOX_SIZE.y,BOX_THICKNESS])
            rotate([0, -90, 180])
            difference() {
                box_side_lr();
                extrude_box_cutout() eng_box_side_lr();
            }
    }

    if (PREVIEW_FRONT_WALL) {
        color("Orange", 0.5)
            translate([0,0,BOX_THICKNESS])
            rotate([90, 0, 0])
            difference() {
                box_side_f();
                extrude_box_cutout() eng_box_side_f();
            }
    }

    if (PREVIEW_BACK_WALL) {
        color("Purple", 0.5)
            translate([0,BOX_SIZE.y+BOX_THICKNESS,BOX_THICKNESS])
            rotate([90, 0, 0])
            difference() {
                box_side_b();
                extrude_box_cutout() eng_box_side_b();
            }
    }
    if (PREVIEW_TOP_COVER) {
        color("Yellow", 0.5)
            translate([0, 0, BOX_SIZE.z-PANEL_THICKNESS])
            difference() {
                extrude_box() box_top();
                extrude_box() eng_box_top();
            }
    }

    if (PREVIEW_TOP_PANEL) {
        color("Grey", 0.5)
            translate([0, 0, BOX_SIZE.z+BOX_THICKNESS-PANEL_THICKNESS])
            extrude_panel() {
                difference() {
                    panel();
                    eng_panel();
                    inv_panel();
                }
                difference() {
                    // broken, disabled for now
                    //inv_panel();
                    panel();
                    eng_panel();
                }
            }
    }
    if (PREVIEW_LKP) {
        color("Lime", 0.5)
        // Button-base coordinate in 3D (panel z level)
        translate([BUTTON_OFFSET.x,
                   BUTTON_OFFSET.y,
                   BOX_SIZE.z+BOX_THICKNESS-PANEL_THICKNESS])
        // Slider 2D offset
            translate(SLIDER_OFFSET_REF)
        // LKP-Assy sink z offset
            lkp_assy_zposition()
            lkp_demo_assy_centered();
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
    } else if (SHEET == "lscad") {
        echo("LaserSCAD interop");
        boxes_lscad();
    } else {
        echo("SHEET is undefined or invalid.");
        echo("Valid options: panel1, box1, box2, box3, lscad (ONLY use this with laserscad).");
        echo("No shape will be generated.");
    }
}

