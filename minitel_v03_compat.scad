/* v0.3 compatibility upgrade for an already printed v0.2 body. */

use <archive/v0.2/minitel_esp32_case.scad>

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

module carrier_frame_v03() {
    board_left = pcb_shift_x - pcb_w/2;
    board_right = pcb_shift_x + pcb_w/2;
    board_top = pcb_bottom_z + pcb_h;
    back_y0 = 12.55;
    back_y1 = 14.15;
    board_back_y = 11.95;
    board_front_y = board_back_y - 1.60;

    union() {
        for (p = legacy_posts)
            y_ring(p[0], p[1], 12.0, 14.75, 4.4, 1.35);

        // Open skeleton leaves the PCB component area unobstructed.
        xz_bar(-18.8, 13.0, 49.9, 53.3, back_y0, back_y1);
        xz_bar(-16.5, 13.0, 6.0, 11.9, back_y0, back_y1);
        xz_bar(-16.5, -12.7, 9.5, 51.3, back_y0, back_y1);
        xz_bar(8.0, 12.0, 10.0, 51.8, back_y0, back_y1);

        // Shifted edge cradle. The right edge stays open at USB-C and RESET.
        xz_bar(board_left-1.8, board_left-0.45,
               pcb_bottom_z-0.2, board_top+0.2,
               board_back_y-0.1, back_y1);
        xz_bar(board_left-1.8, board_right+1.5,
               pcb_bottom_z-1.8, pcb_bottom_z-0.2,
               board_back_y-0.1, back_y1);
        xz_bar(board_right+0.45, board_right+1.8,
               13.0, 20.0, board_back_y-0.1, back_y1);
        xz_bar(board_right+0.45, board_right+1.8,
               25.0, 32.0, board_back_y-0.1, back_y1);
        // Bridges tie the two right-hand stops back into the legacy skeleton.
        xz_bar(7.8, board_right+1.0, 13.0, 15.2, back_y0, back_y1);
        xz_bar(7.8, board_right+1.0, 28.0, 30.2, back_y0, back_y1);

        // Small front lips capture only the board edges.
        for (z = [12.5, 31.5, 47.5])
            xz_bar(board_left-1.8, board_left+1.4, z, z+3.0,
                   board_front_y-0.45, board_front_y+0.30);
        xz_bar(board_right-1.4, board_right+1.8, 25.0, 29.0,
               board_front_y-0.45, board_front_y+0.30);
        // Connections run outside the PCB edge, leaving the board-thickness
        // slot open while making every retaining lip part of one print.
        for (z = [12.5, 31.5, 47.5])
            xz_bar(board_left-1.8, board_left-0.45, z, z+3.0,
                   board_front_y-0.45, board_back_y+0.15);
        xz_bar(board_right+0.45, board_right+1.8, 25.0, 29.0,
               board_front_y-0.45, board_back_y+0.15);

        // Compliant top latch with a modest 0.35 mm PLA overlap.
        xz_bar(board_left+9.0, board_left+15.0,
               board_top-0.1, board_top+3.5,
               board_back_y-0.1, back_y1);
        xz_bar(board_left+9.0, board_left+15.0,
               board_top-0.35, board_top+0.55,
               board_front_y-0.55, board_back_y+0.1);
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
        translate([pcb_shift_x-pcb_w/2, 10.35, pcb_bottom_z])
            cube([pcb_w, 1.60, pcb_h]);
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
