"""Render actual v0.3 meshes and Gerber-derived PCB (no invented components).
Run openscad -o pcb_reference.stl render_reference.scad first.
The PCB STL is a reference mesh only, not a printed part.
"""
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from render_preview import ROOT, load_stl, rasterize, transform

def mesh(name, color): return (load_stl(ROOT/name), np.array(color))

body=mesh('archive/v0.2/minitel_body_v0.2.stl',[.83,.76,.63])
lid=mesh('minitel_lid_v0.3-test.stl',[.89,.82,.69])
keyboard=mesh('minitel_keyboard_v0.3-test.stl',[.89,.82,.69])
carrier=mesh('minitel_carrier_v0.3-test.stl',[.88,.43,.13])
pcb=mesh('pcb_reference.stl',[.08,.16,.14])
screen=mesh('archive/v0.2/minitel_screen_v0.2.stl',[.035,.13,.115])
accent=mesh('archive/v0.2/minitel_accent_v0.2.stl',[.12,.68,.42])
reset=(transform(load_stl(ROOT/'minitel_reset_plunger_v0.3-test.stl'),[[0,0,-1],[0,1,0],[1,0,0]],[34.8,11.7,50.3]),np.array([.12,.68,.42]))

def caption(path,title,subtitle):
    img=Image.open(ROOT/path)
    d=ImageDraw.Draw(img)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    d.text((38,28),title,font=ImageFont.truetype(font,27),fill='#233731')
    d.text((38,66),subtitle,font=ImageFont.truetype(font,17),fill='#57665f')
    img.save(ROOT/path)

rasterize([body,lid,keyboard,carrier,pcb,reset,screen,accent],
          'preview-assembly-v0.3.png',eye=(118,-176,103),target=(0,2,27),size=(1400,1100))
caption('preview-assembly-v0.3.png','V0.3 / complete exterior','Actual meshes • retained v0.2 body + screen/accent inserts • fit unverified')
rasterize([carrier], 'preview-carrier-v0.3.png',eye=(89,-130,97),target=(6,12,30),view_angle=27,size=(1200,1050))
caption('preview-carrier-v0.3.png','V0.3 / current carrier','Actual STL • rectangular cradle • NOT yet adapted to the PCB outline')
rasterize([carrier,pcb], 'preview-carrier-pcb-v0.3.png',eye=(75,-150,98),target=(6,12,30),view_angle=26,size=(1200,1050))
caption('preview-carrier-pcb-v0.3.png','V0.3 / PCB contour check','Iodeo v2.2 Gerber outline + holes • components omitted • NOT a fit approval')
# Explode toward the viewer, so the outline and cradle can be compared.
exploded=(pcb[0]+np.array([0,-20,0]),pcb[1])
rasterize([carrier,exploded], 'preview-carrier-exploded-v0.3.png',eye=(105,-145,113),target=(6,0,30),view_angle=29,size=(1200,1050))
caption('preview-carrier-exploded-v0.3.png','V0.3 / exploded contour comparison','PCB moved 20 mm forward for visibility • original carrier unchanged')
