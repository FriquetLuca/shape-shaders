Shader "IkiGraphics/Drawing/RayFromCenterAnim"
{
    Properties
    {
        _Rotation("Rotation Angle", Range(0.0, 360)) = 0.0
        _Speed("Rotation Speed", Float) = 1.0
        _Lines("Lines", Float) = 3.0
        _ColorA("Color A", Color) = (1, 0, 0, 1)
        _ColorB("Color B", Color) = (0, 0, 1, 1)
        _Radius("Circle Radius", Range(0.0, 0.5)) = 0.5
        _InnerStep("Inner Step", Range(0.0, 1.0)) = 0.2
        _ColorInner("Color Inner", Color) = (1, 0, 0, 1)
        _ColorOuter("Color Outer", Color) = (1, 0, 0, 1)
        _CirclePosition("Circle Position", Vector) = (0, 0, 0, 0)
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
            float _Lines, _Rotation, _Speed, _Radius, _InnerStep;
            float2 _CirclePosition;
            float4 _ColorA, _ColorB, _ColorInner, _ColorOuter;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv; // Pass uvs to fragment
                return o;
            }
            #define EPSILON 0.000000001
            #define PI 3.14159265359
            #define TAU 6.28318530718
            #define DEG2RAD 0.0174532925199
            #define RAD2DEG 57.2957795131
            half4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv * 2 - 1;
                float lineMask = LinesFromCenter(mul(matrixRotation2D(_Rotation * DEG2RAD - fmod(_Time.y / _Lines * TAU * _Speed, TAU)), uv), _Lines);
                float diameter = _Radius * 2;
                uv -= _CirclePosition;
                float circleMask = dot(uv, uv) < diameter * diameter;
                float innerMask = step(1.0 - _InnerStep, 1 - length(uv) / diameter);
                float outerMask = (1 - innerMask) * circleMask;
                return lerp(lerp(_ColorA, _ColorB, lineMask), innerMask * _ColorInner + outerMask * _ColorOuter, circleMask);
            }
            ENDCG
        }
    }
}
