// EDITH V2.5 — 3D PRINT FIT KIT (experimental; units mm)
// Derived from EDITH V2.4 kernelCAD rev16. Nominal 52-22-144 mm sizing reference.
// NOT production eyewear, not prescription lenses, not an operational AR system.
// Use PETG for structural parts; optional TPU 95A for the nose-pad gauges.
// Two M2 screws and nuts are intended for hinge test; drill/ream fit after printing.
// Exploded layout for visual inspection; recenter/reorient each STL in slicer.
const shellColor={baseColor:'#172126',roughness:.32};
const lidColor={baseColor:'#354249',roughness:.36};
const tipColor={baseColor:'#a0aeb3',roughness:.72};
function printLens(side,k){const s=k;let p=path().moveTo(-23*s,21*s)
.bezierTo([-6*s,23*s],[12*s,23*s],[22*s,21.5*s])
.bezierTo([27*s,21*s],[30*s,17*s],[30*s,11*s])
.bezierTo([31*s,2*s],[31*s,-10*s],[27*s,-16*s])
.bezierTo([23*s,-22*s],[14*s,-23*s],[-10*s,-23*s])
.bezierTo([-21*s,-23*s],[-28*s,-21*s],[-30*s,-14*s])
.bezierTo([-31*s,-7*s],[-30*s,7*s],[-29*s,12*s])
.bezierTo([-29*s,18*s],[-27*s,20.5*s],[-23*s,21*s]).close();
return side<0?p.reflect('y'):p;}
function printRim(side,k,y,d){return printLens(side,k).extrude(d).rotate([1,0,0],90).translate(side*38,y,24);}
function printSection(w,h){const a=w/2,b=h/2,r=Math.min(w,h)/3;
return path().moveTo(-a+r,-b).lineTo(a-r,-b).quadraticTo([a,-b],[a,-b+r])
.lineTo(a,b-r).quadraticTo([a,b],[a-r,b]).lineTo(-a+r,b)
.quadraticTo([-a,b],[-a,b-r]).lineTo(-a,-b+r).quadraticTo([-a,-b],[-a+r,-b]).close();}
function printEar(s){let a=[[107,0,0,7.8,7.8],[113,0,-.3,7.5,7.4],[121,-.5*s,-1,6.3,6.2],
[132,-1.6*s,-3.4,5.6,5.6],[144,-3*s,-6.8,4.6,4.8],[151,-4.1*s,-9.2,3.8,4.2]];
return printSection(a[0][3],a[0][4]).loft(a.slice(1).map(t=>printSection(t[3],t[4])),{planes:a.map(t=>({plane:'XY',origin:[t[1],-t[2],t[0]]})),ruled:false}).rotate([1,0,0],-90).translate(s*69,0,37);}

const A=assembly('EDITH V2.5 — FDM fit-test kit');
function piece(name,shape,dx=0,dy=0){A.part(name,shape.translate(dx,dy,0),{material:'petg'});}
let F=printRim(-1,1,0,4.6).subtract(printRim(-1,.875,.8,6.3))
 .union(printRim(1,1,0,4.6).subtract(printRim(1,.875,.8,6.3)))
 .union(box(25,3.2,2.7).translate(-12.5,-3.2,43))
 .union(box(25,3,2.3).translate(-12.5,-3,38.3));
for(const s of [-1,1]){
 const x=s*69;
 // Twin front knuckles, 2.45 mm thick, with a 2.95 mm center gap.
 F=F.union(box(7.4,6.2,7.85).fillet(.45).translate(x-3.7,-1,33.7))
 .union(box(7.4,9.8,2.45).fillet(.35).translate(x-3.7,4.7,33.7))
 .union(box(7.4,9.8,2.45).fillet(.35).translate(x-3.7,4.7,39.1));
 // Vertical M2 pilot clearance Ø2.4 mm at x=±69,y=10.5.
 F=F.subtract(cylinder(10,1.2).translate(x,10.5,33.0));
}
piece('front-frame',F);
for(const s of [-1,1]){
 const id=s<0?'left':'right',x=s*69;
 // Hollow pod shells; inner spaces are placeholders until real boards/cells chosen.
 const M=box(12.6,59,11.6).fillet(2)
  .subtract(box(10.1,56.2,12).translate(1.25,1.4,1.25)).translate(x-6.3,19,32.4);
 const B=box(11.6,32,9.6).fillet(1.8)
  .subtract(box(9.1,29.3,10).translate(1.25,1.35,1.2)).translate(x-5.8,78,32);
 // Single center tongue, 2.25 mm thick, leaves ~0.35 mm each side of knuckles.
 const tongue=box(7,17.2,2.25).fillet(.35).translate(x-3.5,5.8,36.5)
  .subtract(cylinder(4,1.2).translate(x,10.5,35.5));
 piece(id+'-temple-shell',M.union(B).union(printEar(s)).union(tongue),s<0?-170:170,18);
 // These covers are fit gauges only: attach temporarily with tape.
 piece(id+'-electronics-cover',box(11.2,55.5,1.25).fillet(.35).translate(x-5.6,20.6,44.4),s<0?-170:170,165);
 piece(id+'-battery-cover',box(10.2,28.3,1.25).fillet(.35).translate(x-5.1,79.8,42),s<0?-170:170,220);
 piece(id+'-nose-pad-TPU-gauge',extrudeRoundedRect(6.8,11,3.25,1.75),s<0?-50:50,280);
}
return A.solvedModel({}, {ignore:[]});