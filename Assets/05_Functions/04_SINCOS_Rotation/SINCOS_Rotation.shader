Shader "USB/SINCOS_Rotation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Rotation Speed", Range(0, 3)) = 1
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
            float _Speed;

            //Funcion de rotacion
            float3 rotation(float3 vertex)
            {
                //Variables de rotacion usando cos(graficamente la curva inica en 1) y sin(graficamente la curva inica en 0). _Time es una variable interna y lo que hace es agregar tiempo a la operacion, es similar a Time.deltaTime en C# y al multiplicarlo por _Speed se puede modificar la velocidad desde el inspector
                float c = cos(_Time.y * _Speed);
                float s = sin(_Time.y * _Speed);

                //Variables aplicadas para rotar en x
                float3x3 mX = float3x3
                (
                    1, 0, 0,
                    0, c, -s,
                    0, s, c
                );

                //Variables aplicadas para rotar en y
                float3x3 mY = float3x3
                (
                    c, 0, s,
                    0, 1, 0,
                    -s, 0, c
                );

                //Variables aplicadas para rotar en z
                float3x3 mZ = float3x3
                (
                    c, -s, 0,
                    s, c, 0,
                    0, 0, 1
                );

                return mul(vertex, mul(mZ, mul(mX, mY)));
                // return mul(mul(mul(mX, mY), mZ), vertex);
            }

            v2f vert (appdata v)
            {
                v2f o;
                float3 rotVertex = rotation(v.vertex); //Uso de la funcion rotation antes de UnityObjectToClipPos()
                o.vertex = UnityObjectToClipPos(rotVertex); //El resultado de la funcion se pasa como parametro a UnityObjectToClipPos()
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}