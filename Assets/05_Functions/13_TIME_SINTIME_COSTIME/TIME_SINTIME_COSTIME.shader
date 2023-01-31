Shader "USB/TIME_SINTIME_COSTIME"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(X AND Y MOVEMENT)]
        [Space(10)]
        [Toggle] _xMov ("X", Float) = 0
        [Toggle] _yMov ("Y", Float) = 0
        _movSpeed ("Movement Speed", Range(-1, 1)) = 1
        [Header(X AND Y SWAY)]
        [Space(10)]
        [Toggle] _xSway ("X", Float) = 0
        [Toggle] _ySway ("Y", Float) = 0
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

            //Pragmas de los toggles de movimiento y vaiven
            #pragma shader_feature _XMOV_ON
            #pragma shader_feature _YMOV_ON
            #pragma shader_feature _XSWAY_ON
            #pragma shader_feature _YSWAY_ON

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
            float _movSpeed;

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

                //Activar estas dos opciones da animacion de desplazamiento en diagonal hacia las coordenadas 1, 1
                #if _XMOV_ON
                    i.uv.x += _Time.y * _movSpeed; //Da animacion de desplazamiento en la coordenada U de las UVs, si el valor de _movSpeed es negativo el sentido del movimiento se invierte
                #endif

                #if _YMOV_ON
                    i.uv.y += _Time.y * _movSpeed;
                #endif

                //Activar estas dos opciones da animacion de rotacion en las coordenadas UV
                #if _XSWAY_ON
                    i.uv.x += _SinTime.w; //Da movimiento de vaiven en la coordenada U de las UVs
                #endif
                #if _YSWAY_ON
                    i.uv.y += _CosTime.w;
                #endif

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}