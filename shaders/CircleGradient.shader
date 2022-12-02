Shader "IkiGraphics/Drawing/CircleGradient"
{
    Properties
    {
        _Tiles("Tiles", Float) = 2.0
        _Scale("Scale", Float) = 2.0
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
            float _Scale, _Tiles;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                float actualX = ceil(i.uv.y * _Tiles);
                float2 tileSize;
                tileSize.x = fmod(i.uv.x * actualX * _Tiles, 1.0);
                tileSize.y = fmod(i.uv.y * actualX * _Tiles, 1.0);
                tileSize = (tileSize - 0.5) * 2;
                float linearColor = dot(tileSize, tileSize) < pow(_Scale, actualX);
                half4 col = linearColor;
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
