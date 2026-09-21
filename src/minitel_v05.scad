/*
  Mini Minitel ESP32 case v0.5

  Complete avatar-inspired Minitel enclosure plus one removable rear bay for
  the populated iodeo ESP Minitel V2 JST board. The iodeo enclosure geometry
  is deliberately not used. Units: mm.

  Creality K2 baseline: 0.4 mm nozzle, 0.20 mm layers, PLA.
  Select: case, case_assembly, keyboard, bay, assembly, pcb, cable,
          keyboard_case_interference, case_bay_interference,
          pcb_insertion_interference, bay_route_interference.
*/

include <pcb_reference.scad>

part = "assembly";
sweep_offset = 0;
$fn = 40;

// ----- Printer and measured hardware -----
layer_h = 0.20;
wall = 2.40;
sliding_clearance = 0.40;       // each side, K2/PLA baseline
pcb_length = 47.10521;
pcb_depth = 36.21792;
pcb_thickness = 1.60;
populated_height = 10.40;
pcb_slot_h = 2.20;              // 0.30 mm above/below nominal PCB
pcb_side_clearance = 0.35;
edge_capture = 1.00;
cable_d = 4.30;                 // measured black DIN lead
din_plug_d = 15.50;             // measured; plug remains outside the bay
reset_protrusion = 1.50;        // measured beyond the PCB rear edge

watermark_text = "WDTY v0.5";
watermark_z = 0.60;
watermark_h = 0.60;             // three 0.20 mm layers

// ----- Complete miniature Minitel envelope -----
case_w = 78.0;
case_d = 72.0;
case_h = 74.0;
case_corner = 5.0;
case_top_inset = 2.0;

// The keyboard is a separate, flat-bottomed multicolour print. Four rigid
// tongues locate it in clearance pockets in the lower front of the cabinet.
// The 0.30 mm per-face clearance is deliberately conservative for K2/PLA.
keyboard_seam_y = -2.20;
keyboard_tab_w = 7.0;
keyboard_tab_d = 7.0;
keyboard_tab_h = 3.0;
keyboard_tab_clearance = 0.30;
keyboard_tab_x = [-23.0,23.0];
keyboard_tab_z = [5.0,13.0];

// Bay is assembled outside the case and inserted from the lower rear.
bay_w = 65.2;
bay_d = 66.0;
bay_floor_h = 1.80;
bay_body_h = 17.2;
bay_flange_w = 70.0;
bay_flange_h = 21.0;
bay_flange_t = 2.0;
bay_flange_recess_d = 2.25;
bay_stop_clearance = 0.15;
bay_installed_y = case_d - bay_d - bay_flange_recess_d
                  + bay_flange_t + bay_stop_clearance;
bay_installed_z = 2.20;
bay_opening_w = bay_w + 2*sliding_clearance;
bay_opening_h = bay_body_h + 0.80;

// Board orientation inside the bay: JST points toward the front/loop and the
// USB-C/RESET edge finishes at the rear service face.
pcb_rear_y = 60.0;
usb_outer_y = 64.0;
// Owner measured 60 mm from protruding USB-C to the outside of the relaxed
// cable bend, not to its centreline.
loop_depth = 60.0;
loop_front_y = usb_outer_y - loop_depth + cable_d/2;
pcb_z = 4.70;
slot_bottom_z = pcb_z - (pcb_slot_h-pcb_thickness)/2;
slot_top_z = slot_bottom_z + pcb_slot_h;
board_edge_x = pcb_length/2;
slot_wall_x = board_edge_x + pcb_side_clearance;
lip_inner_x = board_edge_x - edge_capture;
rail_outer_x = 28.70;
rail_front_y = 37.40;
rail_rear_y = 61.20;
rail_mouth_y = 32.60;
rail_top_z = 8.00;
cable_z = rail_top_z + cable_d/2 + 0.35;

// Approximate component positions only constrain insertion and service access.
usb_x0 = -15.5;
usb_x1 = -7.0;
// The physical v2 board sits lower than the first component mock suggested.
// Keep the proven horizontal alignment, but make the service opening a
// bottom-open notch so the USB-C shell and moulded plug can never disappear
// behind a printed lower lip.
usb_access_z1 = 11.8;
reset_x = -20.9;
reset_z = pcb_z + pcb_thickness + 1.15;

// Accessible floor cantilever that clicks behind the narrow JST-side nose.
pcb_latch_x = 15.1;
pcb_latch_tip_y = 23.20;
pcb_latch_w = 3.0;
pcb_latch_t = 0.80;
pcb_latch_hook_z = pcb_z + 0.35;

module rounded_rect_2d(w,h,r) {
    offset(r=r) square([w-2*r,h-2*r],center=true);
}

module rounded_xy(w,d,h,r) {
    linear_extrude(height=h) rounded_rect_2d(w,d,r);
}

module rounded_xz(w,h,d,r) {
    translate([0,0,h/2]) rotate([90,0,0])
        linear_extrude(height=d) rounded_rect_2d(w,h,r);
}

module cabinet_outer() {
    // Gentle taper and deep CRT cabinet, matching the project avatar.
    hull() {
        translate([0,case_d/2,0]) rounded_xy(case_w,case_d,2.0,case_corner);
        translate([0,case_d/2,case_h-2.0])
            rounded_xy(case_w-2*case_top_inset,
                       case_d-2*case_top_inset,2.0,case_corner-0.8);
    }
}

module cabinet_inner() {
    // True hollow envelope. The slightly thinner 2.0 mm lower skin gives the
    // installed bay 0.20 mm floor clearance; all other walls remain 2.4 mm.
    hull() {
        translate([0,case_d/2,2.0])
            rounded_xy(case_w-2*wall,case_d-2*wall,2.0,
                       case_corner-wall/2);
        translate([0,case_d/2,case_h-wall-2.0])
            rounded_xy(case_w-2*case_top_inset-2*wall,
                       case_d-2*case_top_inset-2*wall,2.0,
                       case_corner-1.0-wall/2);
    }
}

module keyboard_wedge() {
    // Open-Minitel proportions: almost as wide as the cabinet and visibly
    // deeper than the screen body, as in the avatar.
    polyhedron(
        points=[
            [-38, 3,0], [38, 3,0], [37,-49,0], [-37,-49,0],
            [-38, 3,20], [38, 3,20], [37,-49,7.2], [-37,-49,7.2]
        ],
        faces=[
            [0,3,2,1], [4,5,6,7], [0,1,5,4],
            [1,2,6,5], [2,3,7,6], [3,0,4,7]
        ]
    );
}

function key_z(y) = 7.2 + (y+49)*(12.8/52);
key_angle = atan(12.8/52);

module keycap(x,y,w=4.2,d=3.5,h=1.0) {
    translate([x,y,key_z(y)]) rotate([key_angle,0,0])
        translate([-w/2,-d/2,-0.15])
            linear_extrude(height=h) offset(r=0.55)
                square([w-1.1,d-1.1],center=true);
}

module keyboard_keys_grey() {
    // Avatar-style dense keyboard. Raised top faces are easy to paint by
    // surface in Creality Print/Orca while remaining one case STL.
    for (row=[0:4]) {
        y = -41.0 + row*7.2;
        count = row==0 ? 12 : (row==1 ? 11 : (row==2 ? 11 : 10));
        spacing = 5.45;
        shift = row==1 ? 1.5 : (row==3 ? -1.2 : 0);
        for (col=[0:count-1]) {
            x=(col-(count-1)/2)*spacing+shift;
            if (!(row==3 && col==7)) keycap(x,y);
        }
    }
    // Function row and space bar.
    for (x=[-27:9:27]) keycap(x,-9.0,7.0,4.0,1.05);
    keycap(-7.5,-45.3,24.0,3.8,1.0);
}

module keyboard_enter_key() {
    // Green enter key position, still part of the same paintable STL.
    keycap(15.15,-19.4,6.5,4.1,1.15);
}

module keyboard_keys() {
    keyboard_keys_grey();
    keyboard_enter_key();
}

module keyboard_front_lip() {
    translate([0,-48.9,0]) rounded_xz(76.0,7.2,2.2,2.0);
}

module keyboard_tabs() {
    for(x=keyboard_tab_x,z=keyboard_tab_z)
        // Start inside the rear face of the wedge so every tongue has a
        // positive-volume connection instead of only sharing a coplanar face.
        translate([x-keyboard_tab_w/2,keyboard_seam_y-0.8,z])
            cube([keyboard_tab_w,keyboard_tab_d,keyboard_tab_h]);
}

module keyboard_receiver_holes() {
    for(x=keyboard_tab_x,z=keyboard_tab_z)
        translate([x-keyboard_tab_w/2-keyboard_tab_clearance,
                   keyboard_seam_y-1.0,
                   z-keyboard_tab_clearance])
            cube([keyboard_tab_w+2*keyboard_tab_clearance,
                  keyboard_tab_d+1.4,
                  keyboard_tab_h+2*keyboard_tab_clearance]);
}

module hidden_keyboard_watermark() {
    // Enclosed inside the keyboard's solid front lip: three 0.20 mm layers.
    translate([0,-46.5,watermark_z]) linear_extrude(height=watermark_h)
        text(watermark_text,size=4.1,font="DejaVu Sans:style=Bold",
             halign="center",valign="center",spacing=1.05);
}

module keyboard_v05() {
    difference() {
        union() {
            // Remove the former 2.2 mm overlap with the front fascia. The
            // resulting visible seam is only the intentional assembly seam.
            intersection() {
                union() {
                    keyboard_wedge();
                    keyboard_keys();
                    keyboard_front_lip();
                }
                translate([-50,-60,-1])
                    cube([100,60+keyboard_seam_y,32]);
            }
            keyboard_tabs();
        }
        hidden_keyboard_watermark();
    }
}

module front_features() {
    // The front fascia extends 3.2 mm into the rounded cabinet. This is a
    // structural overlap, not a coplanar touch, and closes the former visible
    // slit between the CRT/front stack and the cabinet body.
    translate([0,3.2,0])
        rounded_xz(case_w-0.8,case_h-0.8,5.2,case_corner-0.4);

    // Convex CRT glass. Six nested profiles approximate the shallow compound
    // curve visible in the project avatar: the edge stays recessed while the
    // centre comes forward, but remains behind the beige bezel face.
    crt_screen_bulb();

    // The inner bezel is funnel-shaped rather than a flat punched ring. The
    // aperture is tight at the recessed screen edge and opens toward the
    // viewer, producing the characteristic inward-running Minitel surround.
    difference() {
        // Only a narrow flat rim remains at the front. Most of the visible
        // surround is the clean tapered return found in the avatar close-up.
        translate([0,-1.80,23.0]) let($fn=64)
            rounded_xz(69.0,46.0,2.38,4.8);
        hull() {
            translate([0,-1.35,26.55]) let($fn=64)
                rounded_xz(62.4,38.9,0.20,4.45);
            translate([0,-4.24,24.25]) let($fn=64)
                rounded_xz(67.0,43.5,0.30,4.75);
        }
    }

    // Three shallow horizontal cabinet ribs above the CRT.
    for(z=[69.0,70.1,71.2])
        translate([-33.0,-2.05,z]) cube([66.0,0.55,0.42]);

    // Green prompt and block cursor, embossed for multicolour face painting.
    translate([-22.0,-3.45,51.0]) rotate([90,0,0])
        linear_extrude(height=0.55)
            text(">",size=7.0,font="Liberation Mono:style=Bold",
                 halign="left",valign="center");
    translate([-13.1,-3.45,48.1]) rotate([90,0,0])
        linear_extrude(height=0.55) square([4.0,6.2]);

    // Status lens on the right side of the bezel.
    translate([36.0,-3.45,29.0]) rounded_xz(2.6,5.0,0.60,0.65);
}

// Render-only coloured surface skins. They overlap the printable one-piece
// case by 0.08 mm and are never exported as additional print parts.
module crt_profile(inset_x,inset_z,y) {
    translate([0,y,26.25+inset_z])
        rounded_xz(63.0-2*inset_x,39.5-2*inset_z,0.16,
                   max(1.6,5.0-inset_z*0.20));
}

module crt_screen_bulb(y_shift=0) {
    // Separate horizontal/vertical insets let the last profile become a small
    // central patch rather than a broad flat plate. The non-linear Y spacing
    // produces a progressively flatter tangent toward the crown.
    insets_x=[0.0,0.5,1.8,4.0,8.0,14.0,25.0];
    insets_z=[0.0,0.4,1.3,3.0,6.0,11.0,17.0];
    faces=[-1.68,-2.30,-2.88,-3.30,-3.60,-3.78,-3.85];

    translate([0,y_shift,0]) union() {
        // Positive overlap with the structural fascia at the outer edge.
        translate([0,-1.45,26.25]) rounded_xz(63.0,39.5,0.34,5.0);
        for(i=[0:len(insets_x)-2]) hull() {
            crt_profile(insets_x[i],insets_z[i],faces[i]);
            crt_profile(insets_x[i+1],insets_z[i+1],faces[i+1]);
        }
    }
}

module render_screen_skin() {
    // Shift the complete bulb 0.08 mm toward the viewer so the renderer can
    // colour the curved glass without creating another printable component.
    crt_screen_bulb(-0.08);
}

module render_key_skin(x,y,w=4.2,d=3.5) {
    translate([x,y,key_z(y)]) rotate([key_angle,0,0])
        translate([-w/2,-d/2,0.76])
            linear_extrude(height=0.10) offset(r=0.50)
                square([w-1.0,d-1.0],center=true);
}

module render_grey_key_skins() {
    for (row=[0:4]) {
        y=-41.0+row*7.2;
        count=row==0 ? 12 : (row==1 ? 11 : (row==2 ? 11 : 10));
        spacing=5.45;
        shift=row==1 ? 1.5 : (row==3 ? -1.2 : 0);
        for(col=[0:count-1]) {
            x=(col-(count-1)/2)*spacing+shift;
            if(!(row==3 && col==7)) render_key_skin(x,y);
        }
    }
    for(x=[-27:9:27]) render_key_skin(x,-9.0,7.0,4.0);
    render_key_skin(-7.5,-45.3,24.0,3.8);
}

module render_green_skins() {
    render_key_skin(15.15,-19.4,6.5,4.1);
    translate([36.0,-4.07,29.075]) rounded_xz(2.45,4.85,0.10,0.58);
    translate([-22.0,-4.02,51.0]) rotate([90,0,0])
        linear_extrude(height=0.10)
            text(">",size=7.0,font="Liberation Mono:style=Bold",
                 halign="left",valign="center");
    translate([-13.1,-4.02,48.1]) rotate([90,0,0])
        linear_extrude(height=0.10) square([4.0,6.2]);
}

module side_vents() {
    for(z=[34:4:58])
        translate([case_w/2-wall-0.8,49,z]) cube([wall+2.0,14.0,1.55]);
}

module bay_cavity() {
    // Full-width lower passage. Chamfered roof reduces the unsupported bridge
    // to 30 mm, suitable for the K2 after the supplied bridge settings.
    // Keep the internal roof behind the rear skin, not open to the exterior.
    translate([0,case_d-wall-1.0,2.0])
        rotate([90,0,0]) linear_extrude(height=case_d-wall-6.0)
            polygon(points=[
                [-bay_opening_w/2,0], [bay_opening_w/2,0],
                [bay_opening_w/2,bay_opening_h], [15,35],
                [-15,35], [-bay_opening_w/2,bay_opening_h]
            ]);
}

module bay_guide_structure() {
    // The hollow cabinet no longer needs a solid tunnel around the cartridge.
    // Two thin U-shaped longitudinal rails locate its sides and prevent lift.
    guide_y0=4.5;
    guide_y1=case_d-bay_flange_recess_d;
    guide_inner_x=bay_opening_w/2;
    guide_outer_x=case_w/2-wall;
    guide_top_z=bay_installed_z+bay_body_h+0.80;

    for(side=[-1,1]) {
        x0=side<0 ? -guide_outer_x : guide_inner_x;
        translate([x0,guide_y0,1.60])
            cube([guide_outer_x-guide_inner_x,
                  guide_y1-guide_y0,
                  guide_top_z-1.60]);

        // Inward top lip turns each longitudinal guide into a real U-channel.
        lip_x0=side<0 ? -guide_outer_x : guide_inner_x-4.8;
        translate([lip_x0,guide_y0,guide_top_z])
            cube([guide_outer_x-guide_inner_x+4.8,
                  guide_y1-guide_y0,wall]);
    }
}

module rear_print_bridge_ribs() {
    // Printing on the flat rear turns the front wall into a roof. Three
    // permanent 1.2 mm ribs reduce its maximum bridge from ~70 mm to 24 mm
    // while leaving virtually the complete upper cabinet volume hollow.
    rib_t=1.20;
    rib_z0=bay_installed_z+bay_body_h+wall+1.0;
    for(x=[-24,0,24])
        translate([x-rib_t/2,wall-0.4,rib_z0])
            // End at Y=69.8: 0.2 mm inside the rear wall but 0.1 mm clear
            // of the installed bay flange, whose inner face begins at 69.9.
            cube([rib_t,case_d-2*wall+0.6,case_h-wall-rib_z0]);
}

module rear_bay_opening() {
    // The narrow through-opening passes only the cartridge body. A wider,
    // shallow outer pocket receives the flange and leaves a positive axial
    // shoulder instead of letting the complete flange disappear into the case.
    translate([-bay_opening_w/2,case_d-wall-1.0,-0.4])
        cube([bay_opening_w,wall+3.0,
              bay_installed_z+bay_opening_h+0.4]);
    translate([-bay_flange_w/2-0.25,case_d-bay_flange_recess_d,
               bay_installed_z-0.25])
        cube([bay_flange_w+0.50,bay_flange_recess_d+0.6,
              bay_flange_h+0.50]);
}

module hidden_case_watermark() {
    // With the case printed on its rear, original Y becomes print Z. This void
    // therefore remains exactly three 0.20 mm layers inside the rear wall.
    translate([0,case_d-watermark_z,55]) rotate([90,0,0])
        linear_extrude(height=watermark_h)
        text(watermark_text,size=4.1,font="DejaVu Sans:style=Bold",
             halign="center",valign="center",spacing=1.05);
}

module case_core() {
    union() {
        difference() {
            cabinet_outer();
            cabinet_inner();
            rear_bay_opening();
            side_vents();
        }
        bay_guide_structure();
        rear_print_bridge_ribs();
    }
}

module case_v05() {
    difference() {
        union() {
            case_core();
            front_features();
        }
        hidden_case_watermark();
        keyboard_receiver_holes();
    }
}

module case_print_v05() {
    // Export orientation: broad flat rear face on Z=0. CRT and green details
    // become bounded top layers; no slicer rotation is required.
    translate([0,0,case_d]) rotate([-90,0,0]) case_v05();
}

module imported_case_assembly() {
    // Inverse of case_print_v05(), used so route tests still inspect the exact
    // exported print STL in the normal assembly coordinate system.
    rotate([90,0,0]) translate([0,0,-case_d])
        import("../stl/v0.5/minitel_case_v0.5.stl");
}

// ----- Rear bay / loaded cartridge -----
module placed_pcb(offset_y=0,thickness=pcb_thickness) {
    translate([-pcb_length/2,pcb_rear_y-18.11024+offset_y,pcb_z])
        mirror([1,0,0]) rotate([0,0,90])
            linear_extrude(height=thickness) pcb_reference_2d();
}

module reset_envelope(offset_y=0) {
    translate([reset_x-1.8,
               pcb_rear_y-(3.2-reset_protrusion)+offset_y,
               pcb_z+pcb_thickness])
        cube([3.6,3.2,2.3]);
}

module component_envelopes(offset_y=0,with_reset=true) {
    translate([-22.0,43.0+offset_y,1.00]) cube([20.0,14.0,pcb_z-1.00]);
    translate([usb_x0,pcb_rear_y-2.0+offset_y,pcb_z+pcb_thickness])
        cube([usb_x1-usb_x0,usb_outer_y-pcb_rear_y+2.0,3.2]);
    if(with_reset) reset_envelope(offset_y);
    translate([-2.0,18.8+offset_y,pcb_z+pcb_thickness]) cube([11.0,8.0,5.10]);
}

module usb_service_envelope() {
    // Conservative plug/hand-access volume through the rear face. This is
    // intentionally taller than the metal shell measured on the board.
    translate([usb_x0-1.5,bay_d-3.0,0.20])
        cube([(usb_x1-usb_x0)+3.0,8.0,usb_access_z1-0.40]);
}

module left_pcb_rail() {
    difference() {
        union() {
            translate([-rail_outer_x,rail_front_y,bay_floor_h-0.10])
                cube([rail_outer_x-lip_inner_x,rail_rear_y-rail_front_y,
                      slot_bottom_z-bay_floor_h+0.10]);
            translate([-rail_outer_x,rail_front_y,slot_bottom_z])
                cube([rail_outer_x-slot_wall_x,rail_rear_y-rail_front_y,
                      slot_top_z-slot_bottom_z]);
            translate([-rail_outer_x,rail_front_y,slot_top_z])
                cube([rail_outer_x-lip_inner_x,rail_rear_y-rail_front_y,
                      rail_top_z-slot_top_z]);
            // Front flare receives the broad USB-C edge while the already
            // connected JST cable remains free above the open bay.
            hull() {
                translate([-rail_outer_x,rail_front_y-0.2,slot_top_z])
                    cube([rail_outer_x-lip_inner_x,0.4,rail_top_z-slot_top_z]);
                translate([-rail_outer_x,rail_mouth_y-0.2,slot_top_z])
                    cube([rail_outer_x-(lip_inner_x+1.3),0.4,
                          rail_top_z-slot_top_z]);
            }
            hull() {
                translate([-rail_outer_x,rail_front_y-0.2,bay_floor_h-0.1])
                    cube([rail_outer_x-lip_inner_x,0.4,
                          slot_bottom_z-bay_floor_h+0.1]);
                translate([-rail_outer_x,rail_mouth_y-0.2,bay_floor_h-0.1])
                    cube([rail_outer_x-(lip_inner_x+1.3),0.4,
                          slot_bottom_z-bay_floor_h+0.1]);
            }
        }
        // RESET travels beside this left lip.
        translate([-23.8,57.5,slot_top_z-0.1])
            cube([4.9,7.2,rail_top_z-slot_top_z+0.2]);
    }
}

module pcb_rails() {
    left_pcb_rail();
    mirror([1,0,0]) left_pcb_rail();
}

module cable_node(p) { translate([p[0],p[1],cable_z]) sphere(d=cable_d); }
module cable_segment(a,b) { hull() { cable_node(a); cable_node(b); } }
module cable_reference() {
    // JST is connected before loading. The outside of the measured 4.3 mm
    // lead turns exactly 60 mm in front of the protruding USB-C edge.
    pts=[[3.5,19.0],[3.5,10.0],[8.0,loop_front_y],[18.0,loop_front_y],
         [24.5,12.5],[24.5,65.5]];
    for(i=[0:len(pts)-2]) cable_segment(pts[i],pts[i+1]);
}

module bay_side_frames() {
    // Continuous outside runners plus a front bridge; the PCB itself rests
    // only in the two internal edge guides.
    for(x=[-bay_w/2,bay_w/2-2.4])
        translate([x,0,0]) cube([2.4,bay_d,bay_body_h]);
    // Narrow floor runners guide the cable without forming a snap-on plate.
    translate([-bay_w/2,0,0]) cube([5.0,bay_d,bay_floor_h]);
    translate([bay_w/2-5.0,0,0]) cube([5.0,bay_d,bay_floor_h]);
    // A four-layer front bridge joins both runners below the underside
    // component envelope. Only the latch anchor is locally full floor height.
    translate([-bay_w/2,0,0]) cube([bay_w,4.0,4*layer_h]);
    translate([pcb_latch_x-pcb_latch_w/2,0,0])
        cube([pcb_latch_w,4.0,bay_floor_h]);
}

module pcb_retention_latch() {
    // Long 0.8 mm floor cantilever: the board nose depresses the shallow ramp
    // by only 0.35 mm while loading. Once past it, the upright rear face stops
    // the PCB moving toward the open end when a USB plug is inserted.
    beam_y0=3.8;
    translate([pcb_latch_x-pcb_latch_w/2,beam_y0,bay_floor_h])
        cube([pcb_latch_w,pcb_latch_tip_y-beam_y0,pcb_latch_t]);
    hull() {
        translate([pcb_latch_x-pcb_latch_w/2,pcb_latch_tip_y-2.6,
                   bay_floor_h+pcb_latch_t-0.05])
            cube([pcb_latch_w,0.35,0.20]);
        translate([pcb_latch_x-pcb_latch_w/2,pcb_latch_tip_y-0.35,
                   bay_floor_h+pcb_latch_t-0.05])
            cube([pcb_latch_w,0.35,
                  pcb_latch_hook_z-(bay_floor_h+pcb_latch_t)+0.05]);
    }
}

module cable_keepers() {
    // Two open-top outside fences accept the already-connected 4.3 mm cable
    // from above. A matching inside post would block the broad PCB edge while
    // loading, so the PCB/upper rail forms the inner boundary instead.
    keeper_wall=1.35;
    keeper_h=cable_z+0.25;
    for(y=[17.0,29.0]) {
        translate([24.5+cable_d/2+0.20,y,0])
            cube([keeper_wall,3.0,bay_floor_h]);
        translate([24.5+cable_d/2+0.20,y,bay_floor_h])
            cube([keeper_wall,3.0,keeper_h-bay_floor_h]);
    }
}

module reset_cantilever() {
    // One-piece flexible tongue, attached at the top. The outer pad protrudes
    // 0.7 mm and the inner nub reaches the tactile switch.
    tab_w=5.2; tab_h=8.0; tab_t=1.15;
    translate([reset_x-tab_w/2,bay_d-tab_t,reset_z-tab_h/2])
        cube([tab_w,tab_t,tab_h]);
    translate([reset_x-1.55,bay_d-0.05,reset_z-1.55])
        cube([3.1,0.68,3.1]);
    // 0.30 mm nominal gap to the switch envelope at rest, no preload.
    translate([reset_x-1.15,pcb_rear_y+1.8,reset_z-1.15])
        cube([2.3,bay_d-tab_t-(pcb_rear_y+1.8)+0.1,2.3]);
}

module bay_rear_face() {
    difference() {
        translate([-bay_flange_w/2,bay_d-bay_flange_t,0])
            cube([bay_flange_w,bay_flange_t,bay_flange_h]);
        // Bottom-open USB-C service notch. Physical fit testing showed that
        // the connector sits below the former enclosed window. Opening the
        // cut to the underside also avoids a fragile/sagging printed lip.
        translate([usb_x0-2.0,bay_d-2.5,-0.1])
            cube([(usb_x1-usb_x0)+4.0,3.5,usb_access_z1+0.1]);
        // Open-top cable lay-in notch: the DIN plug never passes through it.
        translate([20.0,bay_d-2.5,7.4]) cube([10.0,3.5,bay_flange_h+2.0]);
        // U-slot leaves the reset tongue connected only across its top edge.
        translate([reset_x-3.3,bay_d-2.5,reset_z-5.0]) cube([6.6,3.5,0.8]);
        translate([reset_x-3.3,bay_d-2.5,reset_z-5.0]) cube([0.8,3.5,10.0]);
        translate([reset_x+2.5,bay_d-2.5,reset_z-5.0]) cube([0.8,3.5,10.0]);
    }
    reset_cantilever();
}

module bay_detents() {
    // Shallow friction beads, printable without support and intentionally
    // conservative for the K2. Sand once if a filament runs oversized.
    for(x=[-bay_w/2-0.18,bay_w/2+0.18])
        translate([x,bay_d-12,7.5]) rotate([90,0,0]) cylinder(h=5,d=0.70);
}

module hidden_bay_watermark() {
    translate([0,bay_d-1.0,watermark_z]) linear_extrude(height=watermark_h)
        text(watermark_text,size=1.35,font="DejaVu Sans:style=Bold",
             halign="center",valign="center",spacing=1.05);
}

module bay_v05(with_detents=true,with_latch=true) {
    difference() {
        union() {
            bay_side_frames();
            pcb_rails();
            cable_keepers();
            if(with_latch) pcb_retention_latch();
            bay_rear_face();
            if(with_detents) bay_detents();
        }
        hidden_bay_watermark();
    }
}

module assembly_v05() {
    color("#dcc9a4") case_v05();
    color("#dcc9a4") keyboard_v05();
    translate([0,bay_installed_y,bay_installed_z]) color("#c9b48f") bay_v05();
    translate([0,bay_installed_y,bay_installed_z]) color("#10201b") placed_pcb();
    translate([0,bay_installed_y,bay_installed_z]) color("#a9aaa6") component_envelopes();
    translate([0,bay_installed_y,bay_installed_z]) color("#222222") cable_reference();
}

if(part=="case") case_print_v05();
else if(part=="case_assembly") case_v05();
else if(part=="case_cutaway") difference() {
    case_v05();
    // Remove the right half plus the centre bridge rib so the hollow volume,
    // left bay U-guide and remaining print rib are visible in the review.
    translate([-5,-8,-1]) cube([65,90,90]);
}
else if(part=="keyboard") keyboard_v05();
else if(part=="bay") bay_v05();
else if(part=="bay_no_latch") bay_v05(true,false);
else if(part=="pcb_latch") pcb_retention_latch();
else if(part=="assembly") assembly_v05();
else if(part=="pcb") { placed_pcb(); component_envelopes(); }
else if(part=="pcb_bare") placed_pcb();
else if(part=="components") component_envelopes();
else if(part=="usb_access_interference") intersection() {
    bay_v05();
    usb_service_envelope();
}
else if(part=="cable") cable_reference();
else if(part=="render_screen") render_screen_skin();
else if(part=="render_keys") render_grey_key_skins();
else if(part=="render_green") render_green_skins();
else if(part=="keyboard_case_interference") intersection() {
    case_v05();
    keyboard_v05();
}
else if(part=="case_bay_interference") intersection() {
    imported_case_assembly();
    translate([0,bay_installed_y+sweep_offset,bay_installed_z]) bay_v05(false,true);
}
else if(part=="loaded_bay_interference") intersection() {
    imported_case_assembly();
    translate([0,bay_installed_y+sweep_offset,bay_installed_z]) union() {
        bay_v05(false,true);
        placed_pcb();
        component_envelopes(0,false);
        cable_reference();
    }
}
else if(part=="pcb_insertion_interference") intersection() {
    bay_v05(false,false);
    union() { placed_pcb(sweep_offset); component_envelopes(sweep_offset,false); }
}
else if(part=="bay_route_interference") intersection() {
    bay_v05(false,true);
    union() { placed_pcb(); component_envelopes(0,false); cable_reference(); }
}
else if(part=="reset_contact") intersection() {
    reset_cantilever();
    reset_envelope();
}
else if(part=="reset_pressed_contact") intersection() {
    translate([0,-0.5,0]) reset_cantilever();
    reset_envelope();
}
else if(part=="pcb_support_contact") intersection() {
    bay_v05(false,false);
    translate([0,0,-0.31]) placed_pcb();
}
else if(part=="pcb_latch_rest_contact") intersection() {
    pcb_retention_latch();
    placed_pcb();
}
else if(part=="pcb_latch_retention_contact") intersection() {
    pcb_retention_latch();
    placed_pcb(-0.70);
}
else if(part=="bay_stop_contact") intersection() {
    imported_case_assembly();
    translate([0,bay_installed_y-0.20,bay_installed_z]) bay_v05(false,false);
}
