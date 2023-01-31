Shader "USB/Alpha_Channel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color Texture", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent" //Activa el canal alpha, paso 1/3
            "Queue"="Transparent" //Activa el canal alpha, paso 2/3
        }
        Blend SrcAlpha OneMinusSrcAlpha //Blending normal, activa el canal alpha, paso 3/3

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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            //EJEMPLO DE FUNCION TIPO void (p. 124)
            /*
            void FakeLight_float (in float3 Normal, out float3 Out)
            {
                float[n] operation = Normal;
                Out = operation;
            }

            En una funcion de tipo void hay que declarar la precision de esta, los inputs y el output o no compilara:
            • _float al final del nombre de la funcion (o dependiendo del tipo de esta) es la precision de la funcion
            • in al inicio de los inputs. NOTA: AL PARECER ACTUALMENTE YA NO ES NECESARIO ESCRIBIRLO
            • out al inicio del output

            Codigo que iria en el fragment shader:
            float3 n = i.normal;
            float3 col = 0;
            FakeLight_float (n, col);
            return float4(col.rgb, 1);
            */

            //EJEMPLO DE FUNCION CON return (p. 126)
            /*
            float3 FakeLight (float3 Normal)
            {
                float3 operation = Normal;
                return = operation;
            }

            En este tipo de funcion no es necesario declarar su precision, los inputs ni el output.

            Codigo que iria en el fragment shader:
            float3 n = i.normal;
            float3 col = FakeLight(n); //El resultado se puede asignar directamente a una variable, igual que en C#
            return float4(col.rgb, 1);
            */

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col * _Color; //Para agregar color a una textura basta con multiplicarlo por esta
            }
            ENDCG
        }
    }
}