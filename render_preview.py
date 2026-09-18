"""Headless perspective renders for the v0.2 README.

Uses a small software z-buffer instead of a flat triangle projection, so
intersecting parts and the dark screen are occluded correctly without OpenGL.
"""

from pathlib import Path
import re
import struct

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parent
VERSION = "v0.2"
PARTS = [
    (f"archive/{VERSION}/minitel_body_{VERSION}.stl", np.array([0.73, 0.62, 0.45])),
    (f"archive/{VERSION}/minitel_front_{VERSION}.stl", np.array([0.86, 0.76, 0.59])),
    (f"archive/{VERSION}/minitel_screen_{VERSION}.stl", np.array([0.045, 0.16, 0.14])),
    (f"archive/{VERSION}/minitel_accent_{VERSION}.stl", np.array([0.08, 0.70, 0.39])),
]


def load_stl(path: Path) -> np.ndarray:
    data = path.read_bytes()
    if len(data) >= 84:
        count = struct.unpack_from("<I", data, 80)[0]
        if 84 + count * 50 == len(data):
            dtype = np.dtype([
                ("normal", "<f4", (3,)),
                ("vertices", "<f4", (3, 3)),
                ("attribute", "<u2"),
            ])
            return np.frombuffer(data, dtype=dtype, offset=84,
                                 count=count)["vertices"].astype(float)

    text = data.decode("ascii")
    rows = re.findall(
        r"^\s*vertex\s+([-+0-9.eE]+)\s+([-+0-9.eE]+)\s+([-+0-9.eE]+)",
        text,
        flags=re.MULTILINE,
    )
    vertices = np.asarray(rows, dtype=np.float64)
    return vertices.reshape((-1, 3, 3))


def box(x0, x1, y0, y1, z0, z1):
    p = np.array([
        [x0, y0, z0], [x1, y0, z0], [x1, y1, z0], [x0, y1, z0],
        [x0, y0, z1], [x1, y0, z1], [x1, y1, z1], [x0, y1, z1],
    ], dtype=float)
    faces = [
        (0, 2, 1), (0, 3, 2), (4, 5, 6), (4, 6, 7),
        (0, 1, 5), (0, 5, 4), (1, 2, 6), (1, 6, 5),
        (2, 3, 7), (2, 7, 6), (3, 0, 4), (3, 4, 7),
    ]
    return np.asarray([[p[a], p[b], p[c]] for a, b, c in faces])


def pcb_mockup(shift_x=0.0, front_y=13.2):
    """Simplified board envelope for explanatory, not dimensional, renders."""
    x = shift_x
    yf = front_y
    yb = front_y + 1.6
    objects = [
        (box(x-18.11, x+18.11, yf, yb, 6.0, 53.1), np.array([0.035, 0.055, 0.05])),
        # ESP32 module and antenna keep-out, on the front-facing board side.
        (box(x-16.0, x+2.0, yf-3.3, yf-0.05, 10.0, 32.5), np.array([0.54, 0.57, 0.55])),
        (box(x-16.0, x+2.0, yf-0.8, yf-0.05, 32.5, 41.5), np.array([0.025, 0.03, 0.03])),
        # USB-C shell projects from the board's right edge, but visibly stops
        # short of the v0.2 cabinet wall: this is the fit error seen in print.
        (box(x+17.2, x+24.1, yf-3.0, yf-0.1, 38.7, 46.2), np.array([0.64, 0.66, 0.65])),
        # Reset switch and JST connector.
        (box(x+15.3, x+18.7, yf-2.1, yf-0.1, 48.5, 52.0), np.array([0.82, 0.82, 0.76])),
        (box(x-5.0, x+5.0, yf-3.1, yf-0.1, 2.0, 7.3), np.array([0.92, 0.90, 0.78])),
        # Cable heading toward the bottom exit.
        (box(x-2.1, x+2.1, yf-2.2, yb-0.8, -1.0, 3.0), np.array([0.035, 0.035, 0.035])),
    ]
    return objects


def camera_basis(eye, target):
    eye = np.asarray(eye, dtype=float)
    target = np.asarray(target, dtype=float)
    forward = target - eye
    forward /= np.linalg.norm(forward)
    right = np.cross(forward, np.array([0.0, 0.0, 1.0]))
    right /= np.linalg.norm(right)
    up = np.cross(right, forward)
    return eye, right, up, forward


def rasterize(objects, output, eye, target, view_angle=31, size=(1200, 1000)):
    width, height = size
    scale = 1.35  # supersampling for clean small keys and cabinet ribs
    width_hi, height_hi = int(width * scale), int(height * scale)
    background = np.array([239, 235, 226], dtype=np.uint8)
    image = np.broadcast_to(background, (height_hi, width_hi, 3)).copy()
    zbuffer = np.full((height_hi, width_hi), np.inf, dtype=np.float64)
    eye, right, up, forward = camera_basis(eye, target)
    focal = 0.5 * height_hi / np.tan(np.deg2rad(view_angle) / 2)
    cx, cy = width_hi / 2, height_hi / 2
    light = np.array([-0.45, -0.62, 0.78])
    light /= np.linalg.norm(light)

    prepared = []
    for triangles, base_color in objects:
        normals = np.cross(triangles[:, 1] - triangles[:, 0], triangles[:, 2] - triangles[:, 0])
        normals /= np.maximum(np.linalg.norm(normals, axis=1)[:, None], 1e-12)
        intensity = 0.50 + 0.50 * np.clip(normals @ light, 0, 1)
        colors = np.clip(base_color[None, :] * intensity[:, None] * 255, 0, 255).astype(np.uint8)

        rel = triangles - eye
        cam_x = rel @ right
        cam_y = rel @ up
        cam_z = rel @ forward
        sx = cx + focal * cam_x / cam_z
        sy = cy - focal * cam_y / cam_z
        projected = np.stack([sx, sy, cam_z], axis=2)
        prepared.extend(zip(projected, colors))

    # Near triangles first is not required for a z-buffer, but reduces writes.
    prepared.sort(key=lambda item: item[0][:, 2].mean())
    for tri, color in prepared:
        if np.any(tri[:, 2] <= 0.1):
            continue
        min_x = max(0, int(np.floor(tri[:, 0].min())))
        max_x = min(width_hi - 1, int(np.ceil(tri[:, 0].max())))
        min_y = max(0, int(np.floor(tri[:, 1].min())))
        max_y = min(height_hi - 1, int(np.ceil(tri[:, 1].max())))
        if min_x > max_x or min_y > max_y:
            continue

        x0, y0 = tri[0, :2]
        x1, y1 = tri[1, :2]
        x2, y2 = tri[2, :2]
        denom = (y1 - y2) * (x0 - x2) + (x2 - x1) * (y0 - y2)
        if abs(denom) < 1e-8:
            continue
        xs = np.arange(min_x, max_x + 1, dtype=float)[None, :] + 0.5
        ys = np.arange(min_y, max_y + 1, dtype=float)[:, None] + 0.5
        a = ((y1 - y2) * (xs - x2) + (x2 - x1) * (ys - y2)) / denom
        b = ((y2 - y0) * (xs - x2) + (x0 - x2) * (ys - y2)) / denom
        c = 1.0 - a - b
        inside = (a >= -1e-7) & (b >= -1e-7) & (c >= -1e-7)
        if not inside.any():
            continue
        depth = a * tri[0, 2] + b * tri[1, 2] + c * tri[2, 2]
        current = zbuffer[min_y:max_y + 1, min_x:max_x + 1]
        visible = inside & (depth < current)
        current[visible] = depth[visible]
        image[min_y:max_y + 1, min_x:max_x + 1][visible] = color

    final = Image.fromarray(image).resize(size, Image.Resampling.LANCZOS)
    final.save(ROOT / output, optimize=True)


def printable_parts(include_front=True):
    selected = PARTS if include_front else PARTS[:1]
    return [(load_stl(ROOT / filename), color) for filename, color in selected]


def transform(triangles, matrix, offset):
    return triangles @ np.asarray(matrix, dtype=float).T + np.asarray(offset)


if __name__ == "__main__":
    rasterize(
        printable_parts(),
        f"archive/{VERSION}/preview-{VERSION}.png",
        eye=(118, -176, 103),
        target=(0, 2, 27),
    )
    rasterize(
        printable_parts(),
        f"archive/{VERSION}/preview-side-{VERSION}.png",
        eye=(174, -128, 130),
        target=(2, 8, 28),
    )
    rasterize(
        printable_parts(include_front=False) + pcb_mockup(),
        f"archive/{VERSION}/preview-mounting-{VERSION}.png",
        eye=(102, -168, 102),
        target=(0, 14, 27),
        view_angle=29,
    )

    # v0.3 reuses the body, but adds the orange carrier and shifts the board.
    carrier = load_stl(ROOT / "minitel_carrier_v0.3-test.stl")
    rasterize(
        printable_parts(include_front=False)
        + [(carrier, np.array([0.79, 0.35, 0.10]))]
        + pcb_mockup(shift_x=10.0, front_y=10.35),
        "preview-v0.3-compat.png",
        eye=(108, -174, 104),
        target=(4, 13, 28),
        view_angle=29,
    )

    # Close-up of the protruding reset cap in its assembled orientation.
    reset = load_stl(ROOT / "minitel_reset_plunger_v0.3-test.stl")
    reset = transform(
        reset,
        [[0, 0, -1], [0, 1, 0], [1, 0, 0]],
        [34.8, 11.7, 50.3],
    )
    rasterize(
        printable_parts(include_front=False)
        + [(reset, np.array([0.08, 0.70, 0.39]))],
        "preview-reset-v0.3.png",
        eye=(110, -62, 82),
        target=(31, 12, 48),
        view_angle=18,
        size=(1000, 800),
    )
