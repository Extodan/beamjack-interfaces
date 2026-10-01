// ============================================================================
// gauge.scad — fit gauge for tslot_2020
// ----------------------------------------------------------------------------
// Slides into your actual extrusion: three T-nut bars in the three fit
// classes. The one that slides and locks without slop is your slot class.

use <../../lib/fits.scad>;
include <tslot_2020.consts.scad>;
use <tslot_2020.scad>;

$fn = 48;

module gauge() {
    for (i = [0 : 2])
        translate([0, i * 12, 0])
            tnut_body(cls = ["clearance", "location", "snug"][i]);
    // labels beside each bar
    for (i = [0 : 2])
        translate([10, i * 12 + 3, 0.4])
            linear_extrude(0.6)
                text(["clearance", "location", "snug"][i], size = 2.6, valign = "center");
}

gauge();
