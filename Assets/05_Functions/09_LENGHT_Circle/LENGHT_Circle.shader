Shader "USB/LENGHT_Circle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Range(0.0, 0.5)) = 0.3
        _Center ("Center", Range(0, 1)) = 0.5
        _Smooth ("Smooth", Range(0.0, 0.5)) = 0.01
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
            float _Radius;
            float _Center;
            float _Smooth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            //FUNCION PARA CREAR UN CIRCULO
            float circle(float2 uvs, float center, float radius, float smooth)
            {
                float c = length(uvs - center); //length() retorna la distancia entre dos puntos (por eso se guarda en una variable float de una dimension), principalmente se usa para generar circulos (como en este caso), y centrarlo en las UVs, pero tambien se puede usar para crear poligonos con los bordes redondeados
                return smoothstep(c - smooth, c + smooth, radius); //Controla el radio del circulo(por radius) y suaviza su borde. smoothstep() retorna un valor de una sola dimension, por eso se puede usar en el return, porque la funcion es de tipo float
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float cir = circle(i.uv, _Center, _Radius, _Smooth);

                return float4(cir.xxx, 1); //Se usa .xxx como sustitutos de .xyz porque cir es de una sola dimension y la funcion debe retornar un valor de 4 dimensiones, el 1 es por que el vector es una posicion en el espacio
            }
            ENDCG
        }
    }
}