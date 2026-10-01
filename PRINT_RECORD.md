# PRINT_RECORD.md — fit-gauge measurement log

One row per cell. This table is what turns `lib/fits.scad` from hypotheses
into data. **A gauge that isn't recorded is a gauge that wasn't printed.**

## Print conditions (both plates, ONE job)

| field | value |
|---|---|
| printer | _e.g. Bambu P1S_ |
| nozzle Ø / material | _e.g. 0.4 / PLA (brand)_ |
| layer height / walls / infill | _e.g. 0.20 / 3 / 15 %_ |
| **hole compensation** | **OFF** — must be off, or the data only holds for this slicer profile |
| **elephant-foot compensation** | **OFF** — same reason |
| slicer + profile name | _record either way_ |
| date | |

Files: `reports/gauges-fasteners.stl` (104×64×7, 18 holes Ø2–7) and
`reports/gauges-bearings.stl` (176×140×9, 12 bores Ø16–32). Print both in the
same job, plates flat, hole axes +Z, no supports, no brim (or brim outside
the embossing).

## How to measure

- Holes: **pin gauges** where possible (calipers splay on small holes); if
  calipers only, measure three axes and record the mean.
- Bores ≥16 mm: calipers are fine; take the mean of two perpendicular axes.
- Fit judgment per class, per size: **free** (slides) / **hand** (assembles,
  no slop) / **force** (press) / **won't** (binds or impossible).

## Plate A — iso_metric_fasteners (nominal = thread Ø)

| size | class | hole Ø (design) | measured Ø | judgment | note |
|---|---|---|---|---|---|
| M2 | clearance | 2.35 | | | |
| M2 | location | 2.15 | | | |
| M2 | snug | 1.95 | | | |
| M2.5 | clearance | 2.85 | | | |
| M2.5 | location | 2.65 | | | |
| M2.5 | snug | 2.45 | | | |
| M3 | clearance | 3.35 | | | |
| M3 | location | 3.15 | | | |
| M3 | snug | 2.95 | | | |
| M4 | clearance | 4.35 | | | |
| M4 | location | 4.15 | | | |
| M4 | snug | 3.95 | | | |
| M5 | clearance | 5.35 | | | |
| M5 | location | 5.15 | | | |
| M5 | snug | 4.95 | | | |
| M6 | clearance | 6.35 | | | |
| M6 | location | 6.15 | | | |
| M6 | snug | 5.95 | | | |

## Plate B — bearing_iso15 (nominal = bearing OD)

| bearing | class | bore Ø (design) | measured Ø | judgment | note |
|---|---|---|---|---|---|
| 625 (16) | clearance | 16.35 | | | |
| 625 (16) | location | 16.15 | | | |
| 625 (16) | snug | 15.95 | | | |
| 608 (22) | clearance | 22.35 | | | |
| 608 (22) | location | 22.15 | | | |
| 608 (22) | snug | 21.95 | | | |
| 6001 (28) | clearance | 28.35 | | | |
| 6001 (28) | location | 28.15 | | | |
| 6001 (28) | snug | 27.95 | | | |
| 6002 (32) | clearance | 32.35 | | | |
| 6002 (32) | location | 32.15 | | | |
| 6002 (32) | snug | 31.95 | | | |

## After measuring — fit the curve

The current table is a constant diametral offset. Expect small holes to come
out proportionally MORE undersized than large ones (absolute, curvature-
dependent error sources), i.e. the right model is likely **delta(d)** rather
than a constant. With 18 + 12 points across a 16× diameter spread there is
enough to see whether the curve is flat, and to fit delta(d) = a + b·d if it
isn't. Update `lib/fits.scad` (and `fitTolerance` in `src/index.ts`) from the
fitted values — one table, both places, they must match.
