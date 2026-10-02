# Service print order — gauge plates + A1

## What to order

Upload these three files to any print service (JLCPCB 3D Printing,
Craftcloud, Hubs, Shapeways — FDM, PLA):

| file | size |
|---|---|
| `gauges-fasteners.stl` | 104 × 64 × 7 mm, 18 holes |
| `gauges-bearings.stl` | 176 × 140 × 9 mm, 12 bores |
| `A1-registry-context-part.stl` | 38.8 × 66.8 × 122.8 mm |

All three in ONE order if the build volume allows (250×250 bed fits all).

## Print specs (state these explicitly in the order notes)

- **FDM, PLA**, 0.2 mm layers, 3 walls
- **Hole compensation: OFF** — the raw machine is the datum
- **Elephant-foot compensation: OFF** — same reason
- No supports, no brim
- Record: printer model, nozzle diameter, material brand, layer height

## After the parts arrive

Measure every hole with pin gauges (calipers for the big bores):
- measured diameter (minimum, 2 axes)
- fit judgment: free / hand / force / won't go
- WHERE it binds: entry-only (elephant's foot) or through-depth (diametral)

Fill `PRINT_RECORD.md` in the interfaces repo and send the numbers.

## What each part answers

| part | question |
|---|---|
| gauge plates | what is delta(d) — the fit table stops being a guess |
| A1 part | the bare-nominal prediction: Ø4.2 bore won't pass an M4 |
| same job, same machine | the gauge quantifies exactly how wrong A1's bare nominal is |

The A1 part is the first object generated with registry context. It carries
32 verbatim nominals as bare literals (zero typed mates). The prediction is
specific and written before printing: the bores will print ~0.3 mm under
nominal and will not fit their fasteners. The gauge plate from the same
service, in the same material, shows what +0.35 clearance looks like on that
specific machine — the difference is the offset's value in one object pair.
