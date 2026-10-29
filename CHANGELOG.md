# Changelog

## [legacy-2019-09-18](https://github.com/penandlim/JL-s-Unity-Blend-Modes/releases/tag/legacy-2019-09-18) — legacy snapshot

Published 2026-10-27, pinned to [`a46e41be35177d9587bd1562eda27bb678dc1249`](https://github.com/penandlim/JL-s-Unity-Blend-Modes/commit/a46e41be35177d9587bd1562eda27bb678dc1249). All 24 shader sources are unchanged from that release.

RGB previews rendered in Unity 6000.6.7f1 · Built-in/Metal · Gamma project · orthographic camera · 80% layer opacity · no tints. These are new captures of the legacy code, not historical Unity 2019 screenshots.

**Inputs** — the reference scene and gradient used throughout.

![Legacy sample background and blend layer](samples/legacy-2019-09-18/inputs.png)

**Darkening & arithmetic** — Color Burn, Linear Burn, Darker Color, Subtract, and Divide.

![Legacy Color Burn, Linear Burn, Darker Color, Subtract, and Divide](samples/legacy-2019-09-18/darken-arithmetic.png)

**Lightening** — Add, Linear Dodge, Screen, Lighten, Lighter Color, and Color Dodge.

![Legacy lightening blend modes](samples/legacy-2019-09-18/lighten.png)

**Contrast & differences** — Overlay through Exclusion.

![Legacy Overlay, Soft Light, Hard Light, Vivid Light, Linear Light, Pin Light, Hard Mix, Difference, and Exclusion](samples/legacy-2019-09-18/contrast-difference.png)

**Color components** — Hue, Saturation, Color, and Luminosity.

![Legacy Hue, Saturation, Color, and Luminosity](samples/legacy-2019-09-18/color-components.png)

**Stencil masks** — Color on selected objects; Screen inside a window. White marks affected pixels.

![Legacy stencil masks and their Color and Screen results](samples/legacy-2019-09-18/stencil-use-cases.png)

This release has no Multiply, Normal, Dissolve, Darken, or blend-space selector.
