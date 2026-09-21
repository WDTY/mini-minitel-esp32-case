"""Rebuild and render the complete three-part v0.5 design."""

from pathlib import Path
import subprocess

import numpy as np

from render_preview import ROOT, load_stl, rasterize


SCAD = ROOT / "src/minitel_v05.scad"
STL = ROOT / "stl/v0.5"
RENDERS = ROOT / "assets/renders/v0.5"
RENDERS.mkdir(parents=True, exist_ok=True)


def export(part: str, output: Path):
    subprocess.run(
        ["openscad", "--export-format", "binstl", "-D", f'part="{part}"',
         "-o", str(output), str(SCAD)],
        check=True, capture_output=True, text=True,
    )
    return load_stl(output)


case_print = export("case", STL / "minitel_case_v0.5.stl")
case = export("case_assembly", Path("/tmp/minitel-v05-case-assembly.stl"))
case_cutaway = export("case_cutaway", Path("/tmp/minitel-v05-case-cutaway.stl"))
keyboard = export("keyboard", STL / "minitel_keyboard_v0.5.stl")
bay = export("bay", STL / "minitel_esp32_bay_v0.5.stl")
bay_no_latch = export("bay_no_latch", Path("/tmp/minitel-v05-bay-no-latch.stl"))
latch = export("pcb_latch", Path("/tmp/minitel-v05-latch.stl"))
pcb = export("pcb_bare", Path("/tmp/minitel-v05-pcb.stl"))
components = export("components", Path("/tmp/minitel-v05-components.stl"))
cable = export("cable", Path("/tmp/minitel-v05-cable.stl"))
screen = export("render_screen", Path("/tmp/minitel-v05-screen.stl"))
keys = export("render_keys", Path("/tmp/minitel-v05-keys.stl"))
green = export("render_green", Path("/tmp/minitel-v05-green.stl"))

beige = np.array([0.82, 0.73, 0.57])
bay_colour = np.array([0.68, 0.57, 0.41])
screen_colour = np.array([0.025, 0.075, 0.065])
key_colour = np.array([0.27, 0.24, 0.20])
green_colour = np.array([0.15, 0.90, 0.39])
metal = np.array([0.55, 0.58, 0.56])
wire = np.array([0.025, 0.028, 0.027])

installed = np.array([0.0, 5.90, 2.2])
withdrawn = np.array([0.0, 82.0, 2.2])

rasterize(
    [(case, beige), (keyboard, beige),
     (screen, screen_colour), (keys, key_colour),
     (green, green_colour), (bay + installed, bay_colour),
     (pcb + installed, screen_colour), (components + installed, metal),
     (cable + installed, wire)],
    RENDERS / "complete-assembly-v0.5.png",
    eye=(142, -175, 112), target=(0, 10, 34), view_angle=29,
    size=(1400, 1100),
)

keyboard_exploded = np.array([0.0, -27.0, 10.0])
rasterize(
    [(case, beige), (keyboard + keyboard_exploded, beige),
     (screen, screen_colour),
     (keys + keyboard_exploded, key_colour),
     (green, green_colour)],
    RENDERS / "keyboard-exploded-v0.5.png",
    eye=(145, -190, 105), target=(0, -4, 34), view_angle=31,
    size=(1400, 1000),
)

rasterize(
    [(case_cutaway, beige)],
    RENDERS / "hollow-case-cutaway-v0.5.png",
    eye=(150, -145, 100), target=(0, 28, 37), view_angle=30,
    size=(1400, 1000),
)

rasterize(
    [(case, beige), (keyboard, beige),
     (screen, screen_colour), (keys, key_colour),
     (green, green_colour), (bay + withdrawn, bay_colour),
     (pcb + withdrawn, screen_colour), (components + withdrawn, metal),
     (cable + withdrawn, wire)],
    RENDERS / "rear-bay-exploded-v0.5.png",
    eye=(160, 220, 115), target=(0, 70, 26), view_angle=38,
    size=(1400, 1100),
)

rasterize(
    [(bay, bay_colour), (pcb, screen_colour), (components, metal),
     (cable, wire)],
    RENDERS / "loaded-bay-v0.5.png",
    eye=(105, 125, 75), target=(0, 38, 8), view_angle=31,
    size=(1300, 900),
)

rasterize(
    [(bay_no_latch, bay_colour), (latch, green_colour)],
    RENDERS / "bay-mechanics-v0.5.png",
    eye=(42, -145, 142), target=(0, 33, 5), view_angle=26,
    size=(1300, 900),
)
