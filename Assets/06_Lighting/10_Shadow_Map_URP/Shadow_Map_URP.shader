//p. 284-290, pero faltaron un par de cosas por explicar, asi que mejor cheque el shader en el package del libro y lo ajuste respecto a ese

Shader "USB/Shadow_Map_URP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline"="UniversalRenderPipeline" //Indica que el render pipeline del shader sera URP
        }
        LOD 100

        Pass
        {
            Name "Shadow Map"
            Tags
            {
                "LightMode"="UniversalForward" //UniversalForward funciona de forma similar a ForwardBase, su diferencia es como evalua todas las contribuciones de luz en el mismo pass
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            #include "HLSLSupport.cginc"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                // float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                // float3 normal : TEXCOORD1;

                float4 shadowCoord : TEXCOORD2; //Almacena el resultado de la transformacion de vertices de NDC a coordenadas UV de la textura del shadow map
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.normal = TransformObjectToWorldNormal(v.normal);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz); //VertexPositionInputs se encuentra en Core.hlsl y GetVertexPositionInputs() en ShaderVariablesFunctions.hlsl
                o.shadowCoord = GetShadowCoord(vertexInput); //Aqui shadowCoord ya posee las coordenadas para la generacion de la sombra. GetShadowCoord() se encuentra en Shadows.hlsl

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                Light light = GetMainLight(i.shadowCoord); //p. 290. GetMainLight() se encuentra en Lighting.hlsl

                // float3 lightColor = light.color;
                float3 shadow = light.shadowAttenuation;

                fixed4 col = tex2D(_MainTex, i.uv);

                // float3 normal = normalize(i.normal);
                // float NL = dot(light.direction, normal);

                col.rgb *= shadow;
                return col;
            }
            ENDHLSL
        }

        //SHADOW CASTER PASS
        UsePass "Universal Render Pipeline/Lit/ShadowCaster" //Llama el pass ShadowCaster del shader Lit en la ruta Universal Render Pipeline
    }
}