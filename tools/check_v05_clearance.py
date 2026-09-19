"""Sample the v0.5 rigid insertion route with OpenSCAD intersections."""

from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
SCAD = ROOT / "src/minitel_v05_fit_test.scad"


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
    result = subprocess.run(args, capture_output=True, text=True, timeout=10)
    if result.returncode not in (0, 1):
        raise RuntimeError(result.stderr)
    return output.exists() and output.stat().st_size > 84


with tempfile.TemporaryDirectory(prefix="minitel-v05-") as directory:
    output = Path(directory) / "intersection.stl"
    hits = [
        offset for offset in range(49)
        if intersection_exists("position_interference", output, offset)
    ]
    route_hit = intersection_exists("route_interference", output)
    retainer_hit = intersection_exists("retainer_interference", output)

print("Sampled populated-PCB positions:", 49)
print("Rigid insertion collisions:", hits or "none")
print("Installed cable-route collision:", "yes" if route_hit else "none")
print("Installed retainer collision:", "yes" if retainer_hit else "none")

if hits or route_hit or retainer_hit:
    raise SystemExit(1)
