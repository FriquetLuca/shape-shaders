Shader "IkiGraphics/Drawing/Ring"
{
    Properties
    {
        _Radius("Radius", Float) = 0.5
        _Width("Width", Float) = 0.1
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
            float Ring(float2 uv, float radius, float width)
            {
                float ring = abs(length(uv) - radius * 0.5) - width;
                return 1.0 - smoothstep(0.0, 1.0 / _ScreenParams.x, ring);
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
            float _Radius, _Width;
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
                half4 col = Ring(i.uv - _Offset, _Radius, _Width);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
