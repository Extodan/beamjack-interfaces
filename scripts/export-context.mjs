#!/usr/bin/env node
// ============================================================================
// scripts/export-context.mjs — registry → backend injection context
// ----------------------------------------------------------------------------
// Emits interfaces-context.json: everything the engine's two seams need,
// nothing it doesn't. The backend loads this file (path via
// INTERFACES_CONTEXT_PATH, default alongside this repo) — the library is the
// single source of truth, the backend never parses spec.json itself.

import { readFileSync, readdirSync, existsSync, writeFileSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("../", import.meta.url));

// fit table mirrors lib/fits.scad + src/index.ts (all three must match)
const FIT = { clearance: 0.35, location: 0.15, snug: -0.05 };

function flatten(obj, prefix = [], out = {}) {
  for (const [k, v] of Object.entries(obj)) {
    if (typeof v === "number") out[[...prefix, k].join(".")] = v;
    else if (v && typeof v === "object") flatten(v, [...prefix, k], out);
  }
  return out;
}

// prompt keywords per interface — what a user's sentence would actually say
const KEYWORDS = {
  iso_metric_fasteners: ["m2 screw", "m2.5 screw", "m3 screw", "m4 screw", "m5 screw", "m6 screw",
    "m2 bolt", "m3 bolt", "m4 bolt", "m5 bolt", "m6 bolt", "m3 nut", "m4 nut", "m5 nut",
    "heat-set insert", "heat set insert", "metric fastener"],
  bearing_iso15: ["608 bearing", "608-2rs", "625 bearing", "6001 bearing", "6002 bearing",
    "bearing seat", "bearing 608", "bearing 625", "bearing 6001", "bearing 6002"],
  tslot_2020: ["2020 extrusion", "2040 extrusion", "t-slot", "tslot", "v-slot", "vslot",
    "2020 profile", "extrusion rail", "t-nut", "tnut"],
};

const out = { generated: new Date().toISOString(), fitTable: FIT, interfaces: [] };

for (const entry of readdirSync(path.join(root, "interfaces"), { withFileTypes: true })) {
  if (!entry.isDirectory()) continue;
  const specPath = path.join(root, "interfaces", entry.name, "spec.json");
  if (!existsSync(specPath)) continue;
  const spec = JSON.parse(readFileSync(specPath, "utf8"));
  out.interfaces.push({
    id: spec.id,
    title: spec.title,
    version: spec.version,
    summary: spec.summary,
    keywords: KEYWORDS[spec.id] ?? [],
    nominals: flatten(spec.nominals),
    features: spec.features.map((f) => {
      const base = spec.nominals;
      const ref = f.nominal_ref.split(".");
      let v = base;
      for (const r of ref) v = v?.[r];
      return {
        name: f.name,
        kind: f.kind,
        nominal: typeof v === "number" ? v : null,
        fitted: typeof v === "number" ? v + FIT[f.fit_class_default] : null,
        fitClass: f.fit_class_default,
      };
    }),
  });
}

const dest = path.join(root, "interfaces-context.json");
writeFileSync(dest, JSON.stringify(out, null, 1) + "\n");
console.log(`wrote ${path.basename(dest)} — ${out.interfaces.length} interfaces, ` +
  `${out.interfaces.reduce((n, i) => n + i.features.length, 0)} features`);
