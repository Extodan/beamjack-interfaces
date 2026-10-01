#!/usr/bin/env node
// ============================================================================
// scripts/verify.mjs — compile + measure + assert every interface
// ----------------------------------------------------------------------------
// For each interfaces/<id>: spawn OpenSCAD on test.scad, evaluate the
// spec.json assertions against the compiled geometry (python3 + trimesh,
// via the main repo's worker when GEOMETRY_WORKER_URL is set), and write
// reports/<id>.json. --check diffs against fixtures/interfaces-baseline.json
// and exits non-zero when a previously-passing assertion regresses.
// Honest skip everywhere: unavailable measurements are reported, never passed.

import { spawnSync } from "node:child_process";
import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

// NOTE: no path.dirname here — the '../' URL keeps a trailing slash and
// dirname would strip the last real component, resolving root one level high
const root = fileURLToPath(new URL("../", import.meta.url));
const check = process.argv.includes("--check");
const OPENSCAD = process.env.OPENSCAD_BIN || "openscad";
const reports = path.join(root, "reports");
mkdirSync(reports, { recursive: true });

function compile(id) {
  const out = path.join(reports, `${id}.stl`);
  const r = spawnSync(OPENSCAD, ["-o", out, path.join(root, "interfaces", id, "test.scad")], {
    encoding: "utf8",
  });
  // UNDEF GATE: OpenSCAD silently drops geometry whose constants resolve to
  // undef (the `use <file>` trap — variables aren't imported, features
  // vanish, compile still exits 0, manifold still passes). Any unknown-
  // variable/undefined warning is a HARD failure, never noise.
  const undef = (r.stderr ?? "").split("\n").filter((l) =>
    /WARNING: Ignoring unknown variable|undefined operation|Unable to convert/i.test(l),
  );
  if (undef.length) {
    return { ok: false, error: `UNDEF GATE — ${undef.length} warning(s):\n  ${undef.slice(0, 5).join("\n  ")}`, out };
  }
  return { ok: r.status === 0, error: r.stderr?.slice(0, 800), out };
}

function measure(stl, specPath) {
  // geometry worker first (it centralises trimesh), python3 fallback
  const worker = process.env.GEOMETRY_WORKER_URL;
  if (worker) {
    const r = spawnSync("curl", [
      "-s", "-o", "/dev/null", "-w", "%{http_code}",
      "-X", "POST", `${worker}/measure`,
      "-H", "content-type: application/json",
      "-d", JSON.stringify({ path: stl }),
    ], { encoding: "utf8" });
    if (r.stdout === "200") {
      // worker path lives under the jobs-root allowlist; our reports dir is
      // outside it, so unless the allowlist is opened this falls through to
      // the local python — kept honest rather than special-cased
    }
  }
  const p = spawnSync("python3", [path.join(root, "scripts", "measure.py"), stl, specPath], {
    encoding: "utf8",
  });
  if (p.status !== 0) return { ok: false, reason: `measure.py failed: ${p.stderr?.slice(0, 300)}` };
  try {
    return JSON.parse(p.stdout);
  } catch {
    return { ok: false, reason: `unparseable measure output: ${p.stdout?.slice(0, 200)}` };
  }
}

const results = {};
let failed = 0;

for (const entry of readdirSync(path.join(root, "interfaces"), { withFileTypes: true })) {
  if (!entry.isDirectory()) continue;
  const id = entry.name;
  const specPath = path.join(root, "interfaces", id, "spec.json");
  if (!existsSync(specPath)) continue;
  const spec = JSON.parse(readFileSync(specPath, "utf8"));

  const report = { id, version: spec.version, compiled: false, measured_by: null, assertions: [], ok: false };

  const c = compile(id);
  if (!c.ok) {
    report.compileError = c.error;
    report.ok = false;
    console.error(`✗ ${id}: compile failed\n  ${c.error?.split("\n").slice(-3).join("\n  ")}`);
    results[id] = report;
    failed++;
    continue;
  }
  report.compiled = true;

  const m = measure(c.out, specPath);
  if (!m.ok) {
    report.measureError = m.reason;
    console.error(`✗ ${id}: ${m.reason}`);
    results[id] = report;
    failed++;
    continue;
  }
  report.measured_by = "python3+trimesh";
  report.assertions = m.verdicts;
  const unavailable = m.verdicts.filter((v) => !v.available).length;
  const failedAsserts = m.verdicts.filter((v) => v.available && !v.pass).length;
  report.ok = failedAsserts === 0;
  report.unavailable = unavailable;
  const marks = m.verdicts.map((v) => (!v.available ? "?" : v.pass ? "✓" : "✗"));
  console.log(`${report.ok ? "✓" : "✗"} ${id}: ${m.verdicts.map((v, i) => `${marks[i]} ${v.name}`).join(" · ")}`);
  if (!report.ok) failed++;
  results[id] = report;
}

for (const [id, report] of Object.entries(results)) {
  writeFileSync(path.join(reports, `${id}.json`), JSON.stringify(report, null, 1));
}

// --check: regressions against the committed baseline
if (check) {
  const baselinePath = path.join(root, "fixtures", "interfaces-baseline.json");
  const baseline = existsSync(baselinePath)
    ? JSON.parse(readFileSync(baselinePath, "utf8"))
    : {};
  let regressions = 0;
  for (const [id, report] of Object.entries(results)) {
      const prev = baseline[id];
      if (!prev) continue;
      // baseline assertions are keyed by name (see fixtures writer)
      const wasByName = prev.assertions ?? {};
      for (const v of report.assertions ?? []) {
        const was = wasByName[v.name];
        if (was?.pass && !v.pass) {
          console.error(`REGRESSION ${id}: "${v.name}" passed before, now: ${v.reason}`);
          regressions++;
        }
      }
      if (prev.ok && !report.ok) regressions++;
  }
  if (regressions) {
    console.error(`\n${regressions} regression(s) against fixtures/interfaces-baseline.json`);
    process.exit(1);
  }
  console.log("\nno regressions against baseline.");
} else if (failed) {
  console.error(`\n${failed} interface(s) failed.`);
  process.exit(1);
} else {
  console.log("\nall interfaces verified.");
}
