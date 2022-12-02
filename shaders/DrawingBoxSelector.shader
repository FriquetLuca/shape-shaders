Shader "IkiGraphics/Drawing/DrawingBoxSelector"
{
    Properties
    {
        _Depth("Depth", Float) = 0.5
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
            float BoxSelectorDrawer(float2 uv, float depth)
            {
                float2 remapUvs = abs(uv); // Remap uvs to have the circle drawn from the center
                float intensity = pow(max(remapUvs.x, remapUvs.y), depth);
                float alpha = smoothstep(0, 1, 1 - intensity);
                return saturate(0.995 - alpha) + 0.02;
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
            float _Depth;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = BoxSelectorDrawer(i.uv * 2 - 1, _Depth);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
