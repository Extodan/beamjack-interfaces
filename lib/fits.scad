// ============================================================================
// lib/fits.scad — fit classes and the tolerance table
// ----------------------------------------------------------------------------
// Every mating feature in this library derives its clearance from THIS table,
// never from a second literal. Mirrors the engine's assembly.scad convention
// (asm_socket bore = nominal + signed fit offset) with the engine's class
// names aliased for compatibility ("press" == "snug").
//
// !! STARTING HYPOTHESES, NOT MEASUREMENTS !!
// These are diametral deltas for a 0.4 mm-nozzle FDM printer, PLA, default
// wall settings. They are corrected by physically printing each interface's
// gauge.scad and recording which class actually fits — see README § gauges.
// Until those prints happen and the table is updated, treat every generated
// fit as provisional.

// Diametral offsets (mm), keyed by class. Radial = half these values.
fit_delta = [
  ["clearance", 0.35],  // slides freely
  ["location",  0.15],  // assembles by hand, no slop
  ["snug",     -0.05],  // press fit, needs force
  ["press",    -0.05],  // engine alias for snug
  ["snap",      0.20],  // engine class kept for compatibility
];

function fit_delta_d(cls) =
    let (hit = [for (e = fit_delta) if (e[0] == cls) e[1]])
    len(hit) == 1 ? hit[0]
  : assert(false, str("unknown fit class '", cls, "'")) 0;

// Radial offset — the engine's asm_fit convention (asm_socket adds 2× this).
function fit_delta_r(cls) = fit_delta_d(cls) / 2;

// Resolve a nominal through a fit class: the ONE place tolerances enter.
function fit_d(nominal, cls) = nominal + fit_delta_d(cls);

// Lead-in chamfer length for a feature of diameter d — self-centring mouth.
// Same formula as the engine (max(0.6, 0.15*d)) so parts generated against
// either library seat identically.
function fit_lead(d) = max(0.6, 0.15 * d);
