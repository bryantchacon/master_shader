Shader "USB/ABS_Kaleidoscope"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rotation ("Rotation", Range(0, 360)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Rotation;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            void Unity_Rotate_Degrees_float(float2 UV, float Center, float Rotation, out float2 Out)
            {
                Rotation *= UNITY_PI/180.0f;
                UV -= Center;
                float s = sin(Rotation);
                float c = cos(Rotation);
                float2x2 rMatrix = float2x2(c, -s, s, c);
                rMatrix *= 0.5;
                rMatrix += 0.5;
                rMatrix = rMatrix * 2 - 1; //No se puede optimizar con *=, si se hace el efecto no queda
                UV.xy = mul(UV.xy, rMatrix);
                UV += Center;
                Out = UV;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float u = abs(i.uv.x - 0.5);
                float v = abs(i.uv.y - 0.5);
                float center = 0.5;
                float rotation = _Rotation;
                // float rotation = _Time.y * 50; //Codigo alternativo a float rotation = _Rotation, da movimiento automatico y no usa la propiedad _Rotation
                float2 uv = 0;

                Unity_Rotate_Degrees_float(float2(u, v), center, rotation, uv);

                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}