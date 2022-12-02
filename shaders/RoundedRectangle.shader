Shader "IkiGraphics/Drawing/Rounded Rectangle"
{
    Properties
    {
        _Width("Width", Float) = 0.5
        _Height("Height", Float) = 0.5
        _Radius("Radius", Float) = 0.1
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
            float RoundRect(float2 uv, float2 size, float radius)
            {
                size -= radius;
                float2 d = abs(uv) - size;
                float rRect = min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - radius;
                return 1 - smoothstep(0.0, 1.0 / _ScreenParams.x, rRect);
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
            float _Width, _Height, _Radius;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = RoundRect((i.uv * 2 - 1), float2(_Width, _Height), _Radius);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
