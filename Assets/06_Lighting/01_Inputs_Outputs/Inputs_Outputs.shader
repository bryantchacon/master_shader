//EN ESTE SHADER SE EXPLICA LA CONECCION DE INPUTS CON OUTPUTS PARA EL CALCULO DE NORMALES

Shader "USB/Inputs_Outputs"
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
                float3 normal : NORMAL; //NORMAL da acceso a las normales
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1; //Segun la documentacion oficial de HLSL no existe la semantica NORMAL para el fragment shader, por eso se usa la semantica TEXCOORD[n] porque puede almacenar al menos tres coordenadas de espacio y es TEXCOORD1 porque uv ya esta ocupando TEXCOORD0. Esto se menciona porque primero se conectan ambas propiedades en el vertex shader para luego pasarlas al fragment shader(normals)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            //Funcion para pasar las normales de object space a world space. Esta arriba del vertex shader porque se usara en el, ya que esto es un nivel de optimizacion al hacerse el calculo aqui(por vertice) y no el el fragment shader(por pixel)
            half3 normalWorld(half3 normal)
            {
                return normalize(mul(unity_ObjectToWorld, float4(normal, 0))).xyz; //El 0 es porque las normales son una DIRECCION en el espacio
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = normalWorld(v.normal);
                return o;
            }

            //Ejemplo ficticio de una funcion que calcula la luz
            void unityLight_float3(float3 norm, out float3 Out)
            {
                Out = norm;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half3 normals = i.normal; //Se guardan las normales en un vector
                half3 light = 0; //Se inicia la luz en 0
                unityLight_float3(normals, light); //Se usa la funcion unityLight_float3() y se le pasan las variables anteriores como parametro
                return float4(light.rgb, 1); //Se retorna light con los calculos ya hechos (debido a que es el output de unityLight_float3()), especificando sus canales .rgb y el 1 es porque son una POSICION en el espacio
            }
            ENDCG
        }
    }
}