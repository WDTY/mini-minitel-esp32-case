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
    if result.returncode not in (0, 1):
        raise RuntimeError(result.stderr)
    return output.exists() and output.stat().st_size > 84


for name, path in FILES.items():
    mesh = load_stl(path)
    invalid = nonmanifold_edges(mesh)
    bounds = (mesh.min(axis=(0, 1)), mesh.max(axis=(0, 1)))
    print(name, "triangles", len(mesh), "nonmanifold_edges", invalid,
          "bounds", bounds[0], bounds[1])
    assert invalid == 0

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

print("PCB insertion positions sampled:", 49)
print("PCB hard collisions:", pcb_hits or "none")
print("Loaded-bay insertion positions sampled:", 71)
print("Loaded-bay hard collisions:", loaded_bay_hits or "none")
print("Installed PCB/cable collision:", "yes" if route_hit else "none")
print("Reset plunger reaches switch envelope:", "yes" if reset_contact else "NO")

if pcb_hits or loaded_bay_hits or route_hit or not reset_contact:
    raise SystemExit(1)
