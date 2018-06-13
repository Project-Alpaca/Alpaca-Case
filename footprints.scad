// Various footprints and their constants

ARCADE_BUTTON_100MM_DIA = 100;
ARCADE_BUTTON_100MM_HOLE_DIA = 90;
ARCADE_BUTTON_100MM_NOTCH_DIA = 7;

module footprint_arcade_button_100mm() {
    union() {
        _r = ARCADE_BUTTON_100MM_HOLE_DIA / 2;
        // main hole
        circle(d=ARCADE_BUTTON_100MM_HOLE_DIA);
        // notch
        translate([0, _r, 0]) {
            circle(d=ARCADE_BUTTON_100MM_NOTCH_DIA);
        }
        translate([0, -_r, 0]) {
            circle(d=ARCADE_BUTTON_100MM_NOTCH_DIA);
        }
    }
}

module footprint_1602() {
    square([80, 36], true);
}

module footprint_softpot_mount(softpot_length=500, softpot_width=20, padding=20, invert=false, holes=true, tail_cut=true) {
    module _screw_holes() {
        offset_x = half_l + screw_hole_offset_from_pot;
        offset_y = half_w + screw_hole_offset_from_pot;
        translate([-offset_x, -offset_y]) circle(d=3.5, center=true);
        translate([offset_x, -offset_y]) circle(d=3.5, center=true);
        translate([-offset_x, offset_y]) circle(d=3.5, center=true);
        translate([offset_x, offset_y]) circle(d=3.5, center=true);
    }

    module _tail_cut() {
        offset_x = half_l + 5;
        translate([offset_x, 0]) square([3, 11], center=true);
    }

    screw_hole_offset_from_pot = padding / 4;
    half_l = softpot_length / 2;
    half_w = softpot_width / 2;

    if (!invert) {
        difference() {
            square([softpot_length+padding, softpot_width+padding], center=true);
            if (holes) _screw_holes();
            if (tail_cut) _tail_cut();
        }
    } else {
        %square([softpot_length+padding, softpot_width+padding], center=true);
        if (holes) _screw_holes();
        if (tail_cut) _tail_cut();
    }
    %square([softpot_length, softpot_width], center=true);
}

module footprint_1602() {
    %square([80, 36], center=true);
    square([73, 26], center=true);
}

module footprint_1602_eng() {
    translate([-80/2, -36/2, 0]) {
        translate([2.5, 2.5, 0]) circle(d=2.75, center=true);
        translate([80-2.5, 36-2.5, 0]) circle(d=2.75, center=true);
        translate([80-2.5, 2.5, 0]) circle(d=2.75, center=true);
        translate([2.5, 36-2.5, 0]) circle(d=2.75, center=true);
    }
}