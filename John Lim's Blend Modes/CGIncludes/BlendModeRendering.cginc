#ifndef BLENDMODE_RENDERING_INCLUDED
#define BLENDMODE_RENDERING_INCLUDED

struct BlendModeAppdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
};

struct BlendModeVaryings
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float4 color : COLOR;
    float4 bguv : TEXCOORD1;
    float3 tint1 : TEXCOORD2;
    float3 tint2 : TEXCOORD3;
};

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _Tint1;
float4 _Tint2;
float _Alpha;
float _BlendSpace;
float _BlendSrc;
float _BlendDst;
sampler2D _GrabTexture;

// Exact sRGB transfer functions, not a gamma-2.2 approximation.
// Preserve white exactly: several blend modes have endpoint branches at 1.
float BlendModeDecodeSRGB(float c)
{
    if (c == 1.0) return 1.0;
    return c <= 0.04045 ? c / 12.92 : pow(max((c + 0.055) / 1.055, 0.0), 2.4);
}

float BlendModeEncodeSRGB(float c)
{
    if (c == 1.0) return 1.0;
    return c <= 0.0031308 ? 12.92 * c : 1.055 * pow(max(c, 0.0), 1.0 / 2.4) - 0.055;
}

bool BlendModeConvertsSpace()
{
#if defined(UNITY_COLORSPACE_GAMMA)
    return _BlendSpace == 2.0;
#else
    return _BlendSpace == 1.0 || _BlendSpace == 3.0;
#endif
}

bool BlendModeCompositeConvertsSpace()
{
#if defined(UNITY_COLORSPACE_GAMMA)
    return _BlendSpace == 2.0 || _BlendSpace == 3.0;
#else
    return _BlendSpace == 1.0;
#endif
}

float3 BlendModeToSpace(float3 c)
{
    if (!BlendModeConvertsSpace()) return c;
#if defined(UNITY_COLORSPACE_GAMMA)
    return float3(BlendModeDecodeSRGB(c.r), BlendModeDecodeSRGB(c.g), BlendModeDecodeSRGB(c.b));
#else
    return float3(BlendModeEncodeSRGB(c.r), BlendModeEncodeSRGB(c.g), BlendModeEncodeSRGB(c.b));
#endif
}

float3 BlendModeToCompositeSpace(float3 c)
{
    if (!BlendModeCompositeConvertsSpace()) return c;
#if defined(UNITY_COLORSPACE_GAMMA)
    return float3(BlendModeDecodeSRGB(c.r), BlendModeDecodeSRGB(c.g), BlendModeDecodeSRGB(c.b));
#else
    return float3(BlendModeEncodeSRGB(c.r), BlendModeEncodeSRGB(c.g), BlendModeEncodeSRGB(c.b));
#endif
}

float3 BlendModeFromCompositeSpace(float3 c)
{
    if (!BlendModeCompositeConvertsSpace()) return c;
#if defined(UNITY_COLORSPACE_GAMMA)
    return float3(BlendModeEncodeSRGB(c.r), BlendModeEncodeSRGB(c.g), BlendModeEncodeSRGB(c.b));
#else
    return float3(BlendModeDecodeSRGB(c.r), BlendModeDecodeSRGB(c.g), BlendModeDecodeSRGB(c.b));
#endif
}

BlendModeVaryings BlendModeVert(BlendModeAppdata v)
{
    BlendModeVaryings o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.color = v.color;
    o.color.rgb = BlendModeToSpace(v.color.rgb);
    o.tint1 = BlendModeToSpace(_Tint1.rgb) * _Tint1.a;
    o.tint2 = BlendModeToSpace(_Tint2.rgb) * _Tint2.a;
    o.bguv = ComputeGrabScreenPos(o.vertex);
    return o;
}

float3 BlendModeSource(BlendModeVaryings i, out float alpha)
{
    float4 textureColor = tex2D(_MainTex, i.uv);
    float3 source = saturate(BlendModeToSpace(textureColor.rgb) * i.color.rgb + i.tint1);
    alpha = saturate(textureColor.a * i.color.a * _Alpha);
    return source;
}

float4 BlendModeBackdrop(BlendModeVaryings i)
{
    float4 backdrop = tex2Dproj(_GrabTexture, i.bguv);
    backdrop.a = saturate(backdrop.a);
    return backdrop;
}

float3 BlendModeBackdropColor(float4 backdrop)
{
    return backdrop.a > 0.0 ? BlendModeToSpace(saturate(backdrop.rgb / backdrop.a)) : float3(0.0, 0.0, 0.0);
}

// UnityEngine.Rendering.BlendMode values. RGB factors operate in the selected
// space; alpha retains the existing independent source-over equation.
float3 BlendModeFactor(float factor, float3 source, float sourceAlpha, float4 backdrop)
{
    if (factor == 0.0) return 0.0;                          // Zero
    if (factor == 1.0) return 1.0;                          // One
    if (factor == 2.0) return backdrop.rgb;                 // DstColor
    if (factor == 3.0) return source;                       // SrcColor
    if (factor == 4.0) return 1.0 - backdrop.rgb;           // OneMinusDstColor
    if (factor == 5.0) return sourceAlpha;                  // SrcAlpha
    if (factor == 6.0) return 1.0 - source;                 // OneMinusSrcColor
    if (factor == 7.0) return backdrop.a;                   // DstAlpha
    if (factor == 8.0) return 1.0 - backdrop.a;             // OneMinusDstAlpha
    if (factor == 9.0) return min(sourceAlpha, 1.0 - backdrop.a); // SrcAlphaSaturate
    return 1.0 - sourceAlpha;                             // OneMinusSrcAlpha
}

float4 BlendModeCompose(float3 source, float3 modeResult, float4 backdrop, float sourceAlpha, float3 tint2)
{
    // Tint only the overlap result. Source-only coverage keeps source RGB.
    float3 blended = saturate(modeResult + tint2);
    if (_BlendSpace == 3.0)
    {
        // Photoshop's linear-opacity setting keeps the mode formula in sRGB.
        source = float3(BlendModeDecodeSRGB(source.r), BlendModeDecodeSRGB(source.g), BlendModeDecodeSRGB(source.b));
        blended = float3(BlendModeDecodeSRGB(blended.r), BlendModeDecodeSRGB(blended.g), BlendModeDecodeSRGB(blended.b));
    }
    float3 fragment = lerp(source, blended, backdrop.a);
    sourceAlpha = saturate(sourceAlpha);

    // Transfer functions operate on straight RGB, never premultiplied RGB.
    // Keep the residual backdrop unbounded, matching Project-space behavior.
    if (BlendModeCompositeConvertsSpace() && backdrop.a > 0.0)
        backdrop.rgb = BlendModeToCompositeSpace(backdrop.rgb / backdrop.a) * backdrop.a;

    float3 rgb;
    if (_BlendSrc == 5.0 && _BlendDst == 10.0)
        rgb = fragment * sourceAlpha + backdrop.rgb * (1.0 - sourceAlpha);
    else
        rgb = fragment * BlendModeFactor(_BlendSrc, fragment, sourceAlpha, backdrop)
            + backdrop.rgb * BlendModeFactor(_BlendDst, fragment, sourceAlpha, backdrop);

    float alpha = sourceAlpha + backdrop.a * (1.0 - sourceAlpha);
    if (BlendModeCompositeConvertsSpace() && alpha > 0.0)
        rgb = BlendModeFromCompositeSpace(rgb / alpha) * alpha;
    return float4(rgb, alpha);
}

#endif // BLENDMODE_RENDERING_INCLUDED
