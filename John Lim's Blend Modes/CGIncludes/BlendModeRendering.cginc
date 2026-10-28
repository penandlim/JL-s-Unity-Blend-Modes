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
};

sampler2D _MainTex;
float4 _MainTex_ST;
float4 _Tint1;
float4 _Tint2;
float _Alpha;
sampler2D _GrabTexture;

BlendModeVaryings BlendModeVert(BlendModeAppdata v)
{
    BlendModeVaryings o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.color = v.color;
    o.bguv = ComputeGrabScreenPos(o.vertex);
    return o;
}

float3 BlendModeSource(BlendModeVaryings i, out float alpha)
{
    fixed4 textureColor = tex2D(_MainTex, i.uv);
    float3 source = saturate(textureColor.rgb * i.color.rgb + _Tint1.rgb * _Tint1.a);
    alpha = saturate(textureColor.a * i.color.a * _Alpha);
    return source;
}

float3 BlendModeBackdrop(BlendModeVaryings i, out float alpha)
{
    fixed4 backdrop = tex2Dproj(_GrabTexture, i.bguv);
    alpha = saturate(backdrop.a);
    return alpha > 0.0 ? saturate(backdrop.rgb / alpha) : float3(0.0, 0.0, 0.0);
}

float4 BlendModeCompose(float3 source, float3 modeResult, float backdropAlpha, float sourceAlpha)
{
    // Tint the mode result before mixing overlap and source-only coverage.
    float3 blended = saturate(modeResult + _Tint2.rgb * _Tint2.a);
    float3 rgb = lerp(source, blended, saturate(backdropAlpha));
    return float4(rgb, saturate(sourceAlpha));
}

#endif // BLENDMODE_RENDERING_INCLUDED
