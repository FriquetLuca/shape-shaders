Shader "IkiGraphics/Drawing/Line"
{
    Properties
    {
        _Width("Width", Range(0, 1)) = 0.1
        _PointA("Point A", Vector) = (0.25, 0.5, 0.0, 0.0)
        _PointB("Point B", Vector) = (0.25, 0.5, 0.0, 0.0)
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
            float _Width;
            float2 _PointA, _PointB;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                _Width = 1.0 / (_Width * 0.5);
                float2 p2p1 = _PointA - _PointB;
                float2 p2p = i.uv - _PointB;
                float2 p1p = i.uv - _PointA;
                float2 pd = normalize(float2(p2p1.y, -p2p1.x));
                float proj = dot(pd, -p1p);
                float pr1 = dot(p2p1, p2p);
                float pr2 = dot(-p2p1, p1p);
                float mul = (pr1 > 0.0) && (pr2 > 0.0) ? 1.0 : 0.0;
                float gradient = 1.0 / abs(proj * _Width);
                half4 col = mul *(1 - smoothstep(0.0, 1.0 / _ScreenParams.x, 1-gradient));//mul * stepping;// smoothstep(0.0, 1.0 / _ScreenParams.x, coord);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
