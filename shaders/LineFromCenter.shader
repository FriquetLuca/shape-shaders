Shader "IkiGraphics/Drawing/LineFromCenter"
{
    Properties
    {
        _Lines("Number Of Lines", Float) = 3
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
            float LinesFromCenter(float2 uv, float lines)
            {
                float remapAtan01 = atan2(uv.x, uv.y) * 0.159154943092 + 0.5; // 0.159154943092 = 1 / tau
                float sliceWorld = fmod(lines * remapAtan01, 1.0);
                float smoothA = 1.0 - smoothstep(0.0, 1.0 / _ScreenParams.x, sliceWorld - 0.5);
                float smoothB = 1.0 - smoothstep(0.0, 1.0 / _ScreenParams.x, sliceWorld);
                return smoothA - smoothB;
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
            float _Lines, _Rotation, _Speed;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = LinesFromCenter(i.uv * 2 - 1, _Lines);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
