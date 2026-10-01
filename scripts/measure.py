#!/usr/bin/env python3
"""
scripts/measure.py — evaluate spec.json assertions against a compiled STL.

Loads the mesh with trimesh, computes bbox / volume / section geometry, and
evaluates every assertion to {pass, measured, reason}. Honest skip: anything
that cannot be measured reports available=false with a reason — never a
silent pass.

Usage: python3 scripts/measure.py <stl> <spec.json>   → JSON verdict on stdout
"""
from __future__ import annotations

import json
import sys

import trimesh


def _loop_area_centroid(verts) -> tuple[float, tuple[float, float, float]]:
    """Planar-polygon area (Newell) and centroid of a 3D vertex loop."""
    nx = ny = nz = 0.0
    cx = cy = cz = 0.0
    n = len(verts)
    for i in range(n):
        x1, y1, z1 = verts[i]
        x2, y2, z2 = verts[(i + 1) % n]
        nx += (y1 - y2) * (z1 + z2)
        ny += (z1 - z2) * (x1 + x2)
        nz += (x1 - x2) * (y1 + y2)
        cx += x1
        cy += y1
        cz += z1
    normal_len = (nx * nx + ny * ny + nz * nz) ** 0.5
    area = float(normal_len / 2.0)
    cent = (float(cx / n), float(cy / n), float(cz / n))
    return area, cent


def section_loops(mesh: trimesh.Trimesh, axis: str, at: float):
    """Closed loops of the mesh cross-section at plane `axis = at`.

    Returns [(area, centroid_xyz)] for every discrete closed boundary loop in
    WORLD coordinates — the outer boundary plus one loop per interior hole.
    """
    origin = [0.0, 0.0, 0.0]
    normal = [0.0, 0.0, 0.0]
    idx = {"x": 0, "y": 1, "z": 2}[axis]
    origin[idx] = at
    normal[idx] = 1.0
    section = mesh.section(plane_origin=origin, plane_normal=normal)
    if section is None:
        return []
    loops = []
    for verts in section.discrete:
        area, cent = _loop_area_centroid(verts)
        loops.append((area, cent))
    return loops


def evaluate(mesh: trimesh.Trimesh, spec: dict) -> list[dict]:
    verdicts = []
    for a in spec.get("assertions", []):
        v = {
            "name": a["name"],
            "type": a["type"],
            "expect": a["expect"],
            "tol": a["tol"],
            "pass": False,
            "available": True,
            "measured": None,
            "reason": "",
        }
        try:
            if a["type"] == "bbox":
                lo, hi = mesh.bounds
                dims = {
                    "x": round(float(hi[0] - lo[0]), 4),
                    "y": round(float(hi[1] - lo[1]), 4),
                    "z": round(float(hi[2] - lo[2]), 4),
                }
                v["measured"] = dims
                ok = all(
                    abs(dims[k] - a["expect"][k]) <= a["tol"] for k in a["expect"]
                )
                v["pass"] = bool(ok)
                if not ok:
                    v["reason"] = f"dims {dims} vs expect {a['expect']} ±{a['tol']}"

            elif a["type"] == "volume":
                vol = float(mesh.volume)
                v["measured"] = round(vol, 2)
                v["pass"] = abs(vol - a["expect"]) <= a["tol"]
                if not v["pass"]:
                    v["reason"] = f"volume {vol:.1f} vs {a['expect']} ±{a['tol']}"

            elif a["type"] == "section_area":
                plane = a.get("plane") or {}
                loops = section_loops(mesh, plane.get("axis", "z"), plane.get("at", 0))
                if not loops:
                    v["available"] = False
                    v["reason"] = f"no closed loops at {plane}"
                else:
                    # discrete loops are co-wound: the outer boundary is the
                    # largest; every other loop is a hole to SUBTRACT
                    areas = sorted((x[0] for x in loops), reverse=True)
                    area = areas[0] - sum(areas[1:])
                    v["measured"] = round(area, 2)
                    v["pass"] = bool(abs(area - a["expect"]) <= a["tol"])
                    if not v["pass"]:
                        v["reason"] = f"section area {area:.1f} vs {a['expect']} ±{a['tol']}"

            elif a["type"] == "hole_spacing":
                plane = a.get("plane") or {}
                axis = a.get("measure_axis", "x")
                loops = section_loops(mesh, plane.get("axis", "z"), plane.get("at", 0))
                if len(loops) < 3:
                    v["available"] = False
                    v["reason"] = f"need >=3 loops (outer + 2 holes) at {plane}, got {len(loops)}"
                else:
                    # drop the outer boundary (largest loop), project centres
                    holes = sorted(loops, key=lambda x: -x[0])[1:]
                    m = {"x": 0, "y": 1, "z": 2}[axis]
                    centres = sorted(float(round(h[1][m], 4)) for h in holes)
                    gaps = [float(round(b - c, 4)) for c, b in zip(centres, centres[1:])]
                    # at least one true pitch pair: consecutive centres gap == expect
                    v["measured"] = gaps
                    v["pass"] = bool(any(abs(g - a["expect"]) <= a["tol"] for g in gaps))
                    if not v["pass"]:
                        v["reason"] = f"no adjacent pair at {a['expect']} ±{a['tol']} (gaps {gaps})"

            elif a["type"] == "clearance":
                v["available"] = False
                v["reason"] = "clearance assertions require paired fixtures — not yet implemented"

            else:
                v["available"] = False
                v["reason"] = f"unknown assertion type {a['type']}"

        except Exception as e:  # noqa: BLE001
            v["available"] = False
            v["reason"] = f"measurement error: {e}"
        verdicts.append(v)
    return verdicts


def main() -> None:
    stl_path, spec_path = sys.argv[1], sys.argv[2]
    spec = json.load(open(spec_path))  # noqa: SIM115
    try:
        mesh = trimesh.load(stl_path, force="mesh")
    except Exception as e:  # noqa: BLE001
        print(json.dumps({"ok": False, "reason": f"mesh load failed: {e}"}))
        sys.exit(0)
    print(json.dumps({"ok": True, "verdicts": evaluate(mesh, spec)}, indent=1))


if __name__ == "__main__":
    main()
