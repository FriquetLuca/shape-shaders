Shader "IkiGraphics/Drawing/DrawingLine"
{
    Properties
    {
        _Length("Line Length", Range(0, 1)) = 0.5
        _Thickness("Line Thickness", Range(0, 1)) = 0.1
        _AliasingBorder("Border Aliasing", Range(0.000000000000001, 0.5)) = 0.1
        _Intensity("Fade Intensity", Range(0, 20)) = 0.75
        _Angle("Line Angle", Range(0, 6.28318530718)) = 0.5
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
            float2x2 matrixRotation2D(float angle)
            {
                float ac = cos(angle);
                float as = sin(angle);
                return float2x2(ac, as, -as, ac);
            }
            float LineDrawer(float2 uv, float length, float rotation, float thickness, float fadeIntensity, float borderAliasing)
            {
                float2 remapUvs = mul(uv, matrixRotation2D(rotation)); // Do a rotation
                float px0 = 1 - saturate(abs(remapUvs.x) - (thickness - borderAliasing)) / borderAliasing; // Horizontal fading
                float py0 = 1 - saturate(saturate(remapUvs.y) - (length - borderAliasing)) / borderAliasing; // Top fading
                float py1 = saturate(remapUvs.y / borderAliasing); // Bottom fading
                float2 rect = float2(step(abs(remapUvs.x), thickness), step(remapUvs.y, length) * step(0, remapUvs.y)); // Selected rectangle area
                return saturate(pow(min(py0 * py1, px0), fadeIntensity)) * rect.x * rect.y;
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
            float _Length, _Angle, _Thickness, _Intensity, _AliasingBorder;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = LineDrawer(i.uv * 2 - 1, _Length, _Angle, _Thickness, _Intensity, _AliasingBorder);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
