// ============================================================================
// test.scad — assertion fixture for tslot_2020
// ----------------------------------------------------------------------------
// Plate 60x40x8. The bracket-face pattern is a 3 mm pocket cut from the
// bottom (fixture x=0/20/40 + the module's own 10 mm inset → holes at
// x=10/30/50, y=20, 20 mm pitch). End-bolt through bore at (30, 30).
// T-nut body (MALE) stands on top at (10, 30). Section z=1.5 sits inside the
// pocket: 3 bracket holes + the through bore.

use <tslot_2020.scad>;

$fn = 48;

module test_plate() {
    difference() {
        cube([60, 40, 8]);
        for (x = [0, 20, 40])
            translate([x, 10, -0.01]) tslot_bracket_face();
        translate([30, 30, -0.01]) tslot_end_bolt_hole("clearance");
    }
    // T-nut body standing on the top face (extends +Z from the plate)
    translate([10, 30, 8]) tnut_body();
}

test_plate();
