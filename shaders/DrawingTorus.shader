Shader "IkiGraphics/Drawing/DrawingTorus"
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
            float TorusDrawer(float2 uv, float outerRadius, float innerRadius, float fadingIntensity)
            {
                float uvsLength = length(uv); // length of the uvs in the range [0; sqrt(2)]
                float radiusA = outerRadius; // Radius of circle A
                float radiusB = abs(innerRadius - outerRadius); // Radius of the circle B, using _RadiusB as the distance from _RadiusA to center
                float circleA = step(uvsLength, outerRadius); // [0;1] => Draw the circle (0 = No circle, 1 = circle)
                float circleB = step(uvsLength, radiusB); // [0;1] => Draw the circle (0 = No circle, 1 = circle)
                float absDiffCircle = abs(circleB - circleA); // Donut Mask between circleA and circleB
                float circleBorders = 1 - saturate(saturate(uvsLength - radiusB) / innerRadius); // Remap the uvs to the distance of the circle A and B borders in the range [0;1]
                float sliceSmooth = abs(circleBorders - 0.5) * 2; // Slice the fading border in two part for the torus
                float intensity = 1 - pow(smoothstep(0, 1, sliceSmooth), fadingIntensity); // Intensity of the fading mask
                return absDiffCircle * intensity;
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
                half4 col = TorusDrawer(i.uv * 2 - 1, _RadiusA, _RadiusB, _Intensity);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
