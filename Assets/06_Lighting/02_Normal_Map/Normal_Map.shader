Shader "USB/Normal_Map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
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
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_normal : TEXCOORD1; //Variable para agregar tiling y offset al mapa de normales
                float3 normal_world : TEXCOORD2;
                float4 tangent_world : TEXCOORD3;
                float3 binormal_world : TEXCOORD4; //Esta variable no tiene contraparte en el vertex input porque las binormales en World-Space se calculan usando las normales y tangentes ya calculadas en World-Space
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST; //TRANSFORM_TEX() lo usa internamente para generar el tiling y offset de las normales

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT (v2f, o); //Codigo auxiliar para inicializar el vertex output(v2f o) en 0 por si sale una advertencia en el shader luego de agregar los calculos de las normales
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //CALCULOS PARA LA GENERACION DE LAS NORMALES, TANGENTES Y BINORMALES
                o.uv_normal = TRANSFORM_TEX(v.uv, _NormalMap); //Agrega y guarda el tiling y offset del mapa de normales
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))); //Transforma las normales a World-Space
                o.tangent_world = normalize(mul(v.tangent, unity_WorldToObject)); //Transforma las tangentes a World-Space pero de forma inversa; por eso la funcion que se usa es unity_WorldToObject ?
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) * v.tangent.w); //Calcula las binormales en World-Space, v.tangent.w se refiere a ?
                return o;
            }

            //EQUIVALE A LA FUNCION UnpackNormal() ? INCLUIDA EN UnityCG.cginc
            float3 DXTCompression(float4 normalMap)
            {
                #if defined (UNITY_NO_DXT5nm)
                    return normalMap.rgb * 2 - 1;
                #else
                    float3 normalCol;
                    normalCol.rg = normalMap.ag * 2 - 1; //Optimizado de a como viene en el libro (p.208)
                    normalCol.b = sqrt(1 - (pow(normalCol.r, 2) + pow(normalCol.g, 2))); //p. 208-211
                    return normalCol;
                #endif
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 normal_map = tex2D(_NormalMap, i.uv_normal);
                fixed3 normal_compressed = DXTCompression(normal_map);
                float3x3 TBN_matrix = float3x3 //Matriz TBN para transformar el mapa de normales a Tangent-Space
                (
                    i.tangent_world.xyz, //Se especifica que debe usar las coordenadas .xyz porque el vector fue declarado como uno de 4 dimensiones en el vertex output v2f
                    i.binormal_world,
                    i.normal_world
                );
                fixed3 normal_color = normalize(mul(normal_compressed, TBN_matrix));
                return fixed4 (normal_color, 1);
            }
            ENDCG
        }
    }
}