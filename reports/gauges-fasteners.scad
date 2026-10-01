$fn = 48;
// gauge plate — iso_metric_fasteners v0.1.0
module plate() { difference() {
  cube([104, 64, 6]);
  translate([15, 15, -0.01]) cylinder(h = 6.02, d = 2.35);
  translate([15, 31, -0.01]) cylinder(h = 6.02, d = 2.15);
  translate([15, 47, -0.01]) cylinder(h = 6.02, d = 1.95);
  translate([31, 15, -0.01]) cylinder(h = 6.02, d = 2.85);
  translate([31, 31, -0.01]) cylinder(h = 6.02, d = 2.65);
  translate([31, 47, -0.01]) cylinder(h = 6.02, d = 2.45);
  translate([47, 15, -0.01]) cylinder(h = 6.02, d = 3.35);
  translate([47, 31, -0.01]) cylinder(h = 6.02, d = 3.15);
  translate([47, 47, -0.01]) cylinder(h = 6.02, d = 2.95);
  translate([63, 15, -0.01]) cylinder(h = 6.02, d = 4.35);
  translate([63, 31, -0.01]) cylinder(h = 6.02, d = 4.15);
  translate([63, 47, -0.01]) cylinder(h = 6.02, d = 3.95);
  translate([79, 15, -0.01]) cylinder(h = 6.02, d = 5.35);
  translate([79, 31, -0.01]) cylinder(h = 6.02, d = 5.15);
  translate([79, 47, -0.01]) cylinder(h = 6.02, d = 4.95);
  translate([95, 15, -0.01]) cylinder(h = 6.02, d = 6.35);
  translate([95, 31, -0.01]) cylinder(h = 6.02, d = 6.15);
  translate([95, 47, -0.01]) cylinder(h = 6.02, d = 5.95);
} }
module emboss() {
  translate([15, 20.4, 6]) linear_extrude(0.6) text("M2 clr", size=2.4, halign="center", valign="center");
  translate([15, 36.4, 6]) linear_extrude(0.6) text("M2 loc", size=2.4, halign="center", valign="center");
  translate([15, 52.4, 6]) linear_extrude(0.6) text("M2 snug", size=2.4, halign="center", valign="center");
  translate([31, 20.4, 6]) linear_extrude(0.6) text("M2.5 clr", size=2.4, halign="center", valign="center");
  translate([31, 36.4, 6]) linear_extrude(0.6) text("M2.5 loc", size=2.4, halign="center", valign="center");
  translate([31, 52.4, 6]) linear_extrude(0.6) text("M2.5 snug", size=2.4, halign="center", valign="center");
  translate([47, 20.4, 6]) linear_extrude(0.6) text("M3 clr", size=2.4, halign="center", valign="center");
  translate([47, 36.4, 6]) linear_extrude(0.6) text("M3 loc", size=2.4, halign="center", valign="center");
  translate([47, 52.4, 6]) linear_extrude(0.6) text("M3 snug", size=2.4, halign="center", valign="center");
  translate([63, 20.4, 6]) linear_extrude(0.6) text("M4 clr", size=2.4, halign="center", valign="center");
  translate([63, 36.4, 6]) linear_extrude(0.6) text("M4 loc", size=2.4, halign="center", valign="center");
  translate([63, 52.4, 6]) linear_extrude(0.6) text("M4 snug", size=2.4, halign="center", valign="center");
  translate([79, 20.4, 6]) linear_extrude(0.6) text("M5 clr", size=2.4, halign="center", valign="center");
  translate([79, 36.4, 6]) linear_extrude(0.6) text("M5 loc", size=2.4, halign="center", valign="center");
  translate([79, 52.4, 6]) linear_extrude(0.6) text("M5 snug", size=2.4, halign="center", valign="center");
  translate([95, 20.4, 6]) linear_extrude(0.6) text("M6 clr", size=2.4, halign="center", valign="center");
  translate([95, 36.4, 6]) linear_extrude(0.6) text("M6 loc", size=2.4, halign="center", valign="center");
  translate([95, 52.4, 6]) linear_extrude(0.6) text("M6 snug", size=2.4, halign="center", valign="center");
  translate([52, 3, 6]) linear_extrude(0.6) text("iso_metric_fasteners v0.1.0", size=3, halign="center", valign="center");
}
plate(); emboss();
