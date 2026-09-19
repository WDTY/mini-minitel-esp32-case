"""Render the actual review STLs and check their edge topology."""
from collections import Counter
import numpy as np
from render_preview import ROOT, load_stl, rasterize

parts = {}
for part in ['body', 'cover', 'assembly']:
    p = ROOT / f'stl/v0.4/minitel_{part}_v0.4-review.stl'
    mesh = load_stl(p)
    parts[part] = mesh
    edges = Counter()
    adj = {}
    for tri in mesh:
        verts = [tuple(v) for v in tri]
        for a, b in zip(verts, verts[1:] + verts[:1]):
            edges[tuple(sorted((a, b)))] += 1
            adj.setdefault(a, set()).add(b)
            adj.setdefault(b, set()).add(a)
    remaining = set(adj)
    components = 0
    while remaining:
        components += 1
        stack = [remaining.pop()]
        while stack:
            for n in adj[stack.pop()]:
                if n in remaining:
                    remaining.remove(n)
                    stack.append(n)
    invalid = sum(n != 2 for n in edges.values())
    print(part, 'triangles', len(mesh), 'nonmanifold_edges', invalid,
          'connected_components', components,
          'bounds', mesh.min(axis=(0,1)), mesh.max(axis=(0,1)))
    assert invalid == 0
    if part in ('body','cover'):
        assert components == 1

objects = [(parts['body'], np.array([.85,.77,.64])),
           (parts['cover'], np.array([.12,.65,.43])),
           (load_stl(ROOT/'archive/v0.2/minitel_screen_v0.2.stl'),np.array([.025,.12,.115])),
           (load_stl(ROOT/'archive/v0.2/minitel_accent_v0.2.stl'),np.array([.1,.7,.4]))]
rasterize(objects, 'assets/renders/v0.4/front-review.png',
          eye=(122,-176,105),target=(0,0,27),size=(1200,1000))
# Exploded cap, 14 mm outwards, to show the actual service opening.
objects[1]=(parts['cover']+np.array([0,14,0]),np.array([.12,.65,.43]))
rasterize(objects, 'assets/renders/v0.4/rear-review.png',
          eye=(118,200,115),target=(0,28,23),size=(1200,1000))
