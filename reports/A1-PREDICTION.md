# A1 — first part generated with registry context: print beside the gauges

`A1-registry-context-part.stl`. Job 53422c40, prompt "a camera mount that
clamps to 2020 extrusion with M5 bolts", datum-form injection (nominals
supplied, no call instruction). The generated scad contains ZERO asm_peg/
asm_socket calls — every registry nominal appears as a bare literal.

**Prediction (written before printing, from the fits table):**
- the Ø4.2 mm-equivalent bore prints ~3.9–4.0 and will NOT pass an M4 bolt (uncompensated:
  clearance class would have made it 4.55 via asm_socket)
- the 6.0 slot gap prints tight against real 2020 V-slot
- the fastener gauge plate from the same job prints Ø4.35 in its clearance
  class — that cell takes the M4, this part won't. Same machine, same job:
  the gauge quantifies exactly how much the bare literal came in under.

This object is the argument for call-form injection in one print.
