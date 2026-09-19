// v0.5 rear-bay fit test for the iodeo ESP Minitel V2 JST board.
// Units: mm. This fixture validates insertion and cable routing before the
// geometry is integrated into another full Minitel body print.

include <pcb_reference.scad>

part = "fixture"; // fixture, coupon, retainer, retainer_assembly, pcb, pcb_bare, components, cable, assembly, position_interference, route_interference
sweep_offset = 0;
$fn = 36;

// Measured hardware and Gerber-derived board dimensions.
pcb_length = 47.10521;
pcb_depth = 36.21792;
pcb_thickness = 1.60;
populated_height = 10.40;

// The USB-C side is the rear/trailing edge. Its metal shell is modelled as
// projecting 4 mm beyond the PCB for routing review, not as a fit datum.
pcb_rear_y = 60.0;
usb_outer_y = 64.0;
loop_front_y = 4.0;
route_depth = usb_outer_y - loop_front_y; // owner-selected 60 mm

pcb_z = 4.70;
slot_vertical_clearance = 0.30;
slot_side_clearance = 0.35;
// One millimetre is enough to carry the 1.6 mm PCB edge while keeping the
// nearby ESP32 module clear on the underside.
edge_capture = 1.00;

// Creality K2 baseline: 0.4 mm nozzle and 0.20 mm layers. Structural walls
// are multiples of practical line widths; the hidden mark spans three layers.
fixture_half_w = 31.0;
fixture_front_y = 0.0;
fixture_rear_y = 68.0;
base_h = 1.80;
rail_front_y = 37.40;
rail_rear_y = 62.00;
rail_mouth_y = 66.50;
rail_top_z = 8.00;
rail_outer_x = 28.70;

// Provisional until the cable is measured. The open fixture remains usable
// with a larger cable; this value controls only the visual routing reference.
cable_d = 5.0;
cable_z = rail_top_z + cable_d/2 + 0.20;

watermark_text = "WDTY v0.5";
watermark_z = 0.60;
watermark_h = 0.60;

board_edge_x = pcb_length/2;
slot_wall_x = board_edge_x + slot_side_clearance;
lip_inner_x = board_edge_x - edge_capture;
slot_bottom_z = pcb_z - slot_vertical_clearance;
slot_top_z = pcb_z + pcb_thickness + slot_vertical_clearance;

module placed_pcb(offset_y=0, thickness=pcb_thickness) {
    // Gerber (x,y) -> fixture (y,x): the USB/JST axis becomes front-to-rear.
    translate([-pcb_length/2, pcb_rear_y-18.11024+offset_y, pcb_z])
        mirror([1,0,0]) rotate([0,0,90])
            linear_extrude(height=thickness) pcb_reference_2d();
}

module left_rail(y0=rail_front_y, y1=rail_rear_y, mouth_y=rail_mouth_y) {
    // C-channel facing the PCB. Only the bare board edge enters the slot.
    difference() {
        union() {
            translate([-rail_outer_x,y0,base_h-0.15]) cube([rail_outer_x-slot_wall_x,y1-y0,slot_bottom_z-base_h+0.15]);
            translate([-rail_outer_x,y0,slot_top_z]) cube([rail_outer_x-lip_inner_x,y1-y0,rail_top_z-slot_top_z]);
            translate([-rail_outer_x,y0,slot_bottom_z]) cube([rail_outer_x-slot_wall_x,y1-y0,slot_top_z-slot_bottom_z]);

            // A flared mouth helps the broad USB-side edge find both slots.
            hull() {
                translate([-rail_outer_x,y1-0.20,base_h-0.15]) cube([rail_outer_x-lip_inner_x,0.40,slot_bottom_z-base_h+0.15]);
                translate([-rail_outer_x,mouth_y-0.20,base_h-0.15]) cube([rail_outer_x-(lip_inner_x+1.30),0.40,slot_bottom_z-base_h+0.15]);
            }
            hull() {
                translate([-rail_outer_x,y1-0.20,slot_top_z]) cube([rail_outer_x-lip_inner_x,0.40,rail_top_z-slot_top_z]);
                translate([-rail_outer_x,mouth_y-0.20,slot_top_z]) cube([rail_outer_x-(lip_inner_x+1.30),0.40,rail_top_z-slot_top_z]);
            }
        }

        // RESET sits very close to this board edge. This window keeps its
        // entire insertion path free while the remaining lip retains the PCB.
        translate([-23.75,57.70,slot_top_z-0.10])
            cube([4.75,mouth_y-57.50,rail_top_z-slot_top_z+0.20]);
    }
}

module right_rail(y0=rail_front_y, y1=rail_rear_y, mouth_y=rail_mouth_y) {
    mirror([1,0,0]) left_rail(y0,y1,mouth_y);
}

module rear_sockets() {
    // Vertical grooves accept the removable retainer after PCB insertion.
    difference() {
        union() {
            translate([-fixture_half_w,64.0,0]) cube([4.2,4.0,18.0]);
            translate([fixture_half_w-4.2,64.0,0]) cube([4.2,4.0,18.0]);
        }
        translate([-fixture_half_w+1.0,65.55,1.0]) cube([2.3,2.10,18.0]);
        translate([fixture_half_w-3.3,65.55,1.0]) cube([2.3,2.10,18.0]);
    }
}

module hidden_watermark(y=4.0) {
    // Enclosed void: 3 x 0.20 mm layers below, in, and above the mark.
    translate([0,y,watermark_z])
        linear_extrude(height=watermark_h)
            text(watermark_text,size=3.6,font="DejaVu Sans:style=Bold",
                 halign="center",valign="center",spacing=1.05);
}

module fixture_v05() {
    difference() {
        union() {
            // Open U-frame: no carrier plate beneath the PCB.
            translate([-fixture_half_w,fixture_front_y,0]) cube([2.80,fixture_rear_y,base_h]);
            translate([fixture_half_w-2.80,fixture_front_y,0]) cube([2.80,fixture_rear_y,base_h]);
            translate([-fixture_half_w,fixture_front_y,0]) cube([2*fixture_half_w,8.00,base_h]);
            left_rail();
            right_rail();
            rear_sockets();
        }
        hidden_watermark();
    }
}

module guide_coupon_v05() {
    // A short, low-filament test of the 47.105 mm board width and 2.20 mm slot.
    translate([0,-37.4,0]) difference() {
        union() {
            left_rail(37.4,49.4,53.9);
            right_rail(37.4,49.4,53.9);
            translate([-28.7,37.4,0]) cube([57.4,6.0,base_h]);
        }
        hidden_watermark(40.4);
    }
}

module retainer_v05() {
    // Slides down into the rear grooves. The centre stays open for USB-C,
    // RESET and laying in the attached cable/DIN lead.
    union() {
        translate([-29.75,65.70,1.0]) cube([1.80,1.80,16.0]);
        translate([27.95,65.70,1.0]) cube([1.80,1.80,16.0]);
        translate([-29.75,65.70,14.0]) cube([59.50,1.80,3.0]);

        // One stop finger bears on a connector-free end of the PCB rear edge.
        translate([16.5,60.20,slot_bottom_z])
            cube([3.0,6.40,slot_top_z-slot_bottom_z]);
        translate([16.5,65.70,slot_bottom_z])
            cube([3.0,1.80,14.0-slot_bottom_z+0.10]);
    }
}

module printable_retainer_v05() {
    // Rotate the rear face onto the build plate. The stop becomes an upright
    // printable rib and needs no generated support.
    translate([0,-1.0,67.50]) rotate([-90,0,0]) retainer_v05();
}

module component_envelopes(offset_y=0) {
    // Conservative photo-derived visual envelopes. They deliberately do not
    // claim exact component placement; only the measured 10.4 mm total height
    // and obvious USB/JST/ESP32 sides are represented.
    // ESP32 module below the board.
    translate([-22.0,43.0+offset_y,1.00]) cube([20.0,14.0,pcb_z-1.00]);
    // USB-C shell at the rear.
    translate([-15.5,pcb_rear_y-2.0+offset_y,pcb_z+pcb_thickness])
        cube([8.5,usb_outer_y-pcb_rear_y+2.0,3.2]);
    // RESET switch beside USB-C.
    translate([-22.7,pcb_rear_y-1.7+offset_y,pcb_z+pcb_thickness]) cube([3.6,3.2,2.3]);
    // JST connector and inserted plug at the front of the populated board.
    translate([-2.0,18.8+offset_y,pcb_z+pcb_thickness]) cube([11.0,8.0,5.10]);
}

module cable_node(p) { translate([p[0],p[1],cable_z]) sphere(d=cable_d); }
module cable_segment(a,b) { hull() { cable_node(a); cable_node(b); } }
module cable_reference() {
    // Cable is already attached before insertion. It leaves the JST toward
    // the front, makes the requested relaxed bend and returns above the right
    // guide rail to the open rear face.
    pts = [[3.5,19.0],[3.5,9.0],[8.0,4.0],[18.0,4.0],[24.0,10.0],[24.0,68.0]];
    for(i=[0:len(pts)-2]) cable_segment(pts[i],pts[i+1]);
}

module assembly_v05() {
    color("#d8c7a7") fixture_v05();
    color("#cf7b35") retainer_v05();
    color("#10201b") placed_pcb();
    color("#a9aaa6") component_envelopes();
    color("#222222") cable_reference();
}

if(part=="fixture") fixture_v05();
else if(part=="coupon") guide_coupon_v05();
else if(part=="retainer") printable_retainer_v05();
else if(part=="retainer_assembly") retainer_v05();
else if(part=="pcb") { placed_pcb(); component_envelopes(); }
else if(part=="pcb_bare") placed_pcb();
else if(part=="components") component_envelopes();
else if(part=="cable") cable_reference();
else if(part=="assembly") assembly_v05();
else if(part=="position_interference") intersection() {
    fixture_v05();
    union() {
        placed_pcb(sweep_offset);
        component_envelopes(sweep_offset);
    }
}
else if(part=="board_position_interference") intersection() {
    fixture_v05();
    placed_pcb(sweep_offset);
}
else if(part=="component_position_interference") intersection() {
    fixture_v05();
    component_envelopes(sweep_offset);
}
else if(part=="route_interference") intersection() {
    fixture_v05();
    union() { component_envelopes(); cable_reference(); }
}
else if(part=="retainer_interference") intersection() {
    retainer_v05();
    union() { placed_pcb(); component_envelopes(); cable_reference(); }
}
