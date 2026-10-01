// ============================================================================
// interfaces/bearing_iso15/bearing_iso15.scad
// ----------------------------------------------------------------------------
// Seats for ISO 15 deep-groove ball bearings. All numbers come from the
// GENERATED consts file; fits come from lib/fits.scad via lib/asm.scad.

use <../../lib/fits.scad>;
use <../../lib/asm.scad>;
include <bearing_iso15.consts.scad>;

function _bsz(size) =
    size == "608"  ? [B608__BORE, B608__OD, B608__WIDTH] :
    size == "625"  ? [B625__BORE, B625__OD, B625__WIDTH] :
    size == "6001" ? [B6001__BORE, B6001__OD, B6001__WIDTH] :
    size == "6002" ? [B6002__BORE, B6002__OD, B6002__WIDTH] :
    assert(false, str("unknown bearing '", size, "'")) [];

// FEMALE: housing bore for the bearing outer ring, opening at z=0 going +Z.
// press (snug) holds the ring by friction; clearance lets it slide.
module bearing_seat(size, cls = "snug") {
    b = _bsz(size);
    asm_socket(b[1], b[2], cls);
}

// FEMALE: through bore for the inner ring + shaft, sized to the bearing bore.
module bearing_shaft_hole(size, cls = "location") {
    b = _bsz(size);
    asm_socket(b[0], 1000, cls);
}

// MALE: retaining lip — a ring that overhangs the seat mouth to trap the
// bearing axially. Union onto the housing around the seat. z=0 is the face
// the bearing sits against; grows +Z.
module bearing_retaining_lip(size, wall = 2.0, cls = "clearance") {
    b = _bsz(size);
    od = b[1] + 2 * wall;
    difference() {
        // thin ring hugging the seat mouth
        cylinder(d = od, h = SEAT__LIP);
        translate([0, 0, -0.01])
            cylinder(d = fit_d(b[1], cls), h = SEAT__LIP + 0.02);
        // chamfer the inner mouth so the bearing slides past
        translate([0, 0, -0.01])
            cylinder(h = fit_lead(b[1]), d1 = fit_d(b[1], cls), d2 = fit_d(b[1], cls) - 2 * fit_lead(b[1]));
    }
}

// MALE: shoulder ring the bearing's outer ring butts against — a disc of
// bearing od + 2×wall, height = shoulder clearance, with a bore for the
// bearing body. Base at z=0.
module bearing_shoulder(size, wall = 2.0, cls = "clearance") {
    b = _bsz(size);
    difference() {
        cylinder(d = b[1] + 2 * wall, h = SEAT__SHOULDER_CLEARANCE);
        translate([0, 0, -0.01])
            cylinder(d = fit_d(b[1], cls), h = SEAT__SHOULDER_CLEARANCE + 0.02);
    }
}
