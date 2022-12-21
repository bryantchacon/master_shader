Shader "USB/Fresnel_Effect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(FRESNEL PROPERTIES)]
        [Space(10)]
        _FresnelPow ("Power", Range(1, 5)) = 1 //Valor exponencial; a menor cantidad mas efecto, a mayor, menos efecto
        _FresnelInt ("Intensity", Range(0, 1)) = 1 //Intensidad del efecto
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal_world :TEXCOORD1;
                float3 vertex_world :TEXCOORD2; //Guarda la direccion de la vista
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FresnelPow;
            float _FresnelInt;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz; //Calcula las normales en World-Space
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex); //Calcula la direccion de la vista en World-Space 1/2
                
                return o;
            }

            //FUNCION PARA CALCULAR EL EFECTO FRESNEL
            void unity_FresnelEffect_float(float3 normal, float3 viewDir, float power, out float Out) //p. 253-255
            {
                Out = pow((1 - saturate(dot(normal, viewDir))), power);
                /*
                • dot(): Determina el angulo entre la vision de la vista y las normales del objeto
                • saturate(): Limita el resultado de dot() entre 0.0f y 1.0f
                • 1 - x: Voltea el resultado debido a que cuando la vision de la vista y las normales del objeto son paralelas el resultado de dot() retornara 1.0f(blanco) pero en este caso se necesita que sea 0.0f que equivale al color negro que se traduce en ausencia de color, o sea, el objeto no tendra efecto frensel en el area que mire a la camara
                • pow(): Permite aumentar o disminuir la cantidad del efecto por medio del valor de power como exponente, a menor cantidad mas efecto, a mayor, menos efecto
                */
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 normal = i.normal_world;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world); //Calcula la direccion de la vista en World-Space 2/2
                float fresnel = 0;
                unity_FresnelEffect_float(normal, viewDir, _FresnelPow, fresnel);
                col += fresnel * _FresnelInt;

                return col;
            }
            ENDCG
        }
    }
}