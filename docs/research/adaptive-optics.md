# Adaptive prescription optics — research plan

**Status:** Research only. No electronic prescription lens has been built or validated for EDITH.

## Objective

Explore whether EDITH could offer independently adjustable left/right optical power, with a conventional prescription insert as the practical first-generation fallback.

A user with a -4.00 D spherical prescription is an illustrative use case, **not** evidence that an electronic lens can cover that correction safely.

## Requirements to define

- Spherical correction range and increment for each eye, based on an actual target population and optical architecture.
- Whether cylinder/axis (astigmatism), prism, and pupillary-distance correction are supported or require conventional optics.
- Clear aperture, field of view, transmission, haze, distortion, chromatic aberration, and off-axis performance.
- Lens thickness, mass, actuation energy, response time, durability, and behavior on power loss.
- Compatibility with AR waveguides and eye relief across the user's gaze and prescription range.
- Safe default state and a non-electronic corrective-lens option.

## Candidate approaches

| Approach | Why evaluate it | Main unknowns |
| --- | --- | --- |
| Liquid-crystal tunable optics | Potentially thin electronic control | Full-aperture power range, image quality, polarization, voltage |
| Fluid-filled deformable optics | Mechanical change in optical curvature | Thickness, pumping, sealing, temperature, long-term reliability |
| Alvarez elements | Predictable mechanical change in optical power | Packaging, alignment, actuation, wear, aberrations |
| Removable prescription insert | Feasible first-prototype baseline | Lens fit, optical alignment, compatibility with AR module |

## Proposed validation sequence

1. Define realistic lens aperture and eye-relief geometry from measured frame dimensions.
2. Obtain optical data and samples from suppliers; verify available correction range independently.
3. Characterize optical power with appropriate calibrated equipment, not subjective visual impressions.
4. Measure image quality, distortion, and power-failure behavior across the full aperture.
5. Check AR image alignment and comfort with professional optical input.
6. Only after appropriate safety and optical evaluation, consider wearable user testing.

## Safety

This is not a medical device or certified corrective eyewear. **Do not use unvalidated adaptive optics for driving or other activities requiring reliable vision.**

Research decisions and supplier evidence should be recorded here as the project progresses.
