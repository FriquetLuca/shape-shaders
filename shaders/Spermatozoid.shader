Shader "IkiGraphics/Drawing/Spermatozoid"
{
    Properties
    {
        _Position("Position", Vector) = (0.0, 0.0, 0.0, 0.0)
        _Rotation("Rotation", Range(0.0, 360)) = 0.0
        _Scale("Scale", Range(0.0, 1.0)) = 1.0
        _Radius("Radius", Range(0.0, 0.5)) = 0.1
        _TailThickness("Tail Thickness", Range(0.0, 0.5)) = 0.025
        _Speed("Speed", Float) = 1.0
        _TailWaves("Tail Waves", Float) = 1.0
        _TailWaveHeight("Tail Wave Height", Range(0.0, 1.0)) = 1.0
        _EndTailFixed("End Tail Fixed", Range(0.0, 1.0)) = 0.5
        _EyeSize("Eye Size", Vector) = (0.01, 0.01, 0.0, 0.0)
        _EyePosition("Eye Position", Vector) = (0.0, 0.0, 0.0, 0.0)
        _EyeColor("Eye color", Color) = (0.1, 0.2, 0.8, 1.0)
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
            float _Radius, _TailThickness, _Speed, _TailWaves, _EndTailFixed, _TailWaveHeight, _Rotation, _Scale;
            float2 _Position, _EyeSize, _EyePosition;
            float3 _EyeColor;
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
            float4 Spermatozoid(float2 uv, float2 position, float rotationAngle, float2 scale, float radiusHead, float2 eyeSize, float2 eyePosition, float3 eyeColor, float tailThickness, float animationSpeed, float tailWaves, float tailWaveHeight, float endTailFixed)
            {
                uv = mul(matrixRotation2D(rotationAngle * DEG2RAD), uv - (0.5 + position)) / scale + 0.5;
                float2 polar = (uv - 0.5) * 2.0;
                float xOffset = 1.0 - radiusHead;
                float2 circlePosition = float2(xOffset - polar.x, polar.y);
                float tailArea = step(EPSILON, circlePosition.x);
                float size = 1.0 - radiusHead * 0.5;
                float tail01 = fmod(uv.x, size) / size;
                float time = fmod(_Time.y * TAU * animationSpeed, TAU);
                float tailSize = tail01 * endTailFixed + 1 - endTailFixed;
                float remapWaves = tailWaves * TAU;
                float tailAnim = 0.25 * tailSize * tailWaveHeight * sin(tail01 * remapWaves + time) + 0.5;
                circlePosition.y -= 0.5 * tailWaveHeight * sin(remapWaves + time);
                float2 eyeActualSize = min(radiusHead * 0.5, eyeSize);
                float2 eyeActualPosition = float2(circlePosition.x + eyeActualSize.x * 0.5 + eyePosition.x, circlePosition.y + eyeActualSize.y * 0.5 - eyePosition.y);
                float circleMask = dot(circlePosition, circlePosition) < radiusHead * radiusHead;
                tailThickness = min(tailThickness, radiusHead) * tail01 * 0.5;
                float tailTop = 1.0 - (uv.y > (tailAnim + tailThickness));
                float tailBottom = uv.y > (tailAnim - tailThickness);
                float bodyMask = max(tailArea * tailTop * tailBottom, circleMask);
                float eyeMask = 1.0 - smoothstep(0.0, 1.0 / _ScreenParams.x, (length(eyeActualPosition / eyeActualSize) - 1));
                float currentMask = max(bodyMask, eyeMask);
                return half4(lerp(currentMask, eyeMask * eyeColor, eyeMask), currentMask);
            }
            half4 frag(v2f i) : SV_Target
            {
                return Spermatozoid(i.uv, _Position, _Rotation, _Scale, _Radius, _EyeSize, _EyePosition, _EyeColor, _TailThickness, _Speed, _TailWaves, _TailWaveHeight, _EndTailFixed);
            }
            ENDCG
        }
    }
}
