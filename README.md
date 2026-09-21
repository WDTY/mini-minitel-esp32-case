# Mini Minitel ESP32 case

<img src="assets/project-avatar.png" alt="Mini Minitel project avatar" width="180">

A printable Minitel-shaped enclosure for the
[iodeo ESP Minitel V2](https://github.com/iodeo/Minitel-ESP32) JST cable-to-DIN board.

## Latest: complete three-part v0.5

v0.5 is the complete avatar-inspired miniature Minitel. It prints as three
parts: a hollow cabinet, a separate multicolour keyboard and one removable
ESP32 bay. The external design uses no geometry from the iodeo electronics
enclosure.

Connect JST first, slide the PCB into the bay's edge guides, form the measured
60 mm cable turn and slide the loaded bay into the lower rear of the Minitel.
USB-C and the protruding flexible RESET pad remain accessible at the back. The
DIN plug lays into an open-top notch and never passes through a printed hole.

- [Complete Minitel case STL](stl/v0.5/minitel_case_v0.5.stl)
- [Separate multicolour keyboard STL](stl/v0.5/minitel_keyboard_v0.5.stl)
- [Removable ESP32 bay STL](stl/v0.5/minitel_esp32_bay_v0.5.stl)
- [Dimensions, assembly route, K2 settings and multicolour guide](docs/V0.5-DESIGN.md)
- [Editable OpenSCAD source](src/minitel_v05.scad)

The case is already exported flat on its rear. This puts the dark CRT and
green prompt/cursor/lens in the final bounded layers. The keyboard is a
separate flat-bottomed print, so its grey keys and green Enter key do not cause
colour changes throughout the much larger cabinet print.

![Complete multicolour v0.5 assembly](assets/renders/v0.5/complete-assembly-v0.5.png)
![Separate keyboard and four locating tongues](assets/renders/v0.5/keyboard-exploded-v0.5.png)
![Hollow cabinet, bay guides and print bridge ribs](assets/renders/v0.5/hollow-case-cutaway-v0.5.png)
![Loaded bay behind the lower rear opening](assets/renders/v0.5/rear-bay-exploded-v0.5.png)
![ESP32, connected cable and U-turn in the bay](assets/renders/v0.5/loaded-bay-v0.5.png)
![U-rails, front bridge and PCB retention latch](assets/renders/v0.5/bay-mechanics-v0.5.png)

All three parts contain an enclosed `WDTY v0.5` watermark spanning three 0.20 mm
layers. This remains a mechanical prototype, not a fit-verified release.
The cabinet is a real hollow shell rather than a solid infill volume. Thin
U-guides locate the bay and three permanent 1.2 mm bridge ribs reduce the
rear-down front-wall bridge to 24 mm. The CRT backing overlaps the cabinet by
3.2 mm, so it is one continuous structure without the former visible slit.
The revised bay has a
releasable PCB latch, a positive flange shoulder and open guides for the
measured 4.3 mm cable. Those guides are not hard strain relief. Physical
connector positions, latch force and RESET travel still need verification.
See the mechanical audit before printing: a collision-free reference model
alone does not prove physical fit.

## Rejected v0.4 donor-cassette prototype

The official iodeo cassette sits horizontally at the bottom, with its original
end cap at the lower rear. The fixed Minitel front and keyboard form one body.
This requires a new body print; it is not an upgrade for the printed v0.2 body.

> [!WARNING]
> **Superseded after physical testing.** The donor cassette is for another board
> configuration and is too narrow, shallow and low for this populated JST
> board. Keep these files for design history; do not print them for this board.

- [Assembly STL for inspection](archive/v0.4/stl/minitel_assembly_v0.4-review.stl)
- [Body STL](archive/v0.4/stl/minitel_body_v0.4-review.stl)
- [Original cap, positioned at rear](archive/v0.4/stl/minitel_cover_v0.4-review.stl)
- [Design, validation results and rebuild commands](archive/v0.4/V0.4-PROTOTYPE.md)
- [Editable OpenSCAD source](archive/v0.4/src/minitel_v04.scad)

Actual exported meshes; cap shown 14 mm rearward in the second view.

![v0.4 front-right view](archive/v0.4/renders/front-review.png)
![v0.4 lower rear opening and exploded cap](archive/v0.4/renders/rear-review.png)

## Historical v0.3 test

The experimental parts aim to reuse an already printed v0.2 body: a separate
PCB carrier, inset lid, removable keyboard and protruding reset plunger.
See [design and test notes](archive/v0.3/V0.3-COMPAT-DESIGN.md).

For a v0.3 carrier fit test, print
[`archive/v0.3/stl/minitel_carrier_v0.3-test.stl`](archive/v0.3/stl/minitel_carrier_v0.3-test.stl)
only. Keep the already printed v0.2 body.

> [!WARNING]
> Physical fit is not verified yet. The PCB in the renders uses the exact v2.2
> Gerber outline, cut-outs and mounting holes, but omits electronic components.
> USB-C clearance, reset operation and clip force still need checking on the
> real board. Keep the existing v0.2 body and do not force any snap feature.

## Assembly and carrier renders

Actual v0.3 meshes, viewed from the front-right. The complete exterior includes
the retained v0.2 body and its screen/accent inserts. Electronic components are
omitted, so the USB opening and reset cap still need a physical alignment test.

![Complete v0.3 exterior assembly](archive/v0.3/renders/preview-assembly-v0.3.png)

The replacement carrier follows the routed PCB perimeter and uses all five
Gerber mounting holes as locating points. The four round sockets fit the
unchanged v0.2 body pins. Two compliant hooks retain the top and bottom board
edges; the right edge remains clear for USB-C and RESET.

![Gerber-matched v0.3 carrier alone](archive/v0.3/renders/preview-carrier-v0.3.png)

The seated and exploded views use the outline, four internal cutouts and five
mounting holes extracted from iodeo's v2.2 Gerbers. They match the characteristic
shape in the
[upstream 3D view](https://github.com/iodeo/Minitel-ESP32/blob/39c49b8462b46dfb7da84c08aecdd48e5c52a224/hardware/ESP%20Minitel%20Devboard%20-%203d%20view.png).
It is a bare-board geometric reference, not a complete electronic assembly.

![Gerber-derived PCB seated in the replacement carrier](archive/v0.3/renders/preview-carrier-pcb-v0.3.png)

With the lid removed, the carrier and bare-board reference sit inside the
unchanged v0.2 body as follows:

![Replacement carrier and PCB inside the retained v0.2 body](archive/v0.3/renders/preview-v0.3-compat.png)

![Exploded carrier and Gerber-derived PCB comparison](archive/v0.3/renders/preview-carrier-exploded-v0.3.png)

See [reference provenance and limitations](docs/PCB-REFERENCE.md). The previous
rectangular-cradle content of `preview-v0.3-compat.png` was replaced when this
unprinted v0.3 design was revised.

## Repository layout

- [`src/`](src/): editable OpenSCAD sources.
- [`stl/v0.5/`](stl/v0.5/): the three current printable parts.
- [`docs/`](docs/): design notes and PCB-reference provenance.
- [`assets/renders/`](assets/renders/): current CAD renders.
- [`assets/photos/`](assets/photos/): owner-supplied hardware photographs.
- [`reference/`](reference/): PCB inspection mesh and unchanged iodeo donor STLs.
- [`tools/`](tools/): Gerber extraction and software-render scripts.
- [`archive/`](archive/): superseded versions and development fixtures.

## Older versions

- [v0.1](archive/v0.1/): first prototype STLs and previews.
- [v0.2](archive/v0.2/): historical STLs, previews, source and documentation.
  The physical fit test exposed mounting problems; this is not a verified release.
- [v0.3](archive/v0.3/): attempted v0.2-compatible carrier and lid.
- [v0.4](archive/v0.4/): rejected donor-cassette prototype for another board layout.

The v0.3 source imports `archive/v0.2/minitel_esp32_case.scad`.
Keep that directory when downloading the project. Archiving does not change
the geometry or the already printed v0.2 body.

## Editing and exporting

Open [`src/minitel_v05.scad`](src/minitel_v05.scad) in OpenSCAD and select
`case`, `keyboard`, `bay`, `case_assembly` or `assembly` with the `part`
parameter. See the v0.5 design notes for reproducible export, render and
clearance-check commands.

## Attribution and license

Hardware reference: [Louis H./iodeo](https://github.com/iodeo/Minitel-ESP32)
and [Hackaday project](https://hackaday.io/project/180473-minitel-esp32).
This derivative case is licensed under [CC BY-SA 4.0](LICENSE).
Contributions and measured fit reports are welcome.
