#!/usr/bin/env node
// ============================================================================
// scripts/gen-consts.mjs — spec.json → <id>.consts.scad
// ----------------------------------------------------------------------------
// Every number lives once, in spec.json. This emits the OpenSCAD constants
// from it; the generated files are checked in. --check exits non-zero if any
// checked-in consts file is stale relative to its spec.json.

import { readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

// NOTE: no path.dirname — trailing-slash URL + dirname resolves one level high
const root = fileURLToPath(new URL("../", import.meta.url));
const dir = (p) => path.join(root, "interfaces", p);
const check = process.argv.includes("--check");

// spec.json nominals → SCAD identifiers: m3.cap_d → M3__CAP_D
const ident = (parts) => parts.join("__").toUpperCase().replace(/[^A-Z0-9_]/g, "_");

function flatten(obj, prefix = [], out = []) {
  for (const [k, v] of Object.entries(obj)) {
    if (typeof v === "number") out.push([ident([...prefix, k]), v]);
    else if (v && typeof v === "object") flatten(v, [...prefix, k], out);
  }
  return out;
}

function render(id, version, entries) {
  const lines = [
    "// GENERATED from spec.json by scripts/gen-consts.mjs — DO NOT EDIT.",
    `// interface: ${id} v${version}`,
    "",
    ...entries.map(([k, v]) => {
      const num = Number.isInteger(v) ? String(v) : v.toFixed(4).replace(/0+$/, "").replace(/\.$/, "");
      return `${k} = ${num};`;
    }),
    "",
  ];
  return lines.join("\n");
}

let stale = 0;
for (const entry of readdirSync(path.join(root, "interfaces"), { withFileTypes: true })) {
  if (!entry.isDirectory()) continue;
  const specPath = dir(`${entry.name}/spec.json`);
  if (!existsSync(specPath)) continue;
  const spec = JSON.parse(readFileSync(specPath, "utf8"));
  const text = render(spec.id, spec.version, flatten(spec.nominals));
  const outPath = dir(`${entry.name}/${spec.id}.consts.scad`);
  if (!existsSync(outPath)) {
    if (check) { console.error(`STALE: ${spec.id}.consts.scad missing`); stale++; }
    else { writeFileSync(outPath, text); console.log(`wrote ${spec.id}.consts.scad`); }
  } else if (readFileSync(outPath, "utf8") !== text) {
    if (check) { console.error(`STALE: ${spec.id}.consts.scad differs from spec.json`); stale++; }
    else { writeFileSync(outPath, text); console.log(`regenerated ${spec.id}.consts.scad`); }
  }
}

if (stale) {
  console.error(`\n${stale} generated file(s) stale — run: npm run gen`);
  process.exit(1);
}
console.log("consts fresh.");
