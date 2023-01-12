Shader "USB/TIME_SINTIME_COSTIME"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //Valores de _Time
                /*
                _Time.x = t / 20;
                _Time.y = t;
                _Time.z = t * 2;
                _Time.w = t * 3;
                */

                //Valores de _SinTime
                /*
                _SinTime.x = t / 8;
                _SinTime.y = t / 4;
                _SinTime.z = t / 3;
                _SinTime.w = t; //Igual a sin(_Time.y)
                */

                //Valores de _CosTime
                /*
                _CosTime.x = t / 8;
                _CosTime.y = t / 4;
                _CosTime.z = t / 3;
                _CosTime.w = t; //Igual a cos(_Time.y)
                */

                // i.uv.x += _Time.y; //Agrega animacion de desplazamiento en la coordenada U de las UVs

                //Agregan animacion de rotacion en las coordenadas UV
                i.uv.x += _SinTime.w;
                i.uv.y += _CosTime.w;

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}