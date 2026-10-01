// ============================================================================
// gauge.scad — fit gauge for bearing_iso15
// ----------------------------------------------------------------------------
// Rows of seat bosses per bearing, each in snug / location / clearance.
// Press the real bearing into each: the class that holds without force-fit
// damage is your printer's seat class.

use <../../lib/fits.scad>;
include <bearing_iso15.consts.scad>;

$fn = 64;

module _seat(x, y, od, cls, w) {
    translate([x, y, 0])
        difference() {
            cylinder(h = w + 2.5, d = fit_d(od, cls) + 4);
            translate([0, 0, -0.01]) cylinder(h = w + 2.52, d = fit_d(od, cls));
        }
}

module gauge(size = "608") {
    od = size == "608"  ? B608__OD  : size == "625"  ? B625__OD :
         size == "6001" ? B6001__OD : B6002__OD;
    w   = size == "608"  ? B608__WIDTH  : size == "625"  ? B625__WIDTH :
          size == "6001" ? B6001__WIDTH : B6002__WIDTH;
    translate([-40, -12, 0]) cube([80, 44, 2]);
    _seat(-24, 10, od, "snug", w);
    _seat(0,   10, od, "location", w);
    _seat(24,  10, od, "clearance", w);
    translate([0, -8, 2.4])
        linear_extrude(0.6)
            text(str("bearing ", size), size = 4, halign = "center", valign = "center");
}

gauge("608");
