// ============================================================================
// lib/asm.scad — typed mating features, mirroring the engine's assembly.scad
// ----------------------------------------------------------------------------
// Same signatures, same geometry language, same conventions as the main
// engine (Procedura lib/assembly.scad):
//   * MALE / additive solids  (asm_peg)   -> union() onto the part.
//   * FEMALE / negative tools (asm_socket) -> subtract from the part.
//   * every male tip and female mouth carries a lead-in chamfer so parts
//     self-centre as they seat.
//   * male and female pair from ONE shared nominal + signed fit offset.
// The fit values come from lib/fits.scad — nothing here owns a tolerance.

include <fits.scad>;

// ---- peg ↔ socket ----------------------------------------------------------
// MALE peg, base at origin, growing +Z, chamfered self-centring tip.
module asm_peg(d, len) {
    // mating event for the census — $part inherits from the calling module
    part = is_undef($part) ? "?" : $part;
    echo(str("ASM|peg|part=", part, "|nominal=", d, "|cls=none|fitted=", d));
    lead = fit_lead(d);
    union() {
        cylinder(h = max(0.01, len - lead), d = d);
        translate([0, 0, len - lead])
            cylinder(h = lead, d1 = d, d2 = max(0.2, d - 2 * lead));
    }
}

// FEMALE socket, cut from the SAME nominal as its peg. Bore grows with the
// fit class; mouth chamfer eases insertion.
module asm_socket(d, depth, cls = "location") {
    part = is_undef($part) ? "?" : $part;
    echo(str("ASM|socket|part=", part, "|nominal=", d, "|cls=", cls, "|fitted=", fit_d(d, cls)));
    bore = fit_d(d, cls);
    lead = fit_lead(bore);
    union() {
        translate([0, 0, -0.01]) cylinder(h = depth + 0.02, d = bore);
        translate([0, 0, depth - lead])
            cylinder(h = lead + 0.01, d1 = bore, d2 = bore + 2 * lead);
    }
}

// ---- through hole / counterbore --------------------------------------------
// Plain through hole for a fastener of nominal thread d, ISO-273-style.
module asm_through_hole(d, cls = "clearance") {
    bore = fit_d(d, cls);
    lead = fit_lead(bore);
    union() {
        translate([0, 0, -0.01]) cylinder(h = 100000, d = bore, center = false);
        // both mouths chamfered
        translate([0, 0, -0.01 + 100000 - 0.01]) cylinder(h = lead, d1 = bore, d2 = bore + 2 * lead);
    }
}

// Counterbore for a cap/button head: head pocket + shank clearance, both
// derived from the same nominal head diameter and thread.
module asm_counterbore(head_d, head_k, thread_d, cls = "clearance") {
    lead = fit_lead(head_d);
    union() {
        asm_through_hole(thread_d, cls);
        translate([0, 0, -0.01])
            cylinder(h = head_k + fit_delta_d("location"), d = fit_d(head_d, cls));
        translate([0, 0, head_k + fit_delta_d("location") - lead])
            cylinder(h = lead + 0.01, d1 = fit_d(head_d, cls), d2 = fit_d(head_d, cls) + 2 * lead);
    }
}

// ---- nut traps ---------------------------------------------------------------
// Hex nut trap: across-flats s, nut thickness m, from the SAME s.
// Oriented flat-down, opening at -Z (subtract from the part's underside).
module asm_hex_nut_trap(s, m, cls = "location") {
    af = fit_d(s, cls);
    translate([0, 0, -0.01]) {
        cylinder(h = m + fit_delta_d("location") + 0.01, d = af / cos(30), $fn = 6);
        // lead-in on the outer mouth (deeper into the part is -Z here)
        translate([0, 0, m + fit_delta_d("location") - 0.01])
            cylinder(h = fit_lead(af), d1 = af / cos(30), d2 = af / cos(30) + 2 * fit_lead(af), $fn = 6);
    }
}

// Square nut trap: side s, thickness m.
module asm_square_nut_trap(s, m, cls = "location") {
    side = fit_d(s, cls);
    lead = fit_lead(side);
    translate([0, 0, -0.01]) {
        translate([-side / 2, -side / 2, 0])
            cube([side, side, m + fit_delta_d("location") + 0.01]);
        translate([-side / 2, -side / 2, m + fit_delta_d("location") - 0.01])
            cube([side + 2 * lead, side + 2 * lead, lead + 0.02]);
    }
}

// ---- heat-set insert boss -----------------------------------------------------
// Solid boss (MALE — union it on): outer bore holds a brass insert of
// insert_od/insert_len; the top is counterbored so the insert sits flush.
module asm_insert_boss(insert_od, insert_len, wall = 2.4, cls = "snug") {
    bore = fit_d(insert_od, cls);
    od = bore + 2 * wall;
    difference() {
        cylinder(d = od, h = insert_len + wall);
        translate([0, 0, wall])
            cylinder(d = bore, h = insert_len + 0.01);
        // entry chamfer at the insert mouth
        translate([0, 0, wall - fit_lead(bore) + fit_lead(bore)])
            cylinder(h = fit_lead(bore), d1 = bore + 2 * fit_lead(bore), d2 = bore);
    }
}
