/*
  Mini Minitel enclosure for the iodeo ESP Minitel V2 JST/cable board.

  v0.2 work-in-progress: proportions rebuilt from the approximately
  250 x 220 x 260 mm real Minitel envelope and the owner's photographs.

  Board geometry is based on the official v2.2 Gerber outline and mounting
  holes, checked against photographs of the actual board.

  Select one of: "body", "front", "screen", "accent", "assembly".
  License: CC BY-SA 4.0. See README.md and LICENSE.txt.
*/

part = "assembly"; // [body, front, screen, accent, assembly]
$fn = 48;

// Printer-fit parameters. Increase fit_clearance in 0.10 mm steps if needed.
fit_clearance = 0.25;
wall = 2.4;

// Main enclosure dimensions.
body_w = 68;
body_d = 58;
body_h = 60;
corner_r = 4.0;

// Official Gerber board extents, rotated so the JST lead points down.
pcb_w = 36.22;
pcb_h = 47.10;
pcb_t = 1.60;
pcb_bottom_z = 6.0;
pcb_plane_y = 14.0;

// Side controls, measured from the PCB photographs and deliberately exposed
// as fit-test parameters. Coordinates are in enclosure space after rotating
// the PCB so the JST lead points down.
usb_c_y = 11.7;
usb_c_z = 42.5;
usb_c_depth = 9.0;
usb_c_height = 11.5;
reset_y = 11.7;
reset_z = 50.3;
reset_access_d = 3.2;

// Non-plated mounting holes from the v2.2 drill file, after rotation and
// normalization. Coordinates are [x from PCB center, z from PCB bottom].
pcb_holes = [
    [-16.61, 45.51],
    [  2.79, 45.71],
    [-14.39,  1.60],
    [  9.71,  4.70],
    [  9.71, 23.10]
];

// Four holes give stable support; the fifth remains unobstructed.
mount_holes = [0, 1, 2, 3];

module rounded_box(w, d, h, r) {
    translate([-w/2 + r, r, r])
        minkowski() {
            cube([w - 2*r, d - 2*r, h - 2*r]);
            sphere(r=r);
        }
}

module rounded_plate_xz(w, h, d, r) {
    // Front surface at y=-d, back surface at y=0.
    translate([0, 0, h/2])
        rotate([90, 0, 0])
            linear_extrude(height=d)
                offset(r=r)
                    square([w - 2*r, h - 2*r], center=true);
}

module y_cylinder(x, z, y_front, y_back, diameter) {
    translate([x, y_back, z])
        rotate([90, 0, 0])
            cylinder(h=y_back-y_front, d=diameter);
}

module x_cylinder(y, z, x_left, x_right, diameter) {
    translate([x_left, y, z])
        rotate([0, 90, 0])
            cylinder(h=x_right-x_left, d=diameter);
}

module side_service_openings() {
    // USB-C: enough room for the metal receptacle plus a normal moulded plug.
    // This is intentionally rectangular for support-free printing on the rear.
    translate([body_w/2 - wall - 0.5,
               usb_c_y - usb_c_depth/2,
               usb_c_z - usb_c_height/2])
        cube([wall + 2, usb_c_depth, usb_c_height]);

    // RESET: a narrow guided access hole for a paperclip or 2 mm pin. The
    // button remains protected from accidental presses.
    x_cylinder(reset_y, reset_z,
               body_w/2 - wall - 0.5,
               body_w/2 + 1.5,
               reset_access_d);
}

module side_vents() {
    // Rearward horizontal slots echo the original Minitel cabinet while
    // staying clear of USB-C and RESET nearer the front of the right wall.
    for (z = [34.0:3.0:49.0])
        translate([body_w/2 - wall - 0.5, 43.0, z])
            cube([wall + 2, 9.0, 1.25]);
}

module front_fixing_holes() {
    for (x = [-29, 29], z = [17, 49])
        y_cylinder(x, z, -0.3, 7.0, 3.0 + 2*fit_clearance);
}

module board_mounts() {
    inner_back_y = body_d - wall;
    pcb_back_y = pcb_plane_y + pcb_t/2;

    for (i = mount_holes) {
        p = pcb_holes[i];
        x = p[0];
        z = pcb_bottom_z + p[1];

        // Broad support from the rear wall up to the back of the PCB.
        y_cylinder(x, z, pcb_back_y, inner_back_y + 0.1, 4.2);

        // 0.90 mm locating pin for the nominal 1.143 mm PCB hole.
        y_cylinder(x, z, pcb_plane_y - 1.7, pcb_back_y + 0.15, 0.90);
    }
}

module body() {
    union() {
        difference() {
            rounded_box(body_w, body_d, body_h, corner_r);

            // Front-open cavity. The retained rim is the mounting face.
            translate([-body_w/2 + wall, -1, wall])
                cube([body_w - 2*wall,
                      body_d - wall + 1,
                      body_h - 2*wall]);

            // Separate right-side access for USB-C and the protected RESET.
            side_service_openings();

            side_vents();

            // Bottom cable exit for the JST lead; open to the front for assembly.
            translate([-14.0, -1.0, -1.0])
                cube([12.0, body_d + 2.0, 9.0]);

            front_fixing_holes();
        }

        // Add these after hollowing so they remain inside the cavity.
        board_mounts();

        // Small feet keep the cable exit from being pinched on a desk.
        for (x = [-27, 27])
            translate([x-3, 18, -1.2]) cube([6, 20, 1.4]);
    }
}

module keyboard_wedge() {
    // The real Minitel keyboard projects far forward when opened. Keeping
    // this depth near 56% of the body width fixes v0.1's arcade-cabinet look.
    polyhedron(
        points=[
            [-33,-2, 3], [33,-2, 3], [32,-40,3], [-32,-40,3],
            [-33,-2,17], [33,-2,17], [32,-40,6.5], [-32,-40,6.5]
        ],
        faces=[
            [0,1,2,3], [4,7,6,5], [0,4,5,1],
            [1,5,6,2], [2,6,7,3], [3,7,4,0]
        ]
    );
}

function keyboard_z(y) = 6.5 + (y + 40) * (10.5/38);

module keycap(x, y, w=3.6, d=2.2) {
    key_angle = atan(10.5/38);
    translate([x, y, keyboard_z(y)])
        rotate([key_angle, 0, 0])
            translate([-w/2, -d/2, -0.20])
                cube([w, d, 1.15]);
}

module keyboard_keys() {
    // Five well-separated rows fill the opened deck like the real keyboard.
    for (row = [0:4]) {
        y = -34.0 + row*5.7;
        count = row == 0 ? 12 : (row == 1 ? 11 : 10);
        spacing = 4.75;
        shift = row*0.42;
        for (col = [0:count-1]) {
            x = (col-(count-1)/2)*spacing + shift;
            // Leave one position open for the separately coloured Enter key.
            if (!(row == 3 && col == 7)) keycap(x, y, 4.0, 3.0);
        }
    }
    keycap(0, -36.8, 18, 3.0);
}

module keyboard_front_lip() {
    // The rolled front edge gives the open keyboard the toy-like silhouette
    // used by the project avatar and the full-size reference Minitel.
    translate([-32, -41.4, 3.0]) cube([64, 1.8, 2.5]);
}

module screen_bezel() {
    // Raised rounded CRT surround around the removable screen insert.
    difference() {
        translate([0, -1.90, 20.8])
            rounded_plate_xz(58.0, 35.0, 0.85, 4.0);
        translate([0, -1.80, 23.4])
            rounded_plate_xz(53.2, 30.4, 1.9, 3.2);
    }
}

module top_ribs() {
    // Three fine horizontal cabinet ribs from the photographed Minitel.
    for (z = [55.0, 56.10, 57.20])
        translate([-27.5, -2.42, z]) cube([55.0, 0.50, 0.45]);
}

module front_retainer_posts() {
    // These stop the PCB lifting off its locating pins. A 0.35 mm nominal
    // gap avoids squeezing the board when the front is fitted.
    target_y = pcb_plane_y - pcb_t/2 - 0.35;
    for (i = mount_holes) {
        p = pcb_holes[i];
        x = p[0];
        z = pcb_bottom_z + p[1];
        y_cylinder(x, z, 0, target_y, 3.4);
    }
}

module front_fixing_pins() {
    for (x = [-29, 29], z = [17, 49])
        y_cylinder(x, z, 0, 6.4, 2.90);
}

module minitel_label() {
    translate([-13.5, -1.95, 20.1])
        rotate([90, 0, 0])
            linear_extrude(height=0.65)
                text("MINITEL", size=4.3,
                     font="Liberation Sans:style=Bold",
                     halign="left", valign="bottom");
}

module front() {
    difference() {
        union() {
            rounded_plate_xz(body_w-0.6, body_h-0.6, 2.0, corner_r-0.3);
            screen_bezel();
            top_ribs();
            keyboard_wedge();
            keyboard_keys();
            keyboard_front_lip();
            front_fixing_pins();
            front_retainer_posts();
        }

        // Rounded 0.9 mm-deep seat for the separately printable CRT insert.
        translate([0, -1.10, 24.0])
            rounded_plate_xz(51.8, 29.2, 1.05, 3.0);

        // Continue the JST cable notch through the front rim/deck rear.
        translate([-14.0, -2.5, -1.0])
            cube([12.0, 5.0, 9.0]);
    }
}

module screen() {
    difference() {
        translate([0, -1.42, 24.3])
            rounded_plate_xz(51.2, 28.6, 0.82, 2.85);

        // Subtle horizontal scan-line grooves.
        for (z = [27.2:3.2:49.6])
            translate([-22.5, -2.30, z])
                cube([45.0, 0.18, 0.28]);
    }

    // Small terminal prompt matching the avatar, readable at thumbnail scale.
    translate([-17.0, -2.18, 36.0])
        rotate([90, 0, 0])
            linear_extrude(height=0.45)
                text(">", size=6.2,
                     font="Liberation Mono:style=Bold",
                     halign="left", valign="bottom");
}

module accent() {
    // Green Enter key in the deliberately omitted keyboard position.
    key_angle = atan(10.5/38);
    translate([13.135, -16.9, keyboard_z(-16.9)])
        rotate([key_angle, 0, 0])
            translate([-2.0, -1.5, 0])
                cube([4.0, 3.0, 0.95]);

    // Tiny status lens to the right of the CRT surround.
    translate([31.0, -2.0, 27.5])
        rounded_plate_xz(1.8, 3.5, 0.65, 0.42);
}

module assembly() {
    color("#d6c3a1") body();
    color("#e1cfad") front();
    color("#213b38") screen();
    color("#42c98a") accent();
}

if (part == "body") body();
else if (part == "front") front();
else if (part == "screen") screen();
else if (part == "accent") accent();
else assembly();
