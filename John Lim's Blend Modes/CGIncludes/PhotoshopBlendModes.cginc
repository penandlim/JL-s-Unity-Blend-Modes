#ifndef PHOTOSHOP_BLENDMODES_INCLUDED
#define PHOTOSHOP_BLENDMODES_INCLUDED
 
//
// Ported from https://www.shadertoy.com/view/XdS3RW
//
// Original License:
//
// Creative Commons CC0 1.0 Universal (CC-0) 
//
// 25 of the layer blending modes from Photoshop.
//
// The ones I couldn't figure out are from Nvidia's advanced blend equations extension spec -
// http://www.opengl.org/registry/specs/NV/blend_equation_advanced.txt
// 
// ~bj.2013
//
 
// Helpers
 
// Compile the weights into the shader instead of exposing an unset uniform.
static const fixed3 l = fixed3(0.3, 0.59, 0.11);
 
/** @private */
float colorBurn(float s, float d)
{
    if(d >= 1.0) return 1.0;
    if(s <= 0.0) return 0.0;
    return saturate(1.0 - (1.0 - d) / s);
}

/** @private */
float colorDodge(float s, float d)
{
    if(d <= 0.0) return 0.0;
    if(s >= 1.0) return 1.0;
    return saturate(d / (1.0 - s));
}

/** @private */
float pinLight(float s, float d)
{
    return saturate((2.0*s - 1.0 > d) ? 2.0*s - 1.0 : (s < 0.5 * d) ? 2.0*s : d);
}

/** @private */
float vividLight(float s, float d)
{
    return (s < 0.5) ? colorBurn(2.0 * s, d) : colorDodge(2.0 * s - 1.0, d);
}

/** @private */
float hardLight(float s, float d)
{
    return saturate((s < 0.5) ? 2.0*s*d : 1.0 - 2.0*(1.0 - s)*(1.0 - d));
}

/** @private */
float softLight(float s, float d)
{
    return saturate((s < 0.5) ? d - (1.0 - 2.0*s)*d*(1.0 - d) 
                : (d < 0.25) ? d + (2.0*s - 1.0)*d*((16.0*d - 12.0)*d + 3.0) 
                : d + (2.0*s - 1.0) * (sqrt(d) - d));
}

/** @private */
float overlay(float s, float d)
{
    return saturate((d < 0.5) ? 2.0*s*d : 1.0 - 2.0*(1.0 - s)*(1.0 - d));
}

/** @private */
float divide(float numerator, float denominator)
{
    return denominator == 0.0 ? 1.0 : min(1.0, numerator / denominator);
}
 

/** @private */
fixed3 setLum(fixed3 c, float lum)
{
    if(lum <= 0.0) return 0.0;
    if(lum >= 1.0) return 1.0;
    // Preserve the requested luminosity when clipping to the RGB gamut.
    float3 result = c + (lum - dot(c, l));
    float minC = min(min(result.x, result.y), result.z);
    float maxC = max(max(result.x, result.y), result.z);
    if(minC < 0.0) result = lum + ((result - lum) * lum) / (lum - minC);
    if(maxC > 1.0) result = lum + ((result - lum) * (1.0 - lum)) / (maxC - lum);
    return saturate(result);
}
 
/** @private */
float sat(fixed3 c)
{
    return max(max(c.x, c.y), c.z) - min(min(c.x, c.y), c.z);
}

/** @private */
fixed3 setSat(fixed3 c, float saturation)
{
    float minC = min(min(c.x, c.y), c.z);
    float maxC = max(max(c.x, c.y), c.z);
    if(maxC == minC) return 0.0;
    return saturate(((float3(c) - minC) / (maxC - minC)) * saturation);
}
 
// Public API Blend Modes
// Noncommutative color modes take blend/source s, then background/destination d.
// Subtract and Divide retain their arithmetic s-d and s/d argument order.

fixed3 ColorBurn(fixed3 s, fixed3 d)
{
    return fixed3(colorBurn(s.x, d.x), colorBurn(s.y, d.y), colorBurn(s.z, d.z));
}

fixed3 LinearBurn(fixed3 s, fixed3 d)
{
    return saturate(s + d - 1.0);
}

fixed3 DarkerColor(fixed3 s, fixed3 d)
{
    return (s.x + s.y + s.z < d.x + d.y + d.z) ? s : d;
}

fixed3 Lighten(fixed3 s, fixed3 d)
{
    return saturate(max(s, d));
}

fixed3 Screen(fixed3 s, fixed3 d)
{
    return saturate(s + d - s * d);
}

fixed3 ColorDodge(fixed3 s, fixed3 d)
{
    return fixed3(colorDodge(s.x, d.x), colorDodge(s.y, d.y), colorDodge(s.z, d.z));
}

fixed3 LinearDodge(fixed3 s, fixed3 d)
{
    return saturate(s + d);
}

fixed3 LighterColor(fixed3 s, fixed3 d)
{
    return (s.x + s.y + s.z > d.x + d.y + d.z) ? s : d;
}

fixed3 Overlay(fixed3 s, fixed3 d)
{
    return fixed3(overlay(s.x, d.x), overlay(s.y, d.y), overlay(s.z, d.z));
}

fixed3 SoftLight(fixed3 s, fixed3 d)
{
    return fixed3(softLight(s.x, d.x), softLight(s.y, d.y), softLight(s.z, d.z));
}

fixed3 HardLight(fixed3 s, fixed3 d)
{
    return fixed3(hardLight(s.x, d.x), hardLight(s.y, d.y), hardLight(s.z, d.z));
}

fixed3 VividLight(fixed3 s, fixed3 d)
{
    return fixed3(vividLight(s.x, d.x), vividLight(s.y, d.y), vividLight(s.z, d.z));
}

fixed3 LinearLight(fixed3 s, fixed3 d)
{
    return saturate(2.0*s + d - 1.0);
}

fixed3 PinLight(fixed3 s, fixed3 d)
{
    return fixed3(pinLight(s.x, d.x), pinLight(s.y, d.y), pinLight(s.z, d.z));
}

fixed3 HardMix(fixed3 s, fixed3 d)
{
    return step(1.0, s + d);
}

fixed3 Difference(fixed3 s, fixed3 d)
{
    return saturate(abs(d-s));
}

fixed3 Exclusion(fixed3 s, fixed3 d)
{
    return saturate(s + d - 2.0*s*d);
}

fixed3 Subtract(fixed3 s, fixed3 d)
{
    return saturate(s-d);
}

fixed3 Divide(fixed3 s, fixed3 d)
{
    return fixed3(divide(s.x, d.x), divide(s.y, d.y), divide(s.z, d.z));
}

fixed3 Add(fixed3 s, fixed3 d)
{
    return saturate(s+d);
}

fixed3 Multiply(fixed3 s, fixed3 d)
{
    return saturate(s*d);
}

fixed3 Normal(fixed3 s, fixed3 d)
{
    return saturate(s);
}

fixed3 Darken(fixed3 s, fixed3 d)
{
    return saturate(min(s, d));
}

fixed3 Hue(fixed3 s, fixed3 d)
{
    return setLum(setSat(s, sat(d)), dot(d, l));
}

fixed3 Color(fixed3 s, fixed3 d)
{
    return setLum(s, dot(d, l));
}

fixed3 Saturation(fixed3 s, fixed3 d)
{
    return setLum(setSat(d, sat(s)), dot(d, l));
}

fixed3 Luminosity(fixed3 s, fixed3 d)
{
    return setLum(d, dot(s, l));
}
 
#endif // PHOTOSHOP_BLENDMODES_INCLUDED
