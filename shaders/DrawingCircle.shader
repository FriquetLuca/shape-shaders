Shader "IkiGraphics/Drawing/DrawingCircle"
{
    Properties
    {
        _RadiusA("Circle Radius A (uvs)", Range(0, 1)) = 0.5
        _RadiusB("Inner Circle (uvs)", Range(0, 1)) = 0.5
        _Intensity("Circle Fading Intensity", Range(0.000000000000000000001, 10)) = 1.0
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
            #include "../../../../../IkiFramework/IkiGraphics/IkiUnity/CGinc/IkiLibrary.cginc"
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
            float _RadiusA, _RadiusB, _Intensity;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = CircleDrawer(i.uv * 2 - 1, _RadiusA, _RadiusB, _Intensity);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
