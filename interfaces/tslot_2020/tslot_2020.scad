// ============================================================================
// interfaces/tslot_2020/tslot_2020.scad
// ----------------------------------------------------------------------------
// Features for 2020/2040 V-slot extrusion (6.0 mm gap variant). Numbers come
// from the GENERATED consts; fits from lib/fits.scad.

use <../../lib/fits.scad>;
use <../../lib/asm.scad>;
include <tslot_2020.consts.scad>;

// MALE: T-nut body that slides into the slot gap. Base at z=0 on the slot
// mouth plane, body extends +Z into the slot. The stem hole is NOT cut —
// subtract tnut_stem_hole where you want the thread.
module tnut_body(len = TNUT__LENGTH, cls = "clearance") {
    w = fit_d(TNUT__BODY_W, cls);
    t = TNUT__BODY_T;
    // sliding bar inside the slot; both ends chamfered along y so it
    // enters the gap square-on without catching the lips
    for (my = [0, 1])
        mirror([0, my, 0])
            hull() {
                translate([-len / 2, w / 2 - fit_lead(w), 0])
                    cube([len, 0.01, t]);
                translate([-len / 2, w / 2 - fit_lead(w) - 0.01, fit_lead(w)])
                    cube([len, 0.01, 0.01]);
                translate([-len / 2, w / 2 - 0.01, 0]) cube([len, 0.01, t]);
            }
}

// FEMALE: thread hole through the T-nut stem (M5 for the common V-slot nut).
module tnut_stem_hole(cls = "clearance") {
    asm_through_hole(TNUT__STEM_THREAD, cls);
}

// FEMALE: end-face bolt hole into the extrusion's central bore (M4/M5 into
// the 4.2 mm bore — location fit lets an M4 self-tap, clearance suits M5).
module tslot_end_bolt_hole(cls = "location") {
    asm_through_hole(PROFILE__BORE_D, cls);
}

// FEMALE: corner-bracket bolt pattern for one face — holes on the 20 mm
// profile grid, cut through the given thickness. Origin at the face's corner,
// first hole inset half a profile from both edges.
module tslot_bracket_face(thickness = BRACKET__THICKNESS, cls = "clearance") {
    inset = PROFILE__SIZE / 2;
    translate([inset, inset, -0.01])
        cylinder(h = thickness + 0.02, d = fit_d(BRACKET__HOLE_D, cls));
}

// MALE: corner bracket solid (L-shape): base leg on the XY plane (z 0..t),
// upright rising at x 0..t. One M5 hole per leg, centred on the 20 mm grid
// (10 mm from the inside corner). Base at z=0.
module tslot_corner_bracket(cls = "clearance") {
    t = BRACKET__THICKNESS;
    leg = BRACKET__LEG;
    hole_d = fit_d(BRACKET__HOLE_D, cls);
    c = PROFILE__SIZE / 2; // hole centre, 10 mm from the inside corner
    difference() {
        union() {
            cube([leg, leg, t]);              // base leg, holes along z
            translate([0, 0, t]) cube([t, leg, leg]); // upright, holes along x
        }
        // base-leg hole: through z
        translate([c, c, -0.01]) cylinder(h = t + 0.02, d = hole_d);
        // upright hole: through x, one profile height up
        rotate([0, 90, 0]) translate([-t - c, c, -0.01])
            cylinder(h = t + 0.02, d = hole_d);
    }
}
