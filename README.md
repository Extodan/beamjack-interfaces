# @beamjack/interfaces

Parametric mating interface definitions for 3D-printed parts — **compiled, measured, assertion-tested** OpenSCAD modules with fit classes and recorded provenance.

**What this library is actually for.** Modern LLMs already recall the common dimension tables — 2020 extrusion and 608 bearings are among the most-documented numbers in the hobby, and a bare datum is worth approximately nothing. The value here is the two things a model *cannot* do: apply a **measured, printer-specific fit offset** (`asm_socket(d, …, cls)` is where a 4.2 mm nominal becomes a hole that actually passes an M4 bolt on YOUR machine), and be **right about interfaces too obscure to be in training data**. Every claim is verified against compiled geometry, not asserted. The offset table is currently provisional pending gauge prints — the mechanism ships now, the measured numbers land with them.

> Every dimension in this library is **verified against compiled geometry, not asserted** — `scripts/verify.mjs` compiles each interface's fixture with OpenSCAD, measures the result with trimesh, and evaluates every claim in its `spec.json`. Reports land in `reports/`. An assertion that cannot run reports `available: false` with a reason; nothing passes silently.


## Use

```scad
use <lib/asm.scad>;                    // asm_peg / asm_socket / counterbores / nut traps
include <interfaces/tslot_2020/tslot_2020.consts.scad>;
use <interfaces/tslot_2020/tslot_2020.scad>;

difference() {
    my_mounting_ear();
    translate([10, 10, 0]) tslot_bracket_face();   // M5 holes on the 20 mm grid
}
```

Or from TypeScript:

```ts
import { byId, featuresByKind, fitTolerance } from "@beamjack/interfaces";
const tslot = byId("tslot_2020");                 // typed spec, straight from spec.json
const sockets = featuresByKind("socket");         // every socket feature across the library
fitTolerance("clearance");                        // 0.35 mm diametral (provisional — see gauges)
```

## Fit classes

Every mating feature derives its clearance from one table in `lib/fits.scad`:

| class | behaviour | diametral delta |
|---|---|---|
| `clearance` | slides freely | +0.35 mm |
| `location` | assembles by hand, no slop | +0.15 mm |
| `snug` | press fit, needs force | −0.05 mm |

**These are starting hypotheses, not measurements.** Each interface ships a printable `gauge.scad` carrying its mating feature in all three classes; print them, record which class actually fits your printer, and correct the table. Until those prints happen, treat every fit as provisional.

## Repository layout

```
lib/            fits.scad (tolerance table) · asm.scad (typed features, mirrors the Beamjack engine)
interfaces/     <id>/{spec.json, <id>.scad, <id>.consts.scad (generated), test.scad, gauge.scad, README}
schema/         JSON Schema for spec.json
scripts/        gen-consts.mjs (spec → consts) · verify.mjs (compile + measure + assert) · measure.py
fixtures/       interfaces-baseline.json — the regression baseline
reports/        machine-readable verification output
```

## Development

```sh
npm run gen          # spec.json → *.consts.scad (CI fails if stale)
npm run verify       # compile + measure + assert every interface
npm run verify:check # …and diff against the baseline; non-zero on regression
```

## Known limitation: the consumer's mate gate checks within a feature, not across a size family

`src/index.ts` exposes `mateGate`, the seam the Beamjack engine calls on
finished parts. Its honest scope, stated plainly: **it compares an asm
diameter against each feature's single nominal — it cannot see across sizes
within a family.** A 2.4 mm socket is explainable as M2-clearance
(`2.0 + 0.35`) or M2.5-snug (`2.5 − 0.05`); today's schema carries one
`nominal_ref` per feature, so the gate returns CLEAN where a cross-size
ambiguity exists. Those are false CLEANs, live in the current release — not
a hypothetical.

Why not fixed yet: whether the fit bands actually overlap in practice is
exactly what the gauge-print data will measure. Designing a family-shaped
`nominal_ref` before the real offsets are known would be a schema migration
done twice. When the measured `delta(d)` lands, the schema grows size
families and the gate reports cross-size ambiguity explicitly instead of
picking a winner.

## Licensing

Code: **MIT**. Dimension data (`spec.json` nominals): **CC0** — dimensions are facts. Every interface records its dimensional source and that source's licence in [SOURCES.md](SOURCES.md); implementations are written from scratch against published dimensions. Trademarks are used nominatively ("compatible with the 42 mm Gridfinity grid"); no endorsement is implied.
