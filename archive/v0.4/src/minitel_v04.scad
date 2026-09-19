// v0.4 review prototype. Millimetres. Not a fit-certified production model.
// iodeo cassette: rigid rotation/translation ONLY; no scaling or rail edits.
// Donor attribution and limitations: ../V0.4-PROTOTYPE.md.
use <../../v0.2/minitel_esp32_case.scad>
part="body"; // body, cover, assembly, shell, interference
$fn=40;

module cassette() {
    translate([23.75,58,10]) rotate([0,0,180])
        import("../../../reference/iodeo-enclosure/box.stl",convexity=12);
}
module cover() {
    translate([23.75,58,10]) rotate([0,0,180])
        import("../../../reference/iodeo-enclosure/cover.stl",convexity=12);
}
module rear_access() {
    // Keep the entire original end face accessible, including its curved crown.
    translate([-26,55,-1]) cube([52,10,24]);
    // Cable lay-in slot joins the hatch: DIN plug need not pass through a hole.
    // Deliberately generous provisional slot; no cable clamping in this version.
    translate([23,55,10]) cube([8,10,13]);
}
module shell() {
    difference() {
        hull() {
            translate([0,0,0]) linear_extrude(height=1)
                offset(r=3) translate([-31,3]) square([62,54]);
            translate([0,0,58]) linear_extrude(height=2)
                offset(r=3) translate([-29,3]) square([58,50]);
        }
        // Flat floor at 3.6 touches ONLY bottom skin of donor (lowest z=3.4).
        translate([-29.5,2.4,3.6]) cube([59,53.2,54]);
        rear_access();
        // Short horizontal vents in rear half, clear of cassette.
        for(z=[33:3:48]) translate([28,39,z]) cube([8,10,1.2]);
    }
}
module facade() {
    difference() {
        union() {
            rounded_plate_xz(67.4,59.4,2,3.7);
            screen_bezel();
            top_ribs();
        }
        translate([0,-1.10,24]) rounded_plate_xz(51.8,29.2,1.05,3);
    }
}
module outer_body() {
    union() {
        shell();
        facade();
        keyboard_wedge();
        keyboard_keys();
        keyboard_front_lip();
    }
}
module body_v04() { union() { outer_body(); cassette(); } }
// Check swept removal space of the original cap against the completed body.
if(part=="shell_interference") intersection() {
    outer_body();
    union() { for(d=[0:1:20]) translate([0,d,0]) cover(); }
}
else if(part=="interference") intersection() {
    body_v04();
    union() { for(d=[0:1:20]) translate([0,d,0]) cover(); }
}
else if(part=="cover") cover();
else if(part=="shell") outer_body();
else if(part=="assembly") {
    body_v04(); cover(); screen(); accent();
}
else body_v04();
