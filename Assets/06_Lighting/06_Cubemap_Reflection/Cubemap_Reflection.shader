Shader "USB/Cubemap_Reflection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(CUBEMAP REFLECTION PROPERTIES)]
        [Space(10)]
        _ReflectionTex ("Reflection Texture", Cube) = "white" {}
        _ReflectionInt ("Intensity", Range(0, 1)) = 1
        _ReflectionMet ("Metallic", Range(0, 1)) = 0 //Se usa para controlar el brillo de la reflexion y asi emular una superficie metalica
        _ReflectionDet ("Detail", Range(1, 9)) = 1
        _ReflectionExp ("Exposure", Range(1, 3)) = 1
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
                float3 normal_world : TEXCOORD1; //Guarda las normales ya transformadas en World-Space
                float3 vertex_world : TEXCOORD2; //Guarda la direccion de la vista
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            samplerCUBE _ReflectionTex; //El sampler de un cubemap es samplerCUBE(tiene 3 dimensiones)
            float _ReflectionInt;
            half _ReflectionDet;
            float _ReflectionExp;
            float _ReflectionMet;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            /*
            • colorRefl: Cubemap
            • reflectionInt: Intensidad de la reflexion
            • reflectionDet: Nivel de detalle de la reflexion (densidad de texeles, se usa en la coordenada w)
            • normal: Normales
            • viewDir: Direccion de la vista
            • reflectionExp: Exposicion de color
            */
            float3 AmbientReflection(samplerCUBE colorRefl, float reflectionInt, half reflectionDet, float3 normal, float3 viewDir, float reflectionExp)
            {
                float3 reflection_world = reflect(viewDir, normal); //Calcula la reflexion y que no se vea volteada
                float4 cubemap = texCUBElod(colorRefl, float4(reflection_world, reflectionDet)); //Muestreo de la textura (p. 247), reflection_world equivale a las coordenadas xyz (rgb), y reflectionDet a la w (a)

                return reflectionInt * cubemap.rgb * (cubemap.a * reflectionExp);
            }

            //Para asignar una textura al objeto hay que convertirla (ya sea Skybox o 360) a Cube; se selecciona > Inspector > Texture Shape > Cube > Apply, los calculos en este Fragment Shader generan MAYOR CONTROL EN EL RESULTADO FINAL
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                half3 normal = i.normal_world;
                half3 viewDir = normalize(UnityWorldSpaceViewDir(i.vertex_world));
                half3 reflection = AmbientReflection(_ReflectionTex, _ReflectionInt, _ReflectionDet, normal, -viewDir, _ReflectionExp); //viewDir es negativo para que la reflexion funcione correctamente, si no, se veria volteada como si se reflejara en un espejo concavo
                col.rgb *= reflection + _ReflectionMet;

                return col;
            }

            //El proceso con la funcion AmbientReflection() se puede resumir usando el macro UNITY_SAMPLE_TEXCUBE, ya que este asigna de manera automatica la reflexion ambiental que se encuentre configurada en la escena, es decir, si en la ruta Window > Rendering > Lighting (ventana) > Enviroment > Skybox Material, hay un Skybox asignado, la reflexion se guarda como textura dentro del shader y se usa al instante sin necesidad de generar una textura Cubemap de forma independiente (p. 251), este tipo de reflexion (este Fragment Shader) es mas facil de implementar PERO GENERA MENOR CONTROL EN EL RESULTADO FINAL
            // fixed4 frag (v2f i) : SV_Target
            // {
            //     fixed4 col = tex2D(_MainTex, i.uv);
            //     half3 normal = i.normal_world;
            //     half3 viewDir = normalize(UnityWorldSpaceViewDir(i.vertex_world));
            //     half3 reflect_world = reflect(-viewDir, normal); //Calcula la reflexion y que no se vea volteada
            //     half4 reflectionData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, reflect_world); //unity_SpecCube[n] contiene la data del componente Reflection Probe el cual actua como una camara que captura una vista esferica de su entorno en todas las direcciones (p. 242), el macro UNITY_SAMPLE_TEXCUBE samplea esta data siguiendo las coordenadas de relfexion y al final...
            //     half3 reflectionColor = DecodeHDR(reflectionData, unity_SpecCube0_HDR); //... decodifica los colores en HDR a travez de DecodeHDR() (incluida en UnityCG.cginc)
            //     col.rgb *= reflectionColor;

            //     return col;
            // }
            ENDCG
        }
    }
}