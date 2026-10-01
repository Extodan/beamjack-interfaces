// ============================================================================
// gauge.scad — fit gauge for iso_metric_fasteners
// ----------------------------------------------------------------------------
// Print one plate per screw size. Each row carries the THROUGH feature in
// all three fit classes side by side, labelled. Slide the matching screw
// through each: the class that behaves as labelled is the class to use for
// that printer/filament — record it, then correct lib/fits.scad if needed.

use <../../lib/fits.scad>;
include <iso_metric_fasteners.consts.scad>;
use <iso_metric_fasteners.scad>;

$fn = 48;

module gauge(size = "m3") {
    d = size == "m2" ? M2__THREAD : size == "m2_5" ? M2_5__THREAD :
        size == "m3" ? M3__THREAD : size == "m4" ? M4__THREAD :
        size == "m5" ? M5__THREAD : M6__THREAD;
    difference() {
        translate([0, 0, 0]) cube([66, 30, 6]);
        translate([12, 15, -0.01]) cylinder(h = 6.02, d = fit_d(d, "clearance"));
        translate([33, 15, -0.01]) cylinder(h = 6.02, d = fit_d(d, "location"));
        translate([54, 15, -0.01]) cylinder(h = 6.02, d = fit_d(d, "snug"));
    }
    translate([33, 27.5, 6.4])
        linear_extrude(0.6)
            text(str("iso_metric_fasteners ", size), size = 2.8, halign = "center", valign = "center");
}

gauge("m3");
