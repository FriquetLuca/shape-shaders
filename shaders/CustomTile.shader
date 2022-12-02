Shader "IkiGraphics/Sprites/CustomTile"
{
    Properties
    {
        [NoScaleOffset]_MainTex("Texture", 2D) = "white" {}
        _Width("Width Segments", Float) = 1.0
        _Height("Height Segments", Float) = 1.0
        _Tile("Tile (Left-Up)", Float) = 1.0
        _HSize("Horizontal Size (Right)", Float) = 1
        _VSize("Vertical Size (Down)", Float) = 1
        [Toggle]_InvertH("Invert Horizontal", Float) = 0
        [Toggle]_InvertV("Invert Vertical", Float) = 0
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
            // Select a tile at a position t on a (w, h) grid and get the size of it to map the uvs.
            float2 TileSelector(float2 uv, float tile, float width, float height, float2 selectedSize, float2 invert)
            {
                uv = float2(uv.x, 1 - uv.y); // Remap uv of basic quad
                float2 size = floor(float2(width, height)); // Size of tileset
                float2 tilePos = floor(float2(fmod(tile, size.x), tile / size.y)); // 2D position of the tile
                float2 tileSize = 1.0 / float2(size.x, size.y); // Uv tile size
                float2 start = tilePos; // Rectangle start position
                float2 end = tilePos + selectedSize; // Rectangle end position
                float2 invertedUv = invert * (1 - uv) + (1 - invert) * uv; // Invert if needed for the uv
                float2 result = lerp(start, end, invertedUv) * tileSize; // Lerp the texture segments
                return float2(result.x, -result.y); // Returned uv
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
            sampler2D _MainTex;
            float _Width, _Height, _Tile, _HSize, _VSize, _InvertH, _InvertV;
            float4 _MainTex_ST;
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // Tranforms position from object to homogenous space
                o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw; // Transforms 2D uv by scale/bias property
                return o;
            }
            half4 frag(v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, TileSelector(i.uv, _Tile, _Width, _Height, float2(_HSize, _VSize), float2(_InvertH, _InvertV)));
                return col;
            }
            ENDCG
        }
    }
}
