// Various footprints and their constants

include <imperial.scad>

ARCADE_BUTTON_100MM_DIA = 100;
ARCADE_BUTTON_100MM_HOLE_DIA = 88;
ARCADE_BUTTON_100MM_NOTCH_DIA = 6.5;

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

//module footprint_1602() {
//    square([80, 36], true);
//}

// Drill: invert=true, tail_cut=false
// Tail cut (difference): invert=true, holes=false
// TODO account for tail when positioning tail cut.
module footprint_softpot_mount(softpot_length=500, softpot_width=20, padding=20, invert=false, holes=true, tail_cut=true) {
    module _screw_holes() {
        offset_x = half_l + screw_hole_offset_from_pot;
        offset_y = half_w + screw_hole_offset_from_pot;
        translate([-offset_x, -offset_y]) circle(d=3.2);
        translate([offset_x, -offset_y]) circle(d=3.2);
        translate([-offset_x, offset_y]) circle(d=3.2);
        translate([offset_x, offset_y]) circle(d=3.2);
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
    %square([80, 36], center=true);
    translate([-80/2, -36/2, 0]) {
        translate([2.5, 2.5, 0]) circle(d=3.2);
        translate([80-2.5, 36-2.5, 0]) circle(d=3.2);
        translate([80-2.5, 2.5, 0]) circle(d=3.2);
        translate([2.5, 36-2.5, 0]) circle(d=3.2);
    }
}

module footprint_control() {
    %square([70, 30], center=true);
    square([63, 20], center=true);
}

module footprint_control_eng() {
    %square([70, 30], center=true);
    translate([-70/2, -30/2, 0]) {
        translate([2.5, 2.5]) circle(d=3.2);
        translate([70-2.5, 30-2.5, 0]) circle(d=3.2);
        translate([70-2.5, 2.5, 0]) circle(d=3.2);
        translate([2.5, 30-2.5, 0]) circle(d=3.2);
    }
}

module footprint_re() {
    %square([26, 19], center=true);
    translate([-3, 1.5]) {
        circle(d=7);
        translate([-6, 0]) {
            square([1, 2], center=true);
        }
    }
}

module footprint_re_eng() {
    %square([26, 19], center=true);
    //translate([-3, 1.5]) circle(d=7);
    translate([-26/2, -19/2, 0]) {
        translate([4.5, 2.5]) circle(d=3.2);
        translate([26-4.5, 2.5]) circle(d=3.2);
    }
}
module footprint_adafruit_908_ref() {
    translate([-14, 0]) hull() {
        circle(d=12);
        translate([28, 0]) circle(d=12);
    }
}

module footprint_adafruit_908() {
    %footprint_adafruit_908_ref();
    square([14.5, 7], center=true);
}

module footprint_adafruit_908_eng() {
    %footprint_adafruit_908_ref();
    translate([15, 0]) circle(d=in(7/64));
    translate([-15, 0]) circle(d=in(7/64));
}

module footprint_adafruit_3258_ref() {
    union() {
        translate([-8.5, 0]) hull() {
            circle(d=8);
            translate([17, 0]) circle(d=8);
        }
        minkowski() {
            square([12-4, 10-4], center=true);
            circle(r=2);
        }
    }
}

module footprint_adafruit_3258() {
    %footprint_adafruit_3258_ref();
    square([9, 4.5], center=true);
}

module footprint_adafruit_3258_eng() {
    %footprint_adafruit_3258_ref();
    translate([-9, 0]) circle(d=in(7/64));
    translate([9, 0]) circle(d=in(7/64));
}
module footprint_tensility_54_00063() {
    circle(d=11);
}

module footprint_back_panel() {
    // Thickness should not exceed 2.5mm otherwise micro USB plug will not
    // fit
    %square([60,40], center=true);
    difference() {
        square([75,50], center=true);
        translate([20, 0, 0]) rotate([0, 0, 90]) footprint_adafruit_3258();
        rotate([0, 0, 90]) footprint_adafruit_908();
        translate([-20, 0, 0]) rotate([0, 0, 90]) footprint_tensility_54_00063();
    }
}

module footprint_back_panel_eng() {
    translate([20, 0, 0]) rotate([0, 0, 90]) footprint_adafruit_3258_eng();
    rotate([0, 0, 90]) footprint_adafruit_908_eng();
    translate([34.5, 22]) circle(d=3.2);
    translate([-34.5, 22]) circle(d=3.2);
    translate([34.5, -22]) circle(d=3.2);
    translate([-34.5, -22]) circle(d=3.2);
}

module footprint_back_panel_cutout() {
    square([60,40], center=true);
}

module footprint_back_panel_cutout_eng() {
    translate([34.5, 22]) circle(d=3.2);
    translate([-34.5, 22]) circle(d=3.2);
    translate([34.5, -22]) circle(d=3.2);
    translate([-34.5, -22]) circle(d=3.2);
}

module footprint_tp_contact_notch() {
    module side_notch() {
        union() {
            square([4, 14], center=true);
            translate([0, 5-4/2]) square([5+4/2, 4], center=false);
            translate([0, -5-4/2]) square([5+4/2, 4], center=false);
        }
    }

    translate([-50, 0]) side_notch();
    translate([50, 0]) mirror([1, 0]) side_notch();

    translate([-25, 5]) square([15, 4], center=true);
    translate([25, -5]) square([15, 4], center=true);
    translate([-25, -5]) square([15, 4], center=true);
    translate([25, 5]) square([15, 4], center=true);
    translate([0, 5]) square([10, 4], center=true);
}