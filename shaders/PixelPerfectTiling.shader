Shader "IkiGraphics/Sprites/PixelPerfectTiling"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _TileRows("Tile Rows", Range(1, 100)) = 1
        _TileColumns("Tile Columns", Range(1, 100)) = 1
        _TargetTile("Target Tile", Range(0, 100)) = 0
        _Color("Tint", Color) = (1, 1, 1, 1)
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

        Cull Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST, _MainTex_TexelSize, _Color;
            float _TargetTile, _TileRows, _TileColumns;

            float2 tileCoord(float currentTile, float rows, float columns, float2 uv)
            {
                float currentTileFixed = fmod(currentTile, columns * rows);

                float tileWidth = 1.0 / columns;
                float tileHeight = 1.0 / rows;

                float tileX = floor(fmod(currentTileFixed, columns)) * tileWidth;
                float tileY = floor(currentTileFixed / columns) * tileHeight;

                return uv * float2(tileWidth, tileHeight) + float2(tileX, tileY);
            }

            float4 pixelTex2D(sampler2D tex, float2 uv, float4 texel)
            {
                uv -= float2(texel.x, texel.y) * float2(0.5, 0.5);
                float2 uvPixels = uv * float2(texel.z, texel.w);
                float2 deltaPixel = frac(uvPixels) - float2(0.5, 0.5);

                float2 ddxy = fwidth(uvPixels);
                float2 mip = log2(ddxy) - 0.5;

                float2 clampedUV = uv + (clamp(deltaPixel / ddxy, 0.0, 1.0) - deltaPixel) * float2(texel.x, texel.y);
                return tex2Dlod(tex, float4(clampedUV, 0, min(mip.x, mip.y)));
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uvs = tileCoord(_TargetTile, _TileRows, _TileColumns, i.uv);
                float4 tex = pixelTex2D(_MainTex, uvs, _MainTex_TexelSize);
                float4 col = tex * _Color;
                return col;
            }

            ENDCG
        }
    }
}