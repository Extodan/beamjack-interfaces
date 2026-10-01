# Model recall failures — specific, reproducible, checkable

Plain-prompt (no registry context), 5 samples per dimension, gemini-3.7-flash.
Every row: what the model said, how often, and the published value beside it. `unparsable` = matcher miss (model did not echo the dimension name) — not scored as an answer.

## action_cam_mount — recall 10%
- **two-prong fork gap between prongs (mm)** — said: `10`×3, `12`×1, `15`×1 · published: **12.2** (±0.3)

## pi_sbc — recall 33%
- **Pi 4B/5 mounting-hole spacing, short axis (mm)** — said: `58`×5 · published: **49** (±0.2) — never correct in 5 runs
- **Pi PCB width (mm)** — said: `56`×5 · published: **56.5** (±0.3) — never correct in 5 runs

## din_rail_ts35 — recall 50%
- **TS35 rail overall width (mm)** — said: `7.5`×5 · published: **35** (±0.2) — never correct in 5 runs

## nema_stepper — recall 67%
- **NEMA 17 pilot boss diameter (mm)** — said: `22`×5 · published: **22.73** (±0.15) — never correct in 5 runs

## tslot_2020 — recall 90%
- **2020 V-slot slot gap (mm)** — said: `6`×2, `6.2`×2, `5.3`×1 · published: **6** (±0.3)

---
*Method: gemini-3.7-flash, plain prompt, 5 samples per dimension, answers parsed after `=`.
Ranking stability: the extremes (action_cam ~0–17%, pi 33%, din 50%, and the 100% tier) held across
independent audit runs; the 67–90% band (nema/vesa/tslot) is stable to ±1 dimension and should not
be treated as finely ordered. `unparsable` rows are matcher misses, never scored. References are
audit-grade published values; where two values circulate, the alternative is carried in the script.*
