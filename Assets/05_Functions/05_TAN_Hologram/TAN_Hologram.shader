Shader "USB/TAN_Hologram"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Frequency ("Frequency", Range(1, 30)) = 15
        _Speed ("Speed", Range(0, 5)) = 1
    }
    SubShader
    {
        //Como el color negro sera detectado como alpha(transparencia) se deben agregar los tags y blend necesarios para ello
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        Blend SrcAlpha One //Blend aditivo

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
            float4 _Color;
            float _Frequency;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 hologram = clamp(0, abs(sin((i.uv.y - _Time.x * _Speed) * _Frequency)) + 0.2, 1) * _Color; //Con tan() da bordes rigidos, con sin() bordes con cierta difuminacion
                /*
                1. clamp() limita que los valores que da no sean menores a 0 y mayores a 1
                2. abs() solo regresa numeros positivos
                3. Se le resta _Time.x para agregar movimiento hacia arriba, si se sumara seria hacia abajo
                4. Se multiplica por _Speed es para controlar la velocidad desde el inspector
                5. Se multiplica por _Frequency para poder controlar la cantidad de lineas del efecto desde el inspector
                6. Se le suma 0.2 para aumentar el ancho de las lineas del efecto
                7. Todo multiplicado por _Color para añadirselo
                */

                fixed4 col = tex2D(_MainTex, i.uv) * hologram; //Para agregar el efecto este se multiplica por la textura

                return col;
            }
            ENDCG
        }
    }
}