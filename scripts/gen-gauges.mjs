#!/usr/bin/env node
// ============================================================================
// scripts/gen-gauges.mjs — combined fit-gauge plates, ready to slice
// ----------------------------------------------------------------------------
// Emits ONE plate per feature family (small fastener holes 2–6 mm on one,
// bearing seats 16–32 mm on the other) so both print in the SAME job under
// identical conditions. Every hole axis is +Z (horizontal holes sag and
// bridge — characterize those separately, later). Each cell is embossed with
// its nominal and fit class; the plate edge carries interface id + version.
//
// PRINT RULES (also in PRINT_RECORD.md):
//   * slicer hole compensation and elephant-foot compensation OFF — the
//     machine's raw behaviour is the datum; the library owns compensation
//   * record printer/nozzle/material/layer height in PRINT_RECORD.md
//
// Output: reports/gauges-<family>.scad + .stl

import { spawnSync } from "node:child_process";
import { writeFileSync, mkdirSync, readFileSync, existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));
const OPENSCAD = process.env.OPENSCAD_BIN || "openscad";
const reports = path.join(root, "reports");
mkdirSync(reports, { recursive: true });

const spec = (id) => JSON.parse(readFileSync(path.join(root, "interfaces", id, "spec.json"), "utf8"));

// fit deltas mirror lib/fits.scad — generated plates must not import runtime
// state; verify.mjs --check guards the .scad side, this mirrors for the STLs
const FIT = { clearance: 0.35, location: 0.15, snug: -0.05 };
const CLASSES = ["clearance", "location", "snug"];
const clsTag = { clearance: "clr", location: "loc", snug: "snug" };

// ---- plate A: fastener through holes, 6 sizes x 3 classes ----------------
function fastenersPlate() {
  const s = spec("iso_metric_fasteners");
  const sizes = ["m2", "m2_5", "m3", "m4", "m5", "m6"];
  const label = { m2: "M2", m2_5: "M2.5", m3: "M3", m4: "M4", m5: "M5", m6: "M6" };
  const cell = 14, pitch = 16, t = 6;
  const W = sizes.length * pitch + 8;
  const H = CLASSES.length * pitch + 16;
  let scad = `$fn = 48;
// gauge plate — iso_metric_fasteners v${s.version}
module plate() { difference() {
  cube([${W}, ${H}, ${t}]);
`;
  sizes.forEach((sz, ci) => {
    const d = s.nominals[sz].thread;
    CLASSES.forEach((cls, ri) => {
      const x = 8 + ci * pitch + cell / 2;
      const y = 8 + ri * pitch + cell / 2;
      const bore = (d + FIT[cls]).toFixed(2);
      scad += `  translate([${x}, ${y}, -0.01]) cylinder(h = ${t + 0.02}, d = ${bore});\n`;
    });
  });
  scad += `} }
module emboss() {
`;
  sizes.forEach((sz, ci) => {
    CLASSES.forEach((cls, ri) => {
      const x = 8 + ci * pitch + cell / 2;
      const y = 8 + ri * pitch + cell / 2;
      scad += `  translate([${x}, ${y + 5.4}, ${t}]) linear_extrude(0.6) text("${label[sz]} ${clsTag[cls]}", size=2.4, halign="center", valign="center");\n`;
    });
  });
  scad += `  translate([${W / 2}, 3, ${t}]) linear_extrude(0.6) text("iso_metric_fasteners v${s.version}", size=3, halign="center", valign="center");
}
plate(); emboss();
`;
  return scad;
}

// ---- plate B: bearing seat bores, 4 sizes x 3 classes ----------------------
function bearingsPlate() {
  const s = spec("bearing_iso15");
  const sizes = ["b625", "b608", "b6001", "b6002"];
  const cell = 40, pitch = 42, t = 8;
  const W = sizes.length * pitch + 8;
  const H = CLASSES.length * pitch + 14;
  let scad = `$fn = 64;
// gauge plate — bearing_iso15 v${s.version}
module plate() { difference() {
  cube([${W}, ${H}, ${t}]);
`;
  sizes.forEach((sz, ci) => {
    const d = s.nominals[sz].od;
    CLASSES.forEach((cls, ri) => {
      const x = 8 + ci * pitch + cell / 2;
      const y = 8 + ri * pitch + cell / 2;
      const bore = (d + FIT[cls]).toFixed(2);
      scad += `  translate([${x}, ${y}, -0.01]) cylinder(h = ${t + 0.02}, d = ${bore});\n`;
    });
  });
  scad += `} }
module emboss() {
`;
  sizes.forEach((sz, ci) => {
    CLASSES.forEach((cls, ri) => {
      const x = 8 + ci * pitch + cell / 2;
      const y = 8 + ri * pitch + cell / 2;
      scad += `  translate([${x}, ${y + 15}, ${t}]) linear_extrude(0.6) text("${sz.slice(1)} ${clsTag[cls]}", size=3.5, halign="center", valign="center");\n`;
    });
  });
  scad += `  translate([${W / 2}, 3.5, ${t}]) linear_extrude(0.6) text("bearing_iso15 v${s.version}", size=3.5, halign="center", valign="center");
}
plate(); emboss();
`;
  return scad;
}

function build(name, scad) {
  const scadPath = path.join(reports, `gauges-${name}.scad`);
  const stlPath = path.join(reports, `gauges-${name}.stl`);
  writeFileSync(scadPath, scad);
  const r = spawnSync(OPENSCAD, ["-o", stlPath, scadPath], { encoding: "utf8" });
  if (r.status !== 0) {
    console.error(`✗ gauges-${name}: compile failed\n${r.stderr?.slice(0, 600)}`);
    process.exit(1);
  }
  const warn = (r.stderr ?? "").split("\n").filter((l) => /unknown variable|undefined/i.test(l));
  if (warn.length) {
    console.error(`✗ gauges-${name}: UNDEF WARNINGS (gate)\n  ${warn.slice(0, 4).join("\n  ")}`);
    process.exit(1);
  }
  console.log(`✓ gauges-${name}.stl`);
}

build("fasteners", fastenersPlate());
build("bearings", bearingsPlate());
console.log("\nprint BOTH plates in one job · hole/elephant-foot compensation OFF");
