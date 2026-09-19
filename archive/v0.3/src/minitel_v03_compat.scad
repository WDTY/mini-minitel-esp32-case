/* v0.3 compatibility upgrade for an already printed v0.2 body. */

use <../../v0.2/minitel_esp32_case.scad>
include <../../../src/pcb_reference.scad>

part = "assembly"; // [carrier, lid, keyboard, reset, assembly]
$fn = 48;

body_w = 68;
body_h = 60;
wall = 2.4;
lip_clearance = 0.35;

// The carrier receives these existing posts; the PCB no longer does.
legacy_posts = [
    [-16.61, 51.51], [2.79, 51.71],
    [-14.39, 7.60], [9.71, 10.70]
];

pcb_w = 36.22;
pcb_h = 47.10;
pcb_shift_x = 10.0;
pcb_bottom_z = 6.0;
pcb_back_y = 10.40;
pcb_front_y = pcb_back_y - 1.60;

module xz_bar(x0, x1, z0, z1, y0, y1) {
    translate([x0, y0, z0]) cube([x1-x0, y1-y0, z1-z0]);
}

module y_ring(x, z, y0, y1, od, id) {
    difference() {
        translate([x, y1, z]) rotate([90, 0, 0]) cylinder(h=y1-y0, d=od);
        translate([x, y1+0.1, z]) rotate([90, 0, 0])
            cylinder(h=y1-y0+0.2, d=id);
    }
}

module pcb_carrier_rail_2d() {
    // A narrow rail follows the real routed outline and its large internal
    // cut-outs.  It is deliberately set behind the component clearance zone.
    difference() {
        offset(delta=1.35) pcb_reference_outline_2d();
        offset(delta=-1.85) pcb_reference_outline_2d();
    }
}

module pcb_carrier_rail(y0=13.80, y1=14.65) {
    translate([pcb_shift_x, y1, pcb_bottom_z])
        rotate([90, 0, 0])
            linear_extrude(height=y1-y0)
                pcb_carrier_rail_2d();
}

module pcb_mount_boss(p, back_y=14.65) {
    x = pcb_shift_x + p[0];
    z = pcb_bottom_z + p[1];

    // The broad face stops exactly at the PCB back.  A 0.82 mm tapered nub
    // enters the nominal 1.143 mm drill hole without acting as a force fit.
    y_cylinder(x, z, pcb_back_y, back_y, 3.35);
    y_cylinder(x, z, pcb_back_y-0.34, pcb_back_y+0.18, 0.82);
    translate([x, pcb_back_y-0.34, z])
        rotate([-90, 0, 0]) cylinder(h=0.34, d1=0.52, d2=0.82);
}

module yz_clip_prism(x0, x1, points) {
    // Extrude a y/z profile in x.  The 45-degree-ish approach face prints
    // while the contour frame is lying on its broad rear face.
    translate([x0, 0, 0])
        rotate([90, 0, 90])
            linear_extrude(height=x1-x0)
                polygon(points);
}

module pcb_edge_clips() {
    clip_x0 = pcb_shift_x - 2.0;
    clip_x1 = pcb_shift_x + 2.0;

    // Narrow tongues sit 0.9 mm behind the PCB.  Their hooks move outward
    // as the board is pressed straight onto the five locating nubs.
    xz_bar(clip_x0, clip_x1, 48.2, 53.55, 11.25, 12.25);
    xz_bar(clip_x0, clip_x1, 48.2, 53.55, 13.80, 14.65);
    xz_bar(clip_x0, clip_x1, 48.2, 49.25, 11.30, 14.65);
    yz_clip_prism(clip_x0, clip_x1,
        [[12.20,52.55], [12.20,54.25], [8.45,54.25],
         [8.45,52.80], [9.15,52.80], [11.30,53.16]]);

    xz_bar(clip_x0, clip_x1, 5.55, 10.9, 11.25, 12.25);
    xz_bar(clip_x0, clip_x1, 9.85, 10.9, 11.30, 14.65);
    yz_clip_prism(clip_x0, clip_x1,
        [[12.20,6.55], [12.20,4.85], [8.45,4.85],
         [8.45,6.30], [9.15,6.30], [11.30,5.94]]);
}

module carrier_frame_v03() {
    difference() {
        union() {
            for (p = legacy_posts)
                y_ring(p[0], p[1], 12.0, 14.65, 4.4, 1.35);

            pcb_carrier_rail();
            for (p = pcb_reference_holes) pcb_mount_boss(p);
            pcb_edge_clips();

            // Three shallow bridges connect the contour rail to the legacy
            // sockets. They stay at the rear plane rather than crossing the
            // PCB component volume near its face.
            xz_bar(-18.8, 8.0, 50.15, 52.85, 13.80, 14.65);
            xz_bar(-16.8, -14.2, 8.0, 52.4, 13.80, 14.65);
            xz_bar(-16.0, 8.0, 6.25, 9.55, 13.80, 14.65);
        }

        // Re-cut every socket after unioning the bridges; otherwise a bridge
        // crossing a ring silently fills the hole needed by the v0.2 pin.
        for (p = legacy_posts)
            y_cylinder(p[0], p[1], 11.80, 15.05, 1.35);
    }
}

module inset_lip() {
    lip_w = body_w - 2*wall - 2*lip_clearance;
    lip_h = body_h - 2*wall - 2*lip_clearance;
    translate([0, 3.8, 0])
        difference() {
            rounded_plate_xz(lip_w, lip_h, 4.0, 2.7);
            translate([0, 0.25, 0])
                rounded_plate_xz(lip_w-4.0, lip_h-4.0, 4.5, 1.5);
        }

    for (x = [-1, 1], z = [18, 47])
        translate([x*(lip_w/2-0.15)-0.35, 1.35, z-2.2])
            cube([0.7, 1.8, 4.4]);
}

module keyboard_receiver_holes() {
    for (x = [-21.5, 21.5])
        translate([x-2.8, -3.0, 5.0]) cube([5.6, 8.0, 5.0]);
}

module lid_v03() {
    difference() {
        union() {
            rounded_plate_xz(body_w-0.6, body_h-0.6, 2.0, 3.7);
            screen_bezel();
            top_ribs();
            inset_lip();
        }
        translate([0, -1.10, 24.0])
            rounded_plate_xz(51.8, 29.2, 1.05, 3.0);
        keyboard_receiver_holes();
    }
}

module keyboard_tabs() {
    for (x = [-21.5, 21.5]) {
        translate([x-2.5, -2.2, 5.3]) cube([5.0, 6.0, 4.4]);
        translate([x-2.7, 2.7, 5.6]) cube([5.4, 0.65, 3.8]);
    }
}

module keyboard_v03() {
    union() {
        keyboard_wedge();
        keyboard_keys();
        keyboard_front_lip();
        keyboard_tabs();
    }
}

reset_shaft_d = 2.20;
reset_cap_d = 4.80;
reset_wall_span = 4.60;
reset_inner_collar_d = 3.35;

module reset_plunger_v03() {
    union() {
        cylinder(h=1.0, d=reset_cap_d);
        translate([0, 0, 0.85]) cylinder(h=reset_wall_span, d=reset_shaft_d);
        translate([0, 0, reset_wall_span+0.60])
            cylinder(h=0.50, d1=reset_inner_collar_d, d2=reset_shaft_d);
        translate([0, 0, reset_wall_span+1.05])
            cylinder(h=0.80, d1=reset_shaft_d, d2=1.30);
    }
}

module pcb_envelope() {
    color("#101714")
        pcb_reference(pcb_shift_x, pcb_back_y, pcb_bottom_z);
}

module assembly_v03() {
    color("#d6c3a1") body();
    color("#d8c7a7") lid_v03();
    color("#dfcba8") keyboard_v03();
    color("#c97935") carrier_frame_v03();
    pcb_envelope();
    color("#42c98a")
        translate([34.8, 11.7, 50.3]) rotate([0, -90, 0]) reset_plunger_v03();
}

if (part == "carrier") carrier_frame_v03();
else if (part == "lid") lid_v03();
else if (part == "keyboard") keyboard_v03();
else if (part == "reset") reset_plunger_v03();
else assembly_v03();
