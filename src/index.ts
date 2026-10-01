/**
 * @beamjack/interfaces — typed consumer.
 *
 * Loads every interfaces/<id>/spec.json at import time and exposes typed
 * lookups. This is the seam the Beamjack engine uses: generator-context
 * injection (nominals + features for a mentioned interface) and the mate
 * gate (socket-vs-nominal assertion within a declared fit class).
 */

import { readFileSync, readdirSync, existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

// ── types (kept in lockstep with schema/interface.schema.json) ────────────

export type FitClass = "clearance" | "location" | "snug";

export interface InterfaceSource {
  name: string;
  url?: string;
  licence: string;
  notes?: string;
}

export interface NominalTree {
  [key: string]: number | NominalTree;
}

export type FeatureKind = "peg" | "socket" | "hole" | "profile" | "face";

export interface MatingFeature {
  name: string;
  kind: FeatureKind;
  nominal_ref: string;
  fit_class_default: FitClass;
  direction: "+z" | "-z" | "radial" | "normal";
}

export type AssertionType =
  | "bbox"
  | "hole_spacing"
  | "volume"
  | "section_area"
  | "clearance";

export interface Assertion {
  name: string;
  type: AssertionType;
  expect: number | Record<string, number>;
  tol: number;
  fixture?: string;
  plane?: { axis: "x" | "y" | "z"; at: number };
  measure_axis?: "x" | "y" | "z";
}

export interface InterfaceSpec {
  id: string;
  title: string;
  version: string;
  summary: string;
  mates_with: string[];
  source: InterfaceSource;
  units: "mm";
  nominals: NominalTree;
  features: MatingFeature[];
  assertions: Assertion[];
  print_notes: string;
}

// ── loading ────────────────────────────────────────────────────────────────

const repoRoot = fileURLToPath(new URL("../", import.meta.url));

function loadAll(): InterfaceSpec[] {
  const dir = path.join(repoRoot, "interfaces");
  const specs: InterfaceSpec[] = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (!entry.isDirectory()) continue;
    const specPath = path.join(dir, entry.name, "spec.json");
    if (!existsSync(specPath)) continue;
    specs.push(JSON.parse(readFileSync(specPath, "utf8")));
  }
  return specs.sort((a, b) => a.id.localeCompare(b.id));
}

export const interfaces: readonly InterfaceSpec[] = loadAll();

// ── lookups ────────────────────────────────────────────────────────────────

export function byId(id: string): InterfaceSpec | undefined {
  return interfaces.find((i) => i.id === id);
}

export function featuresByKind(kind: FeatureKind): MatingFeature[] {
  return interfaces.flatMap((i) => i.features.filter((f) => f.kind === kind));
}

/** Resolve a dotted nominal path ("bracket.hole_pitch") to its number. */
export function nominal(spec: InterfaceSpec, ref: string): number | undefined {
  let node: number | NominalTree | undefined = spec.nominals;
  for (const part of ref.split(".")) {
    if (node && typeof node === "object") node = node[part];
    else return undefined;
  }
  return typeof node === "number" ? node : undefined;
}

// ── fits (mirrors lib/fits.scad — keep the two in step) ───────────────────

const FIT_TABLE: Record<FitClass, number> = {
  clearance: 0.35,
  location: 0.15,
  snug: -0.05,
};

/** Diametral tolerance for a fit class. PROVISIONAL until gauge prints land. */
export function fitTolerance(cls: FitClass): number {
  return FIT_TABLE[cls];
}

/** Resolve a feature's nominal through its fit class: the mate-gate number. */
export function fittedNominal(spec: InterfaceSpec, feature: MatingFeature, cls?: FitClass): number | undefined {
  const base = nominal(spec, feature.nominal_ref);
  if (base === undefined) return undefined;
  return base + fitTolerance(cls ?? feature.fit_class_default);
}

/**
 * Mate gate: assert a measured socket/peg dimension matches the registry
 * nominal within the declared fit class. Returns a verdict, never throws —
 * the caller decides how loudly to fail.
 */
export function mateGate(
  id: string,
  featureName: string,
  measured: number,
  tolMm = 0.1,
): { ok: boolean; expected?: number; reason: string } {
  const spec = byId(id);
  if (!spec) return { ok: false, reason: `unknown interface "${id}"` };
  const feature = spec.features.find((f) => f.name === featureName);
  if (!feature) return { ok: false, reason: `interface "${id}" has no feature "${featureName}"` };
  const expected = fittedNominal(spec, feature);
  if (expected === undefined) {
    return { ok: false, reason: `nominal "${feature.nominal_ref}" not found in ${id}` };
  }
  const ok = Math.abs(measured - expected) <= tolMm;
  return {
    ok,
    expected,
    reason: ok
      ? "matched"
      : `measured ${measured.toFixed(3)} vs fitted nominal ${expected.toFixed(3)} (±${tolMm})`,
  };
}
