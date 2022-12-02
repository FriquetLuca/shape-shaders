Shader "IkiGraphics/Drawing/Capsule"
{
    Properties
    {
        _Radius("Radius", Float) = 0.25
        _Height("Height", Float) = 1.0
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
            float Capsule(float2 uv, float height, float radius)
            {
                float2 heiUp = float2(0, 0.25) * height;
                float2 pa = uv - heiUp, ba = (-2) * heiUp;
                float h = saturate(dot(pa, ba) / dot(ba, ba));
                float capsule = length(pa - ba * h) - radius;
                return 1.0 - smoothstep(0.0, 1.0 / _ScreenParams.x, capsule);
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
            float _Radius, _Height;
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
                half4 col = Capsule(i.uv - _Offset, _Height, _Radius);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
