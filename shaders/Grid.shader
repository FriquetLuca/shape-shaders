Shader "IkiGraphics/Drawing/Grid"
{
    Properties
    {
        _Width("Width", Float) = 0.5
        _Height("Height", Float) = 0.5
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
            float Grid(float2 uv, float width, float height)
            {
                float2 tile = fmod(uv * float2(width, height), 2.0) - 1.0;
                float2 smooth = smoothstep(0.0, 1.0 / _ScreenParams.xy, tile);
                return max(smooth.x, smooth.y) - min(smooth.x, smooth.y);
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
            float _Width, _Height;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = Grid(i.uv, _Width, _Height);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
