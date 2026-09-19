"""Verify and render the v0.5 K2 rear-bay fit-test parts."""

from collections import Counter
from pathlib import Path
import subprocess

import numpy as np

from render_preview import ROOT, load_stl, rasterize


FILES = {
    "fixture": ROOT / "stl/v0.5/minitel_rear_bay_v0.5-test.stl",
    "coupon": ROOT / "stl/v0.5/minitel_guide_coupon_v0.5-test.stl",
    "retainer": ROOT / "stl/v0.5/minitel_rear_retainer_v0.5-test.stl",
}


def topology(mesh):
    edges = Counter()
    for tri in mesh:
        vertices = [tuple(round(float(v), 5) for v in vertex) for vertex in tri]
        for a, b in zip(vertices, vertices[1:] + vertices[:1]):
            edges[tuple(sorted((a, b)))] += 1
    return sum(count != 2 for count in edges.values())


parts = {}
for name, path in FILES.items():
    mesh = load_stl(path)
    parts[name] = mesh
    invalid = topology(mesh)
    print(
        name,
        "triangles", len(mesh),
        "nonmanifold_edges", invalid,
        "bounds", mesh.min(axis=(0, 1)), mesh.max(axis=(0, 1)),
    )
    assert invalid == 0

SCAD = ROOT / "src/minitel_v05_fit_test.scad"


def export_reference(part, output):
    subprocess.run(
        [
            "openscad", "--export-format", "binstl",
            "-D", f'part="{part}"', "-o", str(output), str(SCAD),
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return load_stl(output)


pcb = export_reference("pcb_bare", Path("/tmp/v05_pcb_bare.stl"))
components = export_reference("components", Path("/tmp/v05_components.stl"))
cable = export_reference("cable", Path("/tmp/v05_cable.stl"))
retainer_assembly = export_reference(
    "retainer_assembly", Path("/tmp/v05_retainer_assembly.stl")
)

beige = np.array([0.83, 0.75, 0.61])
orange = np.array([0.80, 0.34, 0.12])
board = np.array([0.025, 0.075, 0.060])
metal = np.array([0.60, 0.63, 0.61])
wire = np.array([0.035, 0.040, 0.038])

rasterize(
    [
        (parts["fixture"], beige),
        (retainer_assembly, orange),
        (pcb, board),
        (components, metal),
        (cable, wire),
    ],
    "assets/renders/v0.5/rear-bay-assembly-v0.5.png",
    eye=(108, 142, 98),
    target=(0, 36, 6.5),
    view_angle=30,
    size=(1200, 1000),
)

# Half-inserted state. The cable remains flexible and is intentionally omitted;
# the render checks the rigid PCB/component passage only.
travel = np.array([0.0, 24.0, 0.0])
rasterize(
    [
        (parts["fixture"], beige),
        (retainer_assembly + np.array([0.0, 7.0, 18.0]), orange),
        (pcb + travel, board),
        (components + travel, metal),
    ],
    "assets/renders/v0.5/insertion-route-v0.5.png",
    eye=(106, 150, 92),
    target=(0, 46, 7.0),
    view_angle=29,
    size=(1200, 1000),
)

rasterize(
    [(parts["coupon"], beige)],
    "assets/renders/v0.5/guide-coupon-v0.5.png",
    eye=(82, -68, 58),
    target=(0, 8, 3.5),
    view_angle=27,
    size=(1200, 800),
)
