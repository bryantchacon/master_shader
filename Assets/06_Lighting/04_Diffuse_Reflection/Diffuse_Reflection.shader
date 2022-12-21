Shader "USB/Diffuse_Reflection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInt ("Light Intensity", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase" //Dado que el shader interactua con una fuente de iluminacion el LightMode se configura en FowardBase y asi el render path queda configurado
        }
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
                float3 normal_world : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _LightInt;
            float4 _LightColor0; //_LightColor[n] es una variable interna que se refiere al color de la iluminacion en la escena (o sea, el color de la luz), se declara como variable uniforme aqui, sin que provenga de una propiedad

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz; //Calcula las normales en World-Space, se guardan solo sus vectores .xyz porque normal_world es un vector de 3 dimensiones

                return o;
            }

            //FUNCION PARA CALCULAR REFLEXION DIFUSA (p. 221)
            float3 DiffuseReflection(float3 colorRefl, float lightInt, float3 normal, float3 lightDir)
            {
                return colorRefl * lightInt * max(0, dot(normal, lightDir));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                fixed3 colorRefl = _LightColor0.rgb; //Para poder usar _LightColor[n](en este caso 0), como primer parametro en la funcion LambertShading() hay que declarar un vector de 3 dimensiones, guardarlo ahi y solo usar sus canales RGB
                float3 normal = i.normal_world;
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //_WorldSpaceLightPos[n](en este caso 0), es otra variable interna la cual se refiere a la direccion de la iluminacion en World-Space y a diferencia de _LightColor[n] no es necesario declararla como vector uniforme en el area de variables de coneccion ya que viene inicializada en UnityCG.cginc, asi que se puede usar directamente aqui no sin antes guardarla en una variable de 3 dimensiones, normalizarla y especificar que solo se usaran sus coordenadas xyz
                half3 diffuse = DiffuseReflection(colorRefl, _LightInt, normal, lightDir);
                col.rgb *= diffuse;

                return col;
            }
            ENDCG
        }
    }
}