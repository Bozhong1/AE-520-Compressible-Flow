"""Generate the compact HW3 Problem 1 h-s figure from its verified equations.

Dependencies: reportlab and Poppler's pdftoppm (on PATH, or --pdftoppm PATH).
Run from any directory: python make_hs_figure.py
Output: ../figures/HW3_Problem1_hs.pdf and HW3_Problem1_hs.png (200 dpi).
"""
from __future__ import annotations
import argparse
import math
from pathlib import Path
import shutil
import subprocess
from reportlab.pdfgen import canvas
from reportlab.lib.colors import Color, white, black
from verify_hw3 import solve, CP, R, GAMMA, tau


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pdftoppm',default=shutil.which('pdftoppm'))
    args = parser.parse_args()
    if not args.pdftoppm:
        parser.error('pdftoppm must be on PATH or supplied with --pdftoppm.')
    values = solve()['P1']
    out = Path(__file__).resolve().parents[1]/'figures'
    out.mkdir(exist_ok=True)
    pdf = out/'HW3_Problem1_hs.pdf'
    c = canvas.Canvas(str(pdf),pagesize=(468,252))
    c.setTitle('HW3 Problem 1: three routes to a sonic state')
    c.setAuthor('Boyang Chen')
    left,bottom,width,height = 55,38,402,200
    xmin,xmax,ymin,ymax = -70,1540,200,1100
    def point(s,h):
        return left+(s-xmin)/(xmax-xmin)*width,bottom+(h-ymin)/(ymax-ymin)*height
    def segment(coords,color,lw=1.2):
        p=c.beginPath(); p.moveTo(*point(*coords[0]))
        for xy in coords[1:]: p.lineTo(*point(*xy))
        c.setStrokeColor(color);c.setLineWidth(lw);c.drawPath(p)
    def arrow(start,end,color):
        x0,y0=point(*start);x1,y1=point(*end)
        c.setStrokeColor(color);c.setFillColor(color);c.setLineWidth(1)
        c.line(x0,y0,x1,y1)
        angle=math.atan2(y1-y0,x1-x0); length=4; half=1.7
        bx=x1-length*math.cos(angle);by=y1-length*math.sin(angle)
        p=c.beginPath();p.moveTo(x1,y1)
        p.lineTo(bx-half*math.sin(angle),by+half*math.cos(angle))
        p.lineTo(bx+half*math.sin(angle),by-half*math.cos(angle));p.close()
        c.drawPath(p,fill=1,stroke=0)
    def text(s,h,label,align='left',size=8.5):
        x,y=point(s,h);c.setFillColor(black);c.setFont('Helvetica',size)
        {'left':c.drawString,'right':c.drawRightString,'center':c.drawCentredString}[align](x,y,label)
    c.setFont('Helvetica',8)
    for s in (0,250,500,750,1000,1250,1500):
        x,_=point(s,ymin);c.setStrokeColor(Color(.87,.89,.90));c.setLineWidth(.35)
        c.line(x,bottom,x,bottom+height);c.setFillColor(black)
        c.drawCentredString(x,bottom-12,str(s))
    for h in (200,400,600,800,1000):
        _,y=point(xmin,h);c.setStrokeColor(Color(.87,.89,.90));c.setLineWidth(.35)
        c.line(left,y,left+width,y);c.setFillColor(black)
        c.drawRightString(left-7,y-3,str(h))
    c.setStrokeColor(black);c.setLineWidth(.6);c.rect(left,bottom,width,height)
    c.setFont('Helvetica',9);c.setFillColor(black)
    # Explicit label and units avoid any unsupported math font glyphs.
    c.drawCentredString(left+width/2,10,'Delta s = s - s1  (J/(kg K))')
    c.saveState();c.translate(13,bottom+height/2);c.rotate(90)
    c.drawCentredString(0,0,'h (kJ/kg)');c.restoreState()
    colors=[Color(.75,.20,.14),Color(.08,.38,.66),Color(.17,.48,.28)]
    curves=[[],[],[]]
    m1,t1,p1=.25,300.,100000.;t01=303.75
    for i in range(1001):
        m=m1+(1-m1)*i/1000
        pr=p1*(1+GAMMA*m1*m1)/(1+GAMMA*m*m)
        tr=t1*(m/m1)**2*((1+GAMMA*m1*m1)/(1+GAMMA*m*m))**2
        tf=t01/tau(m);pf=p1*m1/m*math.sqrt(tf/t1)
        curves[0].append((CP*math.log(tr/t1)-R*math.log(pr/p1),CP*tr/1000))
        curves[1].append((CP*math.log(tf/t1)-R*math.log(pf/p1),CP*tf/1000))
        curves[2].append((0,CP*tf/1000))
    for line,color in zip(curves,colors):segment(line,color)
    for i in (230,620):arrow(curves[0][i],curves[0][i+25],colors[0])
    arrow(curves[1][260],curves[1][340],colors[1]);arrow((0,288),(0,272),colors[2])
    for key in ('initial','rayleigh','fanno','isentropic'):
        row=values[key];x,y=point(row['ds'],row['h']/1000)
        c.setFillColor(white);c.setStrokeColor(black);c.setLineWidth(.8);c.circle(x,y,2.3,fill=1)
    text(32,333,'I');text(1450,965,'R');text(285,252,'F');text(-18,226,'S','right')
    mx=values['rayleigh_max_h'];x,y=point(mx['ds'],mx['h']/1000)
    c.setStrokeColor(colors[0]);c.setFillColor(white);c.rect(x-2,y-2,4,4,fill=1)
    text(1365,1052,'Tmax','right',8)
    for index,(label,color) in enumerate(zip(('Rayleigh','Fanno','Isentropic'),colors)):
        x=left+13;y=bottom+height-17-index*14
        c.setStrokeColor(color);c.setLineWidth(1.4);c.line(x,y,x+25,y)
        c.setFillColor(black);c.setFont('Helvetica',8.5);c.drawString(x+32,y-3,label)
    c.showPage();c.save()
    subprocess.run([args.pdftoppm,'-r','200','-png','-singlefile',str(pdf),str(pdf.with_suffix(''))],check=True)
    print('Created',pdf)
    print('Created',pdf.with_suffix('.png'))


if __name__=='__main__':
    main()
