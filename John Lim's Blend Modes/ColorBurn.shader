Shader "Blendmodes/ColorBurn"
{
    Properties
    {
        [Header(Properties)]
        _MainTex ("Blend Texture", 2D) = "white" {}
        _Tint1 ("Tint on Texture", Color) = (1,1,1,0)
        _Tint2 ("Tint on Blended Result", Color) = (1,1,1,0)
        _Alpha ("Opacity of Blended Result", Range(0.0, 1.0)) = 1.0

        //blending

        [Header(Blending)]
    		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) = 5
    		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) = 10

        // required for UI.Mask
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
        Tags { "Queue"="Transparent" "IgnoreProjector"="true" "RenderType"="Transparent" }
        LOD 100
        Blend [_BlendSrc] [_BlendDst]

        // required for UI.Mask
        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        GrabPass
        {
            "_BackgroundTexture"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "CGIncludes/PhotoshopBlendModes.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 bguv : TEXCOORD1;
            };

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed4 _Tint1;
            fixed4 _Tint2;
            fixed _Alpha;

            sampler2D _BackgroundTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                o.bguv = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainColor = tex2D(_BackgroundTexture, i.bguv);
                fixed4 blendColor = tex2D(_MainTex, i.uv) * i.color;
                blendColor.xyz += _Tint1.xyz * _Tint1.a;


                // perform blend
                mainColor.xyz = ColorBurn(mainColor.xyz, blendColor.xyz);
                mainColor.xyz += _Tint2.xyz * _Tint2.a;
                mainColor.a = blendColor.a * _Alpha;

                return mainColor;
            }
            ENDCG
        }
    }
}
