Shader "IkiGraphics/Drawing/Star"
{
    Properties
    {
        _Width("Star Width", Range(0.15, 35)) = 0.15
        _Height("Star Height", Range(1, 1.25)) = 1.0
        _Intensity("Star Intensity", Range(0.000000000000001, 20)) = 1.0
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
            float Star(float2 uv, float width, float height, float intensity)
            {
                float baseBlendMul = height; // [1; 1.25] Height
                float opacityBlendSub = width; // [0.15; 35] Width
                uv = abs(uv); // Anchor transformation, uv in the range [-1; 1]
                float2 blendMul = 1.0 - lerp(baseBlendMul, baseBlendMul * uv, 0.15);
                float2 blendSub = lerp(blendMul, blendMul - uv.yx, opacityBlendSub);
                float2 starArraw = blendSub * 4.0;
                float star = saturate(max(starArraw.x, starArraw.y));
                return smoothstep(0.0, 1.0 / _ScreenParams.x, star * 0.1);;
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
            float _Width, _Height, _Intensity;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = Star(i.uv * 2 - 1, _Width, _Height, _Intensity);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
