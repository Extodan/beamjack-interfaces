$fn = 64;
// gauge plate — bearing_iso15 v0.1.0
module plate() { difference() {
  cube([176, 140, 8]);
  translate([28, 28, -0.01]) cylinder(h = 8.02, d = 16.35);
  translate([28, 70, -0.01]) cylinder(h = 8.02, d = 16.15);
  translate([28, 112, -0.01]) cylinder(h = 8.02, d = 15.95);
  translate([70, 28, -0.01]) cylinder(h = 8.02, d = 22.35);
  translate([70, 70, -0.01]) cylinder(h = 8.02, d = 22.15);
  translate([70, 112, -0.01]) cylinder(h = 8.02, d = 21.95);
  translate([112, 28, -0.01]) cylinder(h = 8.02, d = 28.35);
  translate([112, 70, -0.01]) cylinder(h = 8.02, d = 28.15);
  translate([112, 112, -0.01]) cylinder(h = 8.02, d = 27.95);
  translate([154, 28, -0.01]) cylinder(h = 8.02, d = 32.35);
  translate([154, 70, -0.01]) cylinder(h = 8.02, d = 32.15);
  translate([154, 112, -0.01]) cylinder(h = 8.02, d = 31.95);
} }
module emboss() {
  translate([28, 43, 8]) linear_extrude(0.6) text("625 clr", size=3.5, halign="center", valign="center");
  translate([28, 85, 8]) linear_extrude(0.6) text("625 loc", size=3.5, halign="center", valign="center");
  translate([28, 127, 8]) linear_extrude(0.6) text("625 snug", size=3.5, halign="center", valign="center");
  translate([70, 43, 8]) linear_extrude(0.6) text("608 clr", size=3.5, halign="center", valign="center");
  translate([70, 85, 8]) linear_extrude(0.6) text("608 loc", size=3.5, halign="center", valign="center");
  translate([70, 127, 8]) linear_extrude(0.6) text("608 snug", size=3.5, halign="center", valign="center");
  translate([112, 43, 8]) linear_extrude(0.6) text("6001 clr", size=3.5, halign="center", valign="center");
  translate([112, 85, 8]) linear_extrude(0.6) text("6001 loc", size=3.5, halign="center", valign="center");
  translate([112, 127, 8]) linear_extrude(0.6) text("6001 snug", size=3.5, halign="center", valign="center");
  translate([154, 43, 8]) linear_extrude(0.6) text("6002 clr", size=3.5, halign="center", valign="center");
  translate([154, 85, 8]) linear_extrude(0.6) text("6002 loc", size=3.5, halign="center", valign="center");
  translate([154, 127, 8]) linear_extrude(0.6) text("6002 snug", size=3.5, halign="center", valign="center");
  translate([88, 3.5, 8]) linear_extrude(0.6) text("bearing_iso15 v0.1.0", size=3.5, halign="center", valign="center");
}
plate(); emboss();
