﻿Shader "IkiGraphics/Drawing/MultiRing"
{
    Properties
    {
        _RadiusA("Radius A", Float) = 0.1
        _RadiusB("Radius B", Float) = 0.1
        _Scale("Scale", Float) = 0.1
        _Offset("Offset", Vector) = (0.5, 0.5, 0.0, 0.0)
        _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "CanUseSpriteAtlas" = "True"
        }
        LOD 200
        Cull Off
        Lighting Off
        ZWrite Off
        Fog { Mode Off }
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            float MultiRing(float2 uv, float2 center, float scale, float radiusA, float radiusB)
            {
                float2 delta = uv - center;
                float radius = length(delta) * 2;
                float angle = atan2(delta.x, delta.y) * 0.159154943092;
                float2 polarCoord = float2(radius, angle);
                float coord = fmod(polarCoord * scale, radiusA + radiusB);
                float smoothA = smoothstep(0.0, 1.0 / _ScreenParams.x, coord - radiusA);
                float smoothB = smoothstep(0.0, 1.0 / _ScreenParams.x, coord);
                return smoothA + 1 - smoothB;
            }
            struct appdata
            {
                float4 vertex : POSITION; // Object position
                float2 uv : TEXCOORD0; // Uv 0
            };
            struct v2f
            {
                float4 vertex : SV_POSITION; // Object homogenous position
                float2 uv : TEXCOORD0; // Uv 0
            };
            float _Scale, _RadiusA, _RadiusB;
            float2 _Offset;
            half4 _Color;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = MultiRing(i.uv, _Offset, _Scale, _RadiusA, _RadiusB);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
