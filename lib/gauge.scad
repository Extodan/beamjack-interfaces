// ============================================================================
// lib/gauge.scad — fit-gauge plate generator
// ----------------------------------------------------------------------------
// One small printable plate carrying a mating feature in ALL THREE fit
// classes side by side, labelled, with the interface id and definition
// version embossed. Printing these and recording which class actually fits
// is how the tolerance table in fits.scad stops being a hypothesis.
//
// The per-interface gauge.scad files call gauge_plate(); verify.mjs also
// emits a combined plate for every interface at once.

use <fits.scad>;

// text label size scales with feature size so small gauges stay readable
module _gauge_label(txt, size) {
    color("lime")
        linear_extrude(0.6)
            text(txt, size = size, halign = "center", valign = "center",
                 font = "Liberation Sans:style=Bold");
}

// One cell: the feature (a module ref passed by name is not possible in
// OpenSCAD, so cells receive pre-built children) + class label embossed.
module _gauge_cell(width, cls, label_size) {
    translate([0, 0, 0]) children();
    translate([0, width * 0.32, 0.3]) _gauge_label(cls, label_size);
}

// Plate layout: n cells in a row, each width wide, embossed header.
module gauge_plate(id, version, cells, cell_w = 14, pitch = 18, t = 6) {
    n = len(cells);
    total_w = n * pitch + 6;
    difference() {
        cube([total_w, cell_w + 8, t]);
        // cells are placed by the caller as children of this plate — kept
        // simple: the plate is a plain slab; features subtract/union outside
    }
    translate([total_w / 2, cell_w + 5.5, t + 0.3])
        _gauge_label(str(id, " v", version), 3.2);
}
