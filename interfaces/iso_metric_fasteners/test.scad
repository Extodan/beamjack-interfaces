// ============================================================================
// test.scad — assertion fixture for iso_metric_fasteners
// ----------------------------------------------------------------------------
// One plate exercising every feature at KNOWN positions so spec.json
// assertions can measure them on the compiled STL:
//   x=10 : M3 through hole
//   x=25 : M3 cap-head counterbore (from top)
//   x=40 : M4 button-head counterbore (from top)
//   x=55 : M3 hex nut trap (from bottom)
//   x=68 : M4 square nut trap (from bottom)
//   x=82 : M4 heat-set insert boss standing on top
// Spacings between through-shanks at z=4: 10 → 25 → 40 = 15 mm pitch.

use <iso_metric_fasteners.scad>;

$fn = 48;

PLATE_W = 90;
PLATE_D = 30;
PLATE_T = 8;

module test_plate() {
    difference() {
        cube([PLATE_W, PLATE_D, PLATE_T]);
        // through holes + counterbores cut from the top
        translate([10, PLATE_D / 2, 0]) fastener_through_hole("m3");
        translate([25, PLATE_D / 2, 0]) fastener_cap_counterbore("m3");
        translate([40, PLATE_D / 2, 0]) fastener_button_counterbore("m4");
        // nut traps cut from the bottom face (z=0 plane of the plate)
        translate([55, PLATE_D / 2, 0]) fastener_hex_trap("m3");
        translate([68, PLATE_D / 2, 0]) fastener_square_trap("m4");
    }
    // boss stands on the top surface
    translate([82, PLATE_D / 2, PLATE_T]) fastener_insert_boss("m4");
}

test_plate();
