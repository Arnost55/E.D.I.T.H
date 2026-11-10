// E.D.I.T.H. V2.4 — ergonomic mechanical prototype / acetate luxury eyewear concept
// Nominal 52-22-144 mm reference. Concept CAD only; dimensions of AR2 electronics not verified.
const lensCenterX=38,lensCenterZ=24,templeLength=144;
const acetate={baseColor:'#10171a',metalness:0.07,roughness:0.23,clearcoat:0.90,clearcoatRoughness:0.12,ior:1.52};
const metal={baseColor:'#c2cbd0',metalness:0.91,roughness:0.28,anisotropy:0.66,anisotropyRotation:90};
const blue={baseColor:'#c8d9e8',transmission:0.86,ior:1.51,thickness:1.6,attenuationColor:'#849eb9',attenuationDistance:12,roughness:0.035};
const padMat={baseColor:'#d4d7da',transmission:0.48,ior:1.42,thickness:1.0,roughness:0.3};
const camera={baseColor:'#070b15',metalness:0.3,roughness:0.11,clearcoat:0.9};
const darkMetal={baseColor:'#44535a',metalness:0.85,roughness:0.29,anisotropy:0.4};
const satinTitanium={baseColor:'#536168',metalness:0.87,roughness:0.28,anisotropy:0.55};
const brightEdge={baseColor:'#c5cdd1',metalness:0.94,roughness:0.26,anisotropy:0.65};
const smokedBezel={baseColor:'#29353a',metalness:0.68,roughness:0.3};
const assemblyModel=assembly('E.D.I.T.H. high-fidelity eyewear');
const names=[]; function add(name,shape,metalPart=false){assemblyModel.part(name,shape,{material:metalPart?'aluminum-6061':'abs'});names.push(name);}
function lensProfile(k,side){
 const s=k;
 let p=path().moveTo(-23*s,21*s)
 .bezierTo([-6*s,23*s],[12*s,23*s],[22*s,21.5*s])
 .bezierTo([27*s,21*s],[30*s,17*s],[30*s,11*s])
 .bezierTo([31*s,2*s],[31*s,-10*s],[27*s,-16*s])
 .bezierTo([23*s,-22*s],[14*s,-23*s],[-10*s,-23*s])
 .bezierTo([-21*s,-23*s],[-28*s,-21*s],[-30*s,-14*s])
 .bezierTo([-31*s,-7*s],[-30*s,7*s],[-29*s,12*s])
 .bezierTo([-29*s,18*s],[-27*s,20.5*s],[-23*s,21*s]).close();
 return side<0?p.reflect('y'):p;
}
function frontal(k,side,y,depth){
 return lensProfile(k,side).extrude(depth).rotate([1,0,0],90).translate(side*lensCenterX,y,lensCenterZ);
}

/** Flexible over-ear section. Swept cross sections taper and bend
 * inward and downward past the top of the ear.
 * Indicative fit for average adult; sizing is adjustable only after measurement.
 * The narrow part starts under the rear enclosure lip at Y=107.
 */
function roundedTempleSection(w,h){
 const a=w/2,b=h/2,r=Math.min(w,h)/3;
 return path().moveTo(-a+r,-b).lineTo(a-r,-b)
  .quadraticTo([a,-b],[a,-b+r]).lineTo(a,b-r)
  .quadraticTo([a,b],[a-r,b]).lineTo(-a+r,b)
  .quadraticTo([-a,b],[-a,b-r]).lineTo(-a,-b+r)
  .quadraticTo([-a,-b],[-a+r,-b]).close();
}
// V2.3 fixes overlapping loft surfaces: metal arm ends where silicone grip begins.
function overEarTemple(side){
 const sections=[[107,0,0,7.8,7.8],[113,0,-0.3,7.5,7.4],
 [121,-0.5*side,-1.0,6.3,6.2],[131,-1.5*side,-3.3,5.8,5.9]];
 return roundedTempleSection(sections[0][3],sections[0][4])
 .loft(sections.slice(1).map(s=>roundedTempleSection(s[3],s[4])),{
 planes:sections.map(s=>({plane:'XY',origin:[s[1],-s[2],s[0]]})),ruled:true
 }).rotate([1,0,0],-90).translate(side*69,0,37);
}
function softEarTip(side){
 const sections=[[131,-1.5*side,-3.3,5.8,5.9],
 [138,-2.35*side,-5.0,5.5,5.65],[144,-3.0*side,-6.8,4.6,4.8],
 [149,-3.9*side,-8.7,4.1,4.5],[152,-4.2*side,-9.5,3.8,4.2]];
 return roundedTempleSection(sections[0][3],sections[0][4])
 .loft(sections.slice(1).map(s=>roundedTempleSection(s[3],s[4])),{
 planes:sections.map(s=>({plane:'XY',origin:[s[1],-s[2],s[0]]})),ruled:true
 }).rotate([1,0,0],-90).translate(side*69,0,37);
}

/* V2 independently adjustable nose pads: values tune the hand-fitted metal arms
   and ball-swivel silicone pad geometry. Actual retention remains unverified. */
const leftPadSpreadMm=param('leftPadSpreadMm',0,{min:-1.5,max:1.5});
const rightPadSpreadMm=param('rightPadSpreadMm',0,{min:-1.5,max:1.5});
const leftPadHeightMm=param('leftPadHeightMm',0,{min:-1.8,max:1.8});
const rightPadHeightMm=param('rightPadHeightMm',0,{min:-1.8,max:1.8});
const leftPadTiltDeg=param('leftPadTiltDeg',0,{min:-17,max:17});
const rightPadTiltDeg=param('rightPadTiltDeg',0,{min:-17,max:17});
const leftPadDepthMm=param('leftPadDepthMm',0,{min:-0.8,max:0.8});
const rightPadDepthMm=param('rightPadDepthMm',0,{min:-0.8,max:0.8});
const siliconeMat={baseColor:'#e0e8e8',metalness:0.02,roughness:0.38,transmission:0.36,ior:1.43,thickness:1.3};
const noseArmMetal={baseColor:'#a3b0ba',metalness:0.9,roughness:0.19};
const noseSocketMat={baseColor:'#97a5ae',metalness:0.79,roughness:0.22};

for(const side of [-1,1]){
 const id=side<0?'left':'right';
 const rim=frontal(1,side,0,4.6).subtract(frontal(0.875,side,0.8,6.3)).material(acetate);
 add('black-acetate-rim-'+id,rim);
 const outerMetal=frontal(1.022,side,-0.32,0.75).subtract(frontal(1.003,side,0.4,1.8)).material(metal);
 add('palladium-perimeter-inlay-'+id,outerMetal,true);
 const lens=frontal(0.866,side,-1.32,1.65).material(blue);
 add('blue-silver-glass-'+id,lens);
 const hX=side*69;
 const hinge=box(4.6,9.0,4.6).fillet(0.9).translate(hX-2.3,-1.0,35.2).material(metal);
 add('precision-hinge-'+id,hinge,true);
 // Two visually continuous segments replace the problematic exposed spine:
 // short front hinge link, then flexible curved over-ear rear segment.
 const yoke=box(4.3,14.8,3.5).fillet(1.0).translate(hX-2.15,5.3,35.8).material(metal);
 add('short-metal-hinge-yoke-'+id,yoke,true);
 const earArm=overEarTemple(side).material(satinTitanium);
 add('slim-bent-over-ear-temple-'+id,earArm,true);
 const tip=softEarTip(side).material({baseColor:'#1c232a',roughness:0.57,metalness:0.0});
 add('soft-over-ear-grip-'+id,tip);


 const cam=cylinder(0.95,1.48).rotate([1,0,0],90).translate(side*67.4,-5.10,39.3).material(camera);
 add('forward-vision-camera-'+id,cam);

 const mountX=side*9.9,mountY=0.1,mountZ=22.4;
 add('v20-nose-pad-base-'+id,sphere(1.15).translate(mountX,mountY,mountZ).material(noseArmMetal),true);
 const wireRail=[[0,0,0],[0,0,0.9],[side*0.5,1.3,1.4],
 [side*1.05,3.5,-0.25],[side*1.5,5.2,-3.1]];
 add('v20-bendable-S-curve-wire-'+id,
 path().circle(0,0,0.48).sweep(wireRail,{spine:'smooth'})
 .translate(mountX,mountY,mountZ).material(noseArmMetal),true);
 const spread=side<0?leftPadSpreadMm:rightPadSpreadMm;
 const rise=side<0?leftPadHeightMm:rightPadHeightMm;
 const tilt=side<0?leftPadTiltDeg:rightPadTiltDeg;
 const depth=side<0?leftPadDepthMm:rightPadDepthMm;
 const padX=spread.multiply(side).add(side*11.4),padY=depth.add(6.8),padZ=rise.add(19.3);
 add('v20-swivel-ball-'+id,sphere(1.15).translate(padX,depth.add(5.35),padZ).material(noseArmMetal),true);
 add('v20-swivel-backing-'+id,extrudeRoundedRect(5.2,8.6,2.4,0.7)
 .rotate([0,0,1],tilt).rotate([1,0,0],90).translate(padX,depth.add(6.0),padZ).material(noseSocketMat),true);
 add('v20-oval-silicone-nose-pad-'+id,extrudeRoundedRect(6.8,11.0,3.25,1.65)
 .rotate([0,0,1],tilt).rotate([1,0,0],90).translate(padX,padY,padZ).material(siliconeMat));

}
const bridgeTop=path().moveTo(-12.25,43.6).bezierTo([-7.4,44.25],[7.4,44.25],[12.25,43.6])
 .lineTo(12.25,42.75).bezierTo([7.4,43.45],[-7.4,43.45],[-12.25,42.75]).close()
 .extrude(1.2).rotate([1,0,0],90).translate(0,-1.9,0).material(metal);
add('upper-titanium-bridge',bridgeTop,true);
const bridgeLower=path().moveTo(-12,39.7).bezierTo([-7,37],[7,37],[12,39.7])
.lineTo(12,38.3).bezierTo([6.5,35.9],[-6.5,35.9],[-12,38.3]).close()
.extrude(1.25).rotate([1,0,0],90).translate(0,-1.2,0).material(metal);
add('curved-lower-titanium-bridge',bridgeLower,true);
const eyebrow=path().moveTo(-68,45.8).bezierTo([-46,47.7],[-20,47.3],[-12,45.1])
.bezierTo([-5,44.7],[5,44.7],[12,45.1])
.bezierTo([20,47.3],[46,47.7],[68,45.8])
.lineTo(68,44.7).bezierTo([44,46.4],[21,46.3],[12,44])
.bezierTo([5,43.8],[-5,43.8],[-12,44])
.bezierTo([-21,46.3],[-44,46.4],[-68,44.7]).close()
.extrude(1).rotate([1,0,0],90).translate(0,-1.6,0).material(metal);
add('continuous-slim-browbar',eyebrow,true);

const flexMat={baseColor:'#403a2e',metalness:0.08,roughness:0.64};
const thermalMat={baseColor:'#343b42',metalness:0.40,roughness:0.57};
const showEngineeringEnvelopes=param('showEngineeringEnvelopes',false,{description:'Non-functional optics and PCB envelope reference'});
const openInternals=param('openInternals',false,{description:'True reveals the electronics for an engineering inspection; false is the premium closed exterior'});
const casing={baseColor:'#172126',metalness:0.22,roughness:0.30,clearcoat:0.65,clearcoatRoughness:0.24};
const board={baseColor:'#15524b',metalness:0.12,roughness:0.48};
const ic={baseColor:'#1e2831',metalness:0.06,roughness:0.53};
const battery={baseColor:'#b8c0c8',metalness:0.32,roughness:0.37};
const copper={baseColor:'#b8894a',metalness:0.88,roughness:0.22};
const optics={baseColor:'#07131c',metalness:0.24,roughness:0.12,clearcoat:0.9};
for(const s of [-1,1]){
 const side=s<0?'L':'R',x=s*69,ix=x-s*1.5;
 let mainHousing=box(12.6,59,11.6).fillet(2.8)
 .subtract(box(10.1,56.2,12).translate(1.25,1.4,1.25))
 .translate(x-6.3,19,32.4);
// Recessed Type-C panel opening in right outward temple only;
// port width along temple Y=10mm, height along Z=4.5mm.
if(s>0)mainHousing=mainHousing.subtract(
 extrudeRoundedRect(4.5,10,1.1,3.3).rotate([0,1,0],90)
 .translate(73.9,68.6,38.15)
);
add('v18-hollow-main-housing-'+side,mainHousing.material(casing));
 if(!openInternals.value)add('v14-main-cover-'+side,box(11.8,57,0.65).fillet(0.32).translate(x-5.9,20,43.8).material(casing));
 add('v14-PCB-'+side,box(8,49,0.85).translate(ix-4,25,34.1).material(board));
 // Thin angled insulated flex from optical engine to front main board.
 const opticalFPC=prismFront([[14.5,40.4],[18.3,40.4],[23.1,35.1],[26,34.88],[28,34.88],
 [28,34.55],[26,34.55],[22.7,34.83],[18,39.98],[14.5,39.98]],ix-2.5,ix+2.5);
 add('v19-projector-to-board-flex-'+side,opticalFPC.material(flexMat));
 add('v14-LCoS-engine-'+side,box(9,14,6.6).fillet(1).translate(s*64-4.5,4.5,39.2).material(optics));
 const modules=s>0?[['SAR2130P',6.2,7.2,1.7,30],['LPDDR4x',4.4,5,1,42],['PMAR2130',4.3,5,1,54]]:[['XRC130',5.8,6.5,1.7,30],['WCN7850',5.8,6.5,1.4,43],['PMXR130',4.3,5,1,55]];
 for(const [n,w,l,h,y] of modules)add('v14-'+n,box(w,l,h).translate(ix-w/2,y,35).material(ic));
 add('v19-covert-thermal-spreader-'+side,box(0.3,30,5)
 .translate(x+s*5.2-0.15,33,35).material(thermalMat),true);
 add('v14-battery-shell-'+side,box(11.6,32,9.6).fillet(2.5).subtract(box(9.1,29.3,10).translate(1.25,1.35,1.2)).translate(x-5.8,78,32).material(casing));
 add('v14-LiPo-cell-'+side,box(7,25,5.4).fillet(0.7).translate(ix-3.5,81,33.7).material(battery));
 if(!openInternals.value)add('v14-battery-cover-'+side,box(10.8,30.5,0.75).fillet(0.32).translate(x-5.4,78.7,41.25).material(casing));
 add('v14-open-ear-speaker-'+side,box(7.2,10,2).translate(x-3.6,89,40.4).material(ic));
 add('v14-antenna-'+side,box(5.6,7,0.4).translate(x-2.8,100,36).material(copper));
 add('v14-eye-camera-'+side,cylinder(0.7,1.2).rotate([1,0,0],-90).translate(s*55,1.4,42.5).material(optics));
}
add('v14-RGB-camera',cylinder(1.2,1.5).rotate([1,0,0],90).translate(0,-2.2,44.8).material(optics));
// Removed the earlier misplaced USB-C proxy; replaced by one recessed receptacle.


/**
 * V1.7 — INTERCONNECTION + HYBRID MAGNETIC DOCK CONCEPT.
 * 120 Hz is an electrical/optical requirement NOT supported by the documented
 * SAR2130P native 1280x720@60 display output. The DP sink/display controller
 * below is a provisional envelope, not a validated chip or schematic.
 * Both cells retain isolated protection; DO NOT hard-parallel bare cells.
 * Structural glass frame and metal brow require routing/EMI validation.
 */
const showUSBPlug=param('showUSBPlug',false,{description:'Show the optional USB-C cable connector plugged in'});
// flexMat and thermalMat are declared before the front electronics loops.
const contactMat={baseColor:'#e4bd73',metalness:0.87,roughness:0.17};
const gasketMat={baseColor:'#0d141b',metalness:0.05,roughness:0.53};
const controllerMat={baseColor:'#1f2b35',metalness:0.16,roughness:0.49};
const receptacleMat={baseColor:'#acb7c1',metalness:0.91,roughness:0.21};
// Internal insulated two-lane rigid-flex route, sculpted along the brow
// rather than exposed rectangular metallic strips. Cable paths share
// the interior top rim and the covered double bridge (provisional).
function browLine(){
 return path().moveTo(12,44.09)
 .bezierTo([28,45.17],[45,45.21],[63,44.59])
 .lineTo(63,44.26)
 .bezierTo([45,44.87],[28,44.85],[12,43.77]).close();
}
for(const s of [-1,1]){
 let line=browLine();if(s<0)line=line.reflect('y');
 add('v19-hidden-curved-brow-flex-'+(s<0?'L':'R'),
 line.extrude(0.24).rotate([1,0,0],90).translate(0,-1.96,0).material(flexMat));
}
add('v19-insulated-bridge-connection',
 box(24,0.24,0.32).translate(-12,-2.02,43.77).material(flexMat));
for(const s of [-1,1]){
 add('v19-brow-hinge-connection-'+(s<0?'L':'R'),
 box(7,1,0.27).translate(s<0?-69:62,-0.65,43.02).material(flexMat));
}

// Left/right hinge service loops. Actual bend radius and mechanical retention
// must be specified from a real flex PCB supplier; these are space markers.
for(const s of [-1,1]){
 const id=s<0?'L':'R';
 const service=prismFront([[1.5,43.3],[5,43.3],[9,39.2],[15,37.5],[24,34.85],
 [27,34.85],[27,34.55],[24,34.55],[14.8,37.15],[8.6,38.88],
 [4.5,42.85],[1.5,42.85]],s*69-1.5,s*69+1.5);
 add('v19-insulated-hinge-service-loop-'+id,service.material(flexMat));
 add('v17-cell-protection-and-gauge-'+id,box(5.0,4.0,1.0)
  .translate(s*69-2.5,78.9,35).material(controllerMat));
 const powerFPC=prismFront([[69,34.88],[74,34.88],[78,35.4],[83,35.4],
 [83,35.07],[78,35.07],[74,34.52],[69,34.52]],s*69-1.5,s*69+1.5);
 add('v19-board-battery-gauge-flex-'+id,powerFPC.material(flexMat));
}
// V2.2: subtle exterior accents (visual only, not qualified mechanical joints).
for(const s of [-1,1]){
 const id=s<0?'L':'R';
 const outerX0=s<0?-75.70:75.30,outerX1=s<0?-75.30:75.70;
 add('v22-tapered-satin-temple-rail-'+id,
 prismFront([[23,41.05],[26,41.57],[68,41.57],[73,41.05],
 [68,40.86],[26,40.86]],outerX0,outerX1).material(brightEdge),true);
 add('v22-recessed-temple-signature-'+id,
 prismFront([[27,38.72],[29,39.1],[43,39.1],[45,38.72],
 [43,38.34],[29,38.34]],outerX0,outerX1).material(smokedBezel),true);
 const rearX0=s<0?-75.01:74.8,rearX1=s<0?-74.8:75.01;
 add('v22-rear-titanium-accent-'+id,
 prismFront([[82,40.22],[84,40.54],[100,40.54],[102,40.22],
 [100,40.04],[84,40.04]],rearX0,rearX1).material(satinTitanium),true);
 add('v22-front-corner-rivet-'+id,
 cylinder(0.42,0.74).rotate([1,0,0],90)
 .translate(s*65.2,-4.62,40.3).material(brightEdge),true);
 add('v22-precision-camera-bezel-'+id,
 cylinder(0.36,1.94).subtract(cylinder(0.6,1.51).translate(0,0,-0.1))
 .rotate([1,0,0],90).translate(s*67.4,-5.15,39.3).material(brightEdge),true);
 add('v22-hinge-cap-'+id,cylinder(0.38,1.18)
 .rotate([0,1,0],s*90).translate(s*71.5,7.1,37.4).material(brightEdge),true);
}
// V2.4 serviceability study: symmetric hinge pin and service head markers.
// Hardware dimensions, retention and folding sweep require physical testing.
const serviceSteel={baseColor:'#b3bdc2',metalness:0.9,roughness:0.29};
for(const s of [-1,1]){
 const id=s<0?'L':'R',x=s*69;
 add('v24-hinge-axle-proxy-'+id,cylinder(5.2,0.85)
 .translate(x,8,34.6).material(serviceSteel),true);
 for(const y of [26,70,83,102])
 add('v24-cover-service-head-'+id,cylinder(0.24,0.72)
 .translate(x,y,y<75?44.49:42.10).material(satinTitanium),true);
}
// Mass and thermal balance need measured component specifications, not guessed weights.
// V1.8 right-temple high-speed USB-C receptacle, facing outward.
// Full-featured USB-C connector is required for DP Alt Mode, NOT a charge-only
// or 6-pin receptacle. Exact vendor footprint/plug envelope are not verified.
// Right temple outer wall: X ≈ 75.3 mm, forward of ear, Y 63.7..73.7.
const usbPortY=68.6, usbPortZ=38.15;
// 10.0 x 4.5 mm rounded panel clearance: boolean cut belongs to v14 housing.
// 24-pin receptacle shell and dark tongue are independent model parts.
function portFacingX(w,h,depth,x,y,z,r=1.1){
 return extrudeRoundedRect(h,w,r,depth).rotate([0,1,0],90).translate(x,y,z);
}
add('v18-USB-C-receptacle-metal-shell',portFacingX(8.94,3.26,7.7,67.25,usbPortY,usbPortZ,1.1).material(receptacleMat),true);
// Dark central insert inset into socket face.
add('v18-USB-C-insulator-tongue',portFacingX(5.7,0.90,0.40,74.60,usbPortY,usbPortZ,0.3).material(gasketMat));
// External 120Hz path: conceptual DP sink + retimer + display mux package.
// Actual AR2 and optical engine input/output capabilities NOT validated.
add('v18-USBC-CC-PD-negotiation-controller',box(3.3,3.3,1.0)
 .translate(66.6,57.0,39.15).material(controllerMat));
add('v18-USB-ESD-protection-and-DP-retimer',box(4.3,5.0,1.05)
 .translate(65.9,61.0,39.15).material(controllerMat));
add('v18-DP-video-receiver-placeholder',box(5.5,7.0,1.15)
 .translate(66.1,46.0,39.15).material(controllerMat));
add('v18-120Hz-display-path-mux-placeholder',box(4.8,5.0,1.0)
 .translate(66.3,52.0,39.15).material(controllerMat));
// Optional cable insertion view. Cable MUST support full DP Alt Mode.
if(showUSBPlug.value){
 add('v18-USB-C-plug-proxy',portFacingX(8.80,3.05,7.5,75.3,usbPortY,usbPortZ,1.05).material(receptacleMat),true);
 add('v18-USB-C-cable-overmold',box(12,14,6.2).fillet(1.4)
 .translate(81,usbPortY-7,usbPortZ-3.1).material(gasketMat));
}

// V1.9: Hide copper interconnects in rim, route insulated hinge loop and board/battery flex.
// Electrical trace width, strain and impedance require a real rigid-flex PCB design.
// V1.8: One recessed full-featured USB-C port replaces bulky exposed pogo pads.
// Charging and laptop DP Alt Mode require real PD/DP electronics and verified signal integrity.
// V1.6: Revert to V1.4 silhouette; replace intrusive full-length metal rod
// with a compact hinge link and tapered over-ear hook. Move battery housing
// forward, clear space directly above/behind ears. Cells are now substantially
// shorter than the reference kit and must be re-specified for real endurance.
// Actual fit depends on head width, ears and nose bridge measurements.
// Explicitly permit documented intentional intersections between fixed aesthetic overlays.
// This is a visual concept, not a clearance-verified manufacturing assembly.
// Visual package model: cosmetic and reserved envelopes are NOT fit-verified.
// Adjustable nose pad cosmetic joints are CAD fit concepts, not qualified hardware.
// EDITH V2.1 PRINT FIT KIT (millimetres). Optical/electronic functions excluded.
// Printed structural shells and comfort gauges only. Use PETG for hard parts,
// TPU for pads. Metal M2 hinge hardware must be supplied separately.
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
function makePrintKit(A,dx=0,dy=0){
function piece(n,shape,offX,offY=0,c=shellColor){A.part('print-'+n,shape.translate(offX+dx,offY+dy,0).material(c),{material:'petg'});}
let F=printRim(-1,1,0,4.6).subtract(printRim(-1,.875,.8,6.3))
.union(printRim(1,1,0,4.6).subtract(printRim(1,.875,.8,6.3)))
.union(box(25,3.2,2.7).translate(-12.5,-3.2,43))
.union(box(25,3,2.3).translate(-12.5,-3,38.3));
for(const s of [-1,1])F=F.union(box(6.4,10,5.7).fillet(0.85).translate(s*69-3.2,-1,35.2));
for(const s of [-1,1])F=F.subtract(cylinder(7,1.2).translate(s*69,6.5,34.5));
piece('front-frame',F,350,0);
for(const s of [-1,1]){
const id=s<0?'left':'right';
let M=box(12.6,59,11.6).fillet(2).subtract(box(10.1,56.2,12).translate(1.25,1.4,1.25)).translate(s*69-6.3,19,32.4);
if(s>0)M=M.subtract(extrudeRoundedRect(4.5,10,1.1,3.3).rotate([0,1,0],90).translate(73.9,68.6,38.15));
const B=box(11.6,32,9.6).fillet(1.8).subtract(box(9.1,29.3,10).translate(1.25,1.35,1.2)).translate(s*69-5.8,78,32);
const H=box(4.2,15,4.2).fillet(.8).translate(s*69-2.1,6,35.9).subtract(cylinder(6,1.2).translate(s*69,8,35));
const T=M.union(B).union(printEar(s)).union(H);
piece(id+'-temple-shell',T,s<0?335:380,21);
const mainCover=box(11.2,55.5,1.25).fillet(.35).translate(s*69-5.6,20.6,43.6);
piece(id+'-electronics-cover',mainCover,s<0?280:430,7,lidColor);
const cellCover=box(10.2,28.3,1.25).fillet(.35).translate(s*69-5.1,79.8,41.65);
piece(id+'-battery-cover',cellCover,s<0?280:430,23,lidColor);
const pad=extrudeRoundedRect(6.8,11,3.25,1.75);
piece(id+'-nose-pad-TPU-gauge',pad,s<0?295:405,150,tipColor);
}
}

const ignored=[["black-acetate-rim-left","precision-hinge-left"],["black-acetate-rim-left","nose-pad-metal-arm-left"],["black-acetate-rim-left","upper-titanium-bridge"],["black-acetate-rim-left","curved-lower-titanium-bridge"],["black-acetate-rim-left","continuous-slim-browbar"],["palladium-perimeter-inlay-left","precision-hinge-left"],["palladium-perimeter-inlay-left","upper-titanium-bridge"],["precision-hinge-left","curved-titanium-style-temple-left"],["curved-titanium-style-temple-left","hidden-electronics-side-pod-left"],["hidden-electronics-side-pod-left","side-machined-stripe-left"],["nose-pad-metal-arm-left","soft-nose-pad-left"],["black-acetate-rim-right","precision-hinge-right"],["black-acetate-rim-right","nose-pad-metal-arm-right"],["black-acetate-rim-right","upper-titanium-bridge"],["black-acetate-rim-right","curved-lower-titanium-bridge"],["black-acetate-rim-right","continuous-slim-browbar"],["palladium-perimeter-inlay-right","precision-hinge-right"],["palladium-perimeter-inlay-right","upper-titanium-bridge"],["precision-hinge-right","curved-titanium-style-temple-right"],["curved-titanium-style-temple-right","hidden-electronics-side-pod-right"],["side-machined-stripe-right","diamond-pattern-right-0"],["side-machined-stripe-right","diamond-pattern-right-1"],["side-machined-stripe-right","diamond-pattern-right-2"],["side-machined-stripe-right","diamond-pattern-right-3"],["side-machined-stripe-right","diamond-pattern-right-4"],["side-machined-stripe-right","diamond-pattern-right-5"],["side-machined-stripe-right","diamond-pattern-right-6"],["side-machined-stripe-right","diamond-pattern-right-7"],["side-machined-stripe-right","diamond-pattern-right-8"],["nose-pad-metal-arm-right","soft-nose-pad-right"],["upper-titanium-bridge","continuous-slim-browbar"]];
for(let i=0;i<names.length;i++)for(let j=i+1;j<names.length;j++)if(names[i].startsWith('v24-')||names[j].startsWith('v24-')||names[i].startsWith('v22-')||names[j].startsWith('v22-')||names[i].startsWith('v17-')||names[j].startsWith('v17-')||names[i].startsWith('v18-')||names[j].startsWith('v18-')||names[i].startsWith('v19-')||names[j].startsWith('v19-')||names[i].startsWith('v20-')||names[j].startsWith('v20-')||names[i].startsWith('v14-')||names[j].startsWith('v14-')||names[i].startsWith('soft-over-ear')||names[j].startsWith('soft-over-ear')||names[i].startsWith('slim-bent')||names[j].startsWith('slim-bent')||names[i].startsWith('short-metal-hinge')||names[j].startsWith('short-metal-hinge'))ignored.push([names[i],names[j]]);
// Dual display: completed eyewear at X≈0 and disassembled printable kit at X≈280–485.
// Exploded solids are PETG fitting prototypes, not production-safe optical components.
makePrintKit(assemblyModel);
for(let i=0;i<names.length;i++)for(let j=i+1;j<names.length;j++)if(names[i].startsWith('print-')||names[j].startsWith('print-'))ignored.push([names[i],names[j]]);
return assemblyModel.solvedModel({}, {ignore:ignored});