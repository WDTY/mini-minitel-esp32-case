"""Extract iodeo v2.2 Gerber outline; no image-derived dimensions.
Usage: python tools/build_pcb_reference.py path/to/Gerber_minitel_esp32_v2.2.zip
The small endpoint tolerance joins slightly discontinuous Gerber exports.
"""
import math
import re
import sys
import zipfile
from pathlib import Path

def extract(path):
    with zipfile.ZipFile(path) as z:
        outline = z.read('Gerber_BoardOutline.GKO').decode()
        drill = z.read('Gerber_Drill_NPTH.DRL').decode()
    segments = []
    current = None
    mode = 'G01'
    for line in outline.splitlines():
        if line in ('G01*', 'G02*', 'G03*'):
            mode = line[:3]
        m = re.fullmatch(r'X(-?\d+)Y(-?\d+)(?:I(-?\d+)J(-?\d+))?D0([12])\*', line)
        if not m:
            continue
        x, y, i, j, d = m.groups()
        end = (int(x)*25.4e-6, int(y)*25.4e-6)
        if d == '1':
            points = [current, end]
            if i is not None:
                center = (current[0]+int(i)*25.4e-6, current[1]+int(j)*25.4e-6)
                a = math.atan2(current[1]-center[1], current[0]-center[0])
                b = math.atan2(end[1]-center[1], end[0]-center[0])
                sweep = (b-a) % (2*math.pi) if mode=='G03' else -((a-b)%(2*math.pi))
                radius = math.dist(current,center)
                steps = max(3, math.ceil(abs(sweep)*radius/0.08))
                points = [current]+[(center[0]+radius*math.cos(a+sweep*k/steps), center[1]+radius*math.sin(a+sweep*k/steps)) for k in range(1,steps)]+[end]
            segments.append(points)
        current = end
    loops = []
    while segments:
        loop = segments.pop(0)
        while math.dist(loop[-1],loop[0])>0.025:
            choices = [(math.dist(loop[-1],s[e]),k,e) for k,s in enumerate(segments) for e in (0,-1)]
            dist,k,e = min(choices)
            if dist>0.025:
                raise ValueError(f'Unclosed outline: gap {dist:.4f} mm')
            seg = segments.pop(k)
            if e==-1:
                seg = seg[::-1]
            loop.extend(seg[1:])
        loops.append(loop[:-1])
    def area(p):
        return abs(sum(a[0]*b[1]-b[0]*a[1] for a,b in zip(p,p[1:]+p[:1]))/2)
    loops.sort(key=area,reverse=True)
    xs=[p[0] for p in loops[0]]; ys=[p[1] for p in loops[0]]
    xmin,xmax,ymin,ymax=min(xs),max(xs),min(ys),max(ys)
    # USB edge faces enclosure right, antenna down, JST wing left.
    def mapped(p): return [round((ymin+ymax)/2-p[1],5),round(xmax-p[0],5)]
    holes=[]
    active=False
    for line in drill.splitlines():
        if line.startswith('T') and 'C' not in line:
            active=line=='T04'
        m=re.fullmatch(r'X(\d+)Y(\d+)',line)
        if active and m:
            holes.append(mapped([int(m[1])*0.00254,int(m[2])*0.00254]))
    result='// Derived from iodeo/Minitel-ESP32 hardware Gerber v2.2, CC BY-SA 4.0.\n'
    result+='// Source commit 39c49b8462b46dfb7da84c08aecdd48e5c52a224.\n'
    result+='// Arc sampling <=0.08 mm, endpoint join tolerance 0.025 mm.\n'
    result+='// Board thickness assumed 1.60 mm; component heights not defined.\n'
    result+=f'pcb_reference_holes = {holes};\n'
    result+='module pcb_reference_outline_2d() {\n'
    result+='polygon('+str([mapped(p) for p in loops[0]])+');\n}\n'
    result+='module pcb_reference_2d() { difference() {\n'
    result+='pcb_reference_outline_2d();\n'
    for loop in loops[1:]: result+='polygon('+str([mapped(p) for p in loop])+');\n'
    result+='for(p=pcb_reference_holes) translate(p) circle(d=1.143, $fn=32);\n}}\n'
    result+='module pcb_reference(x=10, y=10.40, z=6) { translate([x,y,z]) rotate([90,0,0]) linear_extrude(height=1.6) pcb_reference_2d(); }\n'
    root = Path(__file__).resolve().parents[1]
    (root / 'src' / 'pcb_reference.scad').write_text(result)
    print(f'Outline: {ymax-ymin:.3f} wide x {xmax-xmin:.3f} high mm; {len(loops)-1} internal cutouts; {len(holes)} mounting holes')

if __name__=='__main__': extract(sys.argv[1])
