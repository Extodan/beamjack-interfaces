// ============================================================================
// test.scad — assertion fixture for bearing_iso15
// ----------------------------------------------------------------------------
// Block 120x40x10 with two generously-spaced seat bores (no chamfer overlap):
//   608  @ (30, 20)   bore+chamfer spans x 15.5–44.5
//   6002 @ (90, 20)   bore+chamfer spans x 71.5–108.5
// Mid-plane holes sit 60 mm apart. All four seat sizes are exercised by the
// gauge plates; this fixture verifies the shared seat code path.

use <bearing_iso15.scad>;

$fn = 64;

module test_block() {
    difference() {
        cube([120, 40, 10]);
        translate([30, 20, -0.05]) bearing_seat("608", "clearance");
        translate([90, 20, -0.05]) bearing_seat("6002", "clearance");
    }
}

test_block();
