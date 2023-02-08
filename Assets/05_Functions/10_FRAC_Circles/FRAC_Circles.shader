Shader "USB/FRAC_Circles"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(CIRCLES PROPERTIES)]
        [Space(10)]
        [IntRange]_Quantity ("Quantity", Range(1, 5)) = 3 //Al agregar el MPD [IntRange] al inicio, el slider sera en enteros
        _Size ("Size", Range(0.0, 0.5)) = 0.3
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
            float _Size;
            float _Quantity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv *= _Quantity; //Define las repeticiones que tendra la textura
                float2 fuv = frac(i.uv); //frac() devuelve los decimales de un numero; lo que hace aqui es definir que cada repeticion de la textura sea del tamaño que le corresponde en las UV, segun la cantidad de repeticiones que se indiquen, por ejemplo, si son 3 repeticiones seria; 1 / 3 = 0.33, cada repeticion tendria un tamaño de 0.33 en ambas coordenadas
                float circle = length(fuv - 0.5); //0.5 es la posicion en diagonal de cada circulo
                float wCircle = floor(_Size / circle);

                return float4(wCircle.xxx, 1);
            }
            ENDCG
        }
    }
}