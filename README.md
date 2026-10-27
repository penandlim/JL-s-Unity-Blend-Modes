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


# Special thanks
https://github.com/supyrb/ConfigurableShaders
