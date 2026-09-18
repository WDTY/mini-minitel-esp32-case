# PCB reference used for v0.3 renders

Source: iodeo/Minitel-ESP32 commit
`39c49b8462b46dfb7da84c08aecdd48e5c52a224`,
[`hardware/Gerber_minitel_esp32_v2.2.zip`](https://github.com/iodeo/Minitel-ESP32/blob/39c49b8462b46dfb7da84c08aecdd48e5c52a224/hardware/Gerber_minitel_esp32_v2.2.zip).
Attribution: Louis H./iodeo, CC BY-SA 4.0.

`build_pcb_reference.py` reads BoardOutline.GKO and the T04 mounting holes in
Drill_NPTH.DRL. It preserves the outer contour and four internal cutouts.
Circular arcs are sampled at at most 0.08 mm along the arc; exported endpoints
are joined within 0.025 mm. This is a sampled CAD reference, not an exact solid
model of the populated board. Gerber extents: 36.220 x 47.105 mm in the chosen
orientation; five nominal 1.143 mm mounting holes. PCB thickness is assumed 1.60 mm.

The orientation is chosen with the connector wing left, the antenna end down
and the USB/reset edge right, based on the upstream 3D view. Position uses the
existing carrier parameters: x shift 10 mm, bottom z=6 mm, PCB y=10.35..11.95 mm.
This placement is an inspection hypothesis, not a measured physical fit.

## Findings

The previous rectangular PCB proxy hid the narrow lower section and sloping
shoulders. The existing carrier's lower left clip has no corresponding board
edge, and its upper latch does not meet the board's top edge. The carrier needs
a mechanical revision; these renders do not constitute that revision.

Components, solder joints, connector bodies, cable bending space and button
travel are not reconstructed here. USB-C plug reach and reset operation remain
unverified. The reference also needs dimensional comparison against the owner's
physical JST-equipped board before claiming compatibility.

The complete exterior uses the actual current body/lid/keyboard/reset meshes
and the archived v0.2 screen/accent inserts. No printable geometry was changed.

## Reproduce

Requires Python with NumPy/Pillow, OpenSCAD, and DejaVu Sans for image captions.

```sh
python build_pcb_reference.py /path/to/Gerber_minitel_esp32_v2.2.zip
openscad -o pcb_reference.stl --export-format binstl render_reference.scad
python render_v03_readme.py
```

The exploded view moves the board 20 mm forward only for visibility. All images
are software renders of meshes, not generated concept illustrations.
