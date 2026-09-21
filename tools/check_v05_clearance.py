"""Mechanical checks for the complete v0.5 Minitel case and rear bay."""

from collections import Counter
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import subprocess
import tempfile

import numpy as np

from render_preview import ROOT, load_stl


SCAD = ROOT / "src/minitel_v05.scad"
FILES = {
    "case": ROOT / "stl/v0.5/minitel_case_v0.5.stl",
    "bay": ROOT / "stl/v0.5/minitel_esp32_bay_v0.5.stl",
}


def nonmanifold_edges(mesh: np.ndarray) -> int:
    edges: Counter[tuple] = Counter()
    for triangle in mesh:
        vertices = [tuple(round(float(v), 5) for v in point) for point in triangle]
        for a, b in zip(vertices, vertices[1:] + vertices[:1]):
            edges[tuple(sorted((a, b)))] += 1
    return sum(count != 2 for count in edges.values())


def shell_sizes(mesh: np.ndarray) -> list[float]:
    """Connected surface bounding diagonals; small enclosed watermark shells allowed."""
    parent = list(range(len(mesh)))
    def root(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i
    seen = {}
    for i, tri in enumerate(mesh):
        for point in tri:
            key = tuple(round(float(v), 5) for v in point)
            if key in seen:
                parent[root(i)] = root(seen[key])
            else:
                seen[key] = i
    groups = {}
    for i, tri in enumerate(mesh):
        groups.setdefault(root(i), []).extend(tri)
    return sorted([float(np.linalg.norm(np.ptp(points, axis=0)))
                   for points in groups.values()], reverse=True)


def intersection_exists(part: str, output: Path, offset: int | None = None) -> bool:
    args = [
        "openscad", "--export-format", "binstl",
        "-D", f'part="{part}"',
    ]
    if offset is not None:
        args += ["-D", f"sweep_offset={offset}"]
    args += ["-o", str(output), str(SCAD)]
    if output.exists():
        output.unlink()
    result = subprocess.run(args, capture_output=True, text=True, timeout=35)
    if result.returncode != 0 and "Current top level object is empty" not in result.stderr:
        raise RuntimeError(result.stderr)
    if "ERROR:" in result.stderr:
        raise RuntimeError(result.stderr)
    return output.exists() and output.stat().st_size > 84


for name, path in FILES.items():
    # Route tests import this exact, freshly exported complete case mesh.
    subprocess.run(["openscad", "--export-format", "binstl", "-D",
                    f'part="{name}"', "-o", str(path), str(SCAD)],
                   check=True, capture_output=True, timeout=120)
    mesh = load_stl(path)
    invalid = nonmanifold_edges(mesh)
    bounds = (mesh.min(axis=(0, 1)), mesh.max(axis=(0, 1)))
    print(name, "triangles", len(mesh), "nonmanifold_edges", invalid,
          "bounds", bounds[0], bounds[1])
    assert invalid == 0
    shells = shell_sizes(mesh)
    print(name, "surface shell diagonals:", shells)
    assert sum(size > 10 for size in shells) == 1, "Detached structural part"

assert len(list((ROOT / "stl/v0.5").glob("*.stl"))) == 2

with tempfile.TemporaryDirectory(prefix="minitel-v05-") as directory:
    root = Path(directory)

    def sampled_hit(job: tuple[str, int]) -> tuple[str, int, bool]:
        kind, offset = job
        part = ("pcb_insertion_interference" if kind == "pcb"
                else "loaded_bay_interference")
        output = root / f"{kind}-{offset}.stl"
        return kind, offset, intersection_exists(part, output, offset)

    jobs = ([('pcb', offset) for offset in range(-48, 1)] +
            [('bay', offset) for offset in range(0, 71)])
    with ThreadPoolExecutor(max_workers=8) as pool:
        results = list(pool.map(sampled_hit, jobs))

    pcb_hits = [offset for kind, offset, hit in results if kind == 'pcb' and hit]
    loaded_bay_hits = [offset for kind, offset, hit in results if kind == 'bay' and hit]
    route_hit = intersection_exists("bay_route_interference", root / "route.stl")
    reset_contact = intersection_exists("reset_contact", root / "reset.stl")
    reset_pressed = intersection_exists("reset_pressed_contact", root / "pressed.stl")
    support = intersection_exists("pcb_support_contact", root / "support.stl")
    latch_rest = intersection_exists("pcb_latch_rest_contact", root / "latch-rest.stl")
    latch_retention = intersection_exists("pcb_latch_retention_contact", root / "latch-lock.stl")
    bay_stop = intersection_exists("bay_stop_contact", root / "bay-stop.stl")
    cable_path = root / "cable.stl"
    intersection_exists("cable", cable_path)
    cable_mesh = load_stl(cable_path)
    cable_front = float(cable_mesh[:, :, 1].min())
    assert abs((64.0 - cable_front) - 60.0) < 0.05, "Cable loop is not 60 mm deep"
    assert support, "PCB has no lower support"
    support_mesh = load_stl(root / "support.stl")
    assert support_mesh[:,:,0].min() < -22 and support_mesh[:,:,0].max() > 22, "Support missing on one PCB edge"

print("PCB insertion positions sampled:", 49)
print("PCB hard collisions:", pcb_hits or "none")
print("Loaded-bay insertion positions sampled:", 71)
print("Loaded-bay hard collisions:", loaded_bay_hits or "none")
print("Installed PCB/cable collision:", "yes" if route_hit else "none")
print("PCB lower support on both edges:", support)
print("Reset preloaded at rest:", reset_contact)
print("Reset contact after 0.5 mm inward travel:", reset_pressed)
print("PCB latch touches at rest:", latch_rest)
print("PCB latch catches after 0.7 mm outward travel:", latch_retention)
print("Bay flange catches shoulder after 0.20 mm overtravel:", bay_stop)
print("USB-C edge to outside of cable bend (mm):", round(64.0 - cable_front, 3))

if (pcb_hits or loaded_bay_hits or route_hit or reset_contact or not reset_pressed
        or latch_rest or not latch_retention or not bay_stop):
    raise SystemExit(1)
