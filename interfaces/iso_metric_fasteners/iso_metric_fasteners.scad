// ============================================================================
// interfaces/iso_metric_fasteners/iso_metric_fasteners.scad
// ----------------------------------------------------------------------------
// ISO metric fastener features for M2–M6, keyed by size. All numbers come
// from <id>.consts.scad (GENERATED from spec.json — edit spec.json, not this).
// Mating geometry is built from lib/asm.scad, so tolerances come from
// lib/fits.scad and never appear here as literals.

use <../../lib/fits.scad>;
use <../../lib/asm.scad>;
include <iso_metric_fasteners.consts.scad>;

// ---- size key lookup -------------------------------------------------------
function _fsz(size) =
    size == "m2"   ? [M2__THREAD,   M2__HOLE_CLEAR,   M2__CAP_D,   M2__CAP_K,   M2__BTN_D,   M2__BTN_K,   M2__NUT_AF,   M2__NUT_M,   M2__SQ_AF,   M2__SQ_M,   M2__INSERT_OD,   M2__INSERT_LEN] :
    size == "m2_5" ? [M2_5__THREAD, M2_5__HOLE_CLEAR, M2_5__CAP_D, M2_5__CAP_K, M2_5__BTN_D, M2_5__BTN_K, M2_5__NUT_AF, M2_5__NUT_M, M2_5__SQ_AF, M2_5__SQ_M, M2_5__INSERT_OD, M2_5__INSERT_LEN] :
    size == "m3"   ? [M3__THREAD,   M3__HOLE_CLEAR,   M3__CAP_D,   M3__CAP_K,   M3__BTN_D,   M3__BTN_K,   M3__NUT_AF,   M3__NUT_M,   M3__SQ_AF,   M3__SQ_M,   M3__INSERT_OD,   M3__INSERT_LEN] :
    size == "m4"   ? [M4__THREAD,   M4__HOLE_CLEAR,   M4__CAP_D,   M4__CAP_K,   M4__BTN_D,   M4__BTN_K,   M4__NUT_AF,   M4__NUT_M,   M4__SQ_AF,   M4__SQ_M,   M4__INSERT_OD,   M4__INSERT_LEN] :
    size == "m5"   ? [M5__THREAD,   M5__HOLE_CLEAR,   M5__CAP_D,   M5__CAP_K,   M5__BTN_D,   M5__BTN_K,   M5__NUT_AF,   M5__NUT_M,   M5__SQ_AF,   M5__SQ_M,   M5__INSERT_OD,   M5__INSERT_LEN] :
    size == "m6"   ? [M6__THREAD,   M6__HOLE_CLEAR,   M6__CAP_D,   M6__CAP_K,   M6__BTN_D,   M6__BTN_K,   M6__NUT_AF,   M6__NUT_M,   M6__SQ_AF,   M6__SQ_M,   M6__INSERT_OD,   M6__INSERT_LEN] :
    assert(false, str("unknown size '", size, "'")) [];

// ---- features (FEMALE tools subtract; MALE solids union) ---------------------

// ISO-273 normal clearance through hole.
module fastener_through_hole(size, cls = "clearance") {
    asm_through_hole(_fsz(size)[1]);
}

// ISO 4762 socket-head-cap counterbore, opening at z=0 going up.
module fastener_cap_counterbore(size, cls = "clearance") {
    s = _fsz(size);
    asm_counterbore(s[2], s[3], s[0], cls);
}

// ISO 7380-1 button-head counterbore.
module fastener_button_counterbore(size, cls = "clearance") {
    s = _fsz(size);
    asm_counterbore(s[4], s[5], s[0], cls);
}

// Hex nut trap (ISO 4032 across-flats): pocket opening at z=0, extending +Z
// to the nut thickness — subtract from a face whose underside sits at z=0.
module fastener_hex_trap(size, cls = "location") {
    s = _fsz(size);
    asm_hex_nut_trap(s[6], s[7], cls);
}

// Square nut trap (DIN 562 side): same orientation as the hex trap.
module fastener_square_trap(size, cls = "location") {
    s = _fsz(size);
    asm_square_nut_trap(s[8], s[9], cls);
}

// Heat-set insert boss (MALE). Base at z=0, growing +Z.
module fastener_insert_boss(size, wall = 2.4, cls = "snug") {
    s = _fsz(size);
    asm_insert_boss(s[10], s[11], wall, cls);
}
