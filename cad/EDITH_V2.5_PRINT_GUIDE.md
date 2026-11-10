# EDITH V2.5 — 3D-print fit-test guide

## Model and scope

- [Editable kernelCAD model (V2.5, revision 1)](https://app.kernelcad.com/p/7UDN0k4A?version=1)
- [Editable source](edith-v2.5-print-kit.kcad.ts)
- [Original V2.4 concept](edith-v2.4.kcad.ts)
- Download **nine individually oriented STLs** from the [V2.5 print-kit GitHub prerelease](https://github.com/Arnost55/E.D.I.T.H/releases/tag/v2.5-fit-kit-preview).

**This is a preliminary fit test, not a validated production model.** The frame is based on nominal 52-22-144 mm reference dimensions; it has not been fitted to an individual wearer. It does not contain prescription lenses, operational AR displays, real electronics, battery safety provisions, or certified hinge hardware.

## Nine parts

| Part | Quantity | Suggested filament | Maximum individual size after print orientation |
| --- | ---: | --- | --- |
| Front frame | 1 | PETG | 145.4 × 45.6 × 19.1 mm |
| Left and right temple shells | 2 | PETG | 18.2 × 145.2 × 12.6 mm each |
| Left and right electronics covers | 2 | PETG | 11.2 × 55.5 × 1.25 mm each |
| Left and right battery covers | 2 | PETG | 10.2 × 28.3 × 1.25 mm each |
| Nose-pad comfort gauges | 2 | TPU 95A optional | 6.8 × 11 × 1.75 mm each |

All nine parts were exported as watertight STL meshes by kernelCAD. **No physical print or hinge fit has been validated yet.**

## Suggested Bambu Lab A1 mini setup

- 0.4 mm nozzle, 0.20 mm layers, 3 walls, 20–30% gyroid infill.
- Start with PETG for the three main structural pieces. Test print the front frame and one temple before printing all covers.
- Load the *print-ready, individually reoriented STLs* from the release. They have been recentered onto Z=0. The raw kernelCAD model is exploded for inspection and is not itself a prearranged print plate.
- Inspect Bambu Studio slice preview for overhangs and supports. Use a brim if adhesion is weak. Do not assume every unsupported surface will print cleanly.
- For the hinges, the model uses nominal 2.4 mm holes for M2 hardware and a 2.95 mm front knuckle gap with a 2.25 mm center tongue. Try two M2 screws approximately 10–12 mm long with appropriate nuts, then adjust after checking physical engagement and clearances. **Do not force an undersized hinge or overtighten plastic.**
- Cover plates have no functional retention mechanism; attach temporarily with tape for fit tests. Nose-pad gauges are not a finished mounting system.
- Deburr and inspect all skin-contact edges; do not wear a cracked prototype.

## Next measurements

1. Confirm bridge width, eye position, temple length and ear curvature against actual wearer measurements.
2. Measure printed hinge hole diameters, swing clearance and resistance to cracking.
3. Record masses, fit comfort and any pressure points.
4. Select real hinges, inserts and fastening methods before redesigning the shells around electronics.

**Do not use this as protective or corrective eyewear, or for driving.**
