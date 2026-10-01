# SOURCES.md — dimensional provenance, per interface

Every interface records where its numbers came from and what licence covers that *source document*. Implementations in this repo are written from scratch against published dimensions; no third-party geometry source is vendored, adapted, or ported.

| Interface | Dimensional source | Source licence | How used |
|---|---|---|---|
| `iso_metric_fasteners` | ISO 273 (clearance holes), ISO 4762 (socket head cap), ISO 7380-1 (button head), ISO 4032 (hex nuts), DIN 562 (square nuts) — published dimension tables | Standard documents are copyrighted; **the dimensional values are published facts** summarised from public tables | Numbers only, original implementation |
| `iso_metric_fasteners` (insert bosses) | Vendor-consensus dimensions for common brass heat-set inserts (McMaster-style M3×5 family) | Vendor catalogues, free to browse | Numbers only; marked vendor-consensus, verify against your insert |
| `bearing_iso15` | ISO 15 (radial bearings — boundary dimensions) | Standard document copyrighted; boundary dimensions (bore/OD/width) are published facts | Numbers only, original implementation. 608-2RS shares the 608 boundary |
| `tslot_2020` | OpenBuilds V-Slot published dimensional drawings | OpenBuilds publishes V-Slot drawings openly; V-slot is an open profile cut by many vendors | Numbers only, original implementation. Targets the 6.0 mm-gap variant — do not mix with 5.0 mm B-slot |

## Standing rules

- Where a source is non-commercial (e.g. CC BY-NC-SA, as with Gridfinity when it is added), this repo uses **only the published numbers, never the code**, and says so here.
- Trademarks receive nominative descriptive use only ("compatible with"), never implied endorsement, never third-party logos.
- Interfaces whose sources are unclear or restrictive (Multiboard, LEGO) are **skipped entirely**; OpenGrid is blocked pending a licence check.
