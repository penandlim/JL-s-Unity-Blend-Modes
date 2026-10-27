# JL's Unity Blend Modes
Collection of Unity shaders that support blend modes like photoshop layer style (Darken, Multiply, Linear Burn, etc)

Each shader applies given texture from sprite renderer to the texture from Unity's GrabPass, emulaitng the blend effect of photoshop layers.

![alt text](https://raw.githubusercontent.com/penandlim/JL-s-Unity-Blend-Modes/master/preview.png "Preview")



Built for screen space effect but feel free to modify it by replacing GrabPass to other textures.

You can also use Stencil properties to limit the overlay effect to certain objects in the scene.

# Usage
1. Add a UI Canvas to your project.

2. Add a sprite renderer as a child

3. Add an image with desired colors/opacity/gradient.

4. Add a material with a shader thats in "Blendmodes/" category

5. Adjust tint and opacity of the blend layer accordingly.

## Multiply

Select **Blendmodes/Multiply** on a material and assign it to your sprite renderer.
Keep **Blend mode Source = SrcAlpha** and **Blend mode Destination = OneMinusSrcAlpha**;
the shader performs the multiplication before applying opacity. Do not change these
to `DstColor / Zero` to enable Multiply.

With neutral tints, the result is:

```
alpha = texture alpha * vertex color alpha * material opacity
result = background * (1 - alpha) + background * layer * alpha
```

A white layer preserves the background; an opaque black layer produces black.
Zero opacity or transparent texture pixels leave the background unchanged.
The texture is multiplied by the vertex color before **Tint on Texture** is added.
**Tint on Blended Result** is added after multiplication, before opacity is applied.
The existing stencil controls and **Color Mask** are supported.

Multiply uses an unnamed GrabPass and disables batching to avoid sharing a stale
background between layers. This trades extra screen copies and reduced batching
for correct stacked blending. It uses projective screen coordinates and does not
write depth. These changes apply only to Multiply, not the other legacy shaders.

Requires Unity's **Built-in Render Pipeline**; GrabPass is not supported by URP or
HDRP. Verified locally with Unity **6000.6.7f1**, **Metal**, and **Gamma** color space:
opacity, texture/vertex alpha, both tints, stencil/color masking, shared-material
stacking, and orthographic/perspective sampling.


# Special thanks
https://github.com/supyrb/ConfigurableShaders
