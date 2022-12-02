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
            float CircleDrawer(float2 uv, float radius, float borderRadius, float fadingIntensity)
            {
                float uvsLength = length(uv); // length of the uvs in the range [0; sqrt(2)]
                float radiusB = abs(borderRadius - radius); // Radius of the circle B, using _RadiusB as the distance from _RadiusA to center
                float circleBorders = 1 - saturate(saturate(uvsLength - radiusB) / borderRadius); // Remap the uvs to the distance of the circle A and B borders in the range [0;1]
                return pow(smoothstep(0, 1, circleBorders), fadingIntensity); // Intensity of the fading mask
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
