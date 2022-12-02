Shader "IkiGraphics/Drawing/HorizontalLines"
{
    Properties
    {
        _Slices("Lines", Float) = 2.0
        _Angle("Rotation (Degrees)", Range(0.0, 90.0)) = 0.0
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
            #include "../../../../IkiFramework/IkiGraphics/IkiUnity/CGinc/IkiLibrary.cginc"
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
            float _Slices, _Angle;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                float slicedUvs = fmod(_Slices * mul(matrixRotation2D(1.57079632679 - _Angle * 0.0174532925199), i.uv).x, 1.0);
                half4 col = slicedUvs;
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
