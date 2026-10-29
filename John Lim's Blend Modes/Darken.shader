Shader "Blendmodes/Darken"
{
    Properties
    {
        [Header(Properties)]
        _MainTex ("Blend Texture", 2D) = "white" {}
        _Tint1 ("Tint on Texture", Color) = (1,1,1,0)
        _Tint2 ("Tint on Blended Result", Color) = (1,1,1,0)
        _Alpha ("Opacity of Blended Result", Range(0.0, 1.0)) = 1.0

        [Header(Blending)]
        [Enum(Project,0,sRGB,1,Linear,2,sRGBLinearOpacity,3)] _BlendSpace ("Blending Color Space", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5
        [Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10

        [Header(Stencil)]
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        [Enum(None,0,Alpha,1,Red,8,Green,4,Blue,2,RGB,14,RGBA,15)] _ColorMask("Color Mask", Int) = 15
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="true" "RenderType"="Transparent" "DisableBatching"="true" }
        LOD 100
        Cull Off
        ZWrite Off
        Blend Off
        ColorMask [_ColorMask]

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        GrabPass { }

        Pass
        {
            CGPROGRAM
            #pragma vertex BlendModeVert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "CGIncludes/PhotoshopBlendModes.cginc"
            #include "CGIncludes/BlendModeRendering.cginc"

            float4 frag (BlendModeVaryings i) : SV_Target
            {
                float alpha;

                float3 source = BlendModeSource(i, alpha);
                float4 background = BlendModeBackdrop(i);
                float3 backdrop = BlendModeBackdropColor(background);
                float3 blended = Darken(source, backdrop);
                return BlendModeCompose(source, blended, background, alpha, i.tint2);
            }
            ENDCG
        }
    }
}
