Shader "USB/Specular_Reflection" //p. 228-241
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(SPECULAR REFLECTION PROPERTIES)]
        [Space(10)]
        _SpecularTex ("Texture", 2D) = "black" {}
        _SpecularInt ("Intensity", Range(0, 1)) = 1
        _SpecularPow ("Power", Range(1, 128)) = 64
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "LightMode"="ForwardBase" //El LightMode se configura en ForwardBase debido a que la reflexion es un pase de iluminacion
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
                float3 vertex_world : TEXCOORD2; //Se refiere a la posicion de los vertices del objeto en World-Space, se usa en el calculo de la direccion de la vista a modo de punto de referencia
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SpecularTex; //Debido a que la reflexion especular es constante sobre una superficie, esta no tendra tiling ni offset y por eso no se declarara la variable _SpecularTex_ST
            float _SpecularInt;
            float _SpecularPow;
            // float4 _LightColor0; //_LightColor[n] se refiere al color de la luz de una fuente de luz específica en la escena, por lo tanto no servira para asignar el color de la iluminacion de la escena a la textura de la refleccion. Cuando se necesita de este modo el siguiente comentario es el adecuado: _LightColor[n] es una variable interna que se refiere al color de la iluminacion en la escena (o sea, el color de la luz), se declara como variable uniforme aqui, sin que provenga de una propiedad, esta le dara su valor a la variable colorRefl (solo sus canales .rgb), y se multiplicara por la reflexion especular (specCol), para que asi su color se vea afectado por el color de la luz de la escena

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normal_world = UnityObjectToWorldNormal(v.normal); //UnityObjectToWorldNormal() transforma las normales de Object-Space a World-Space, viene incluida en UnityCG.cginc
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex); //Este calculo transforma los vertices de Object-Space a World-Space, a diferencia de UnityObjectToClipPos() que los transforma de Object-Space a Clip-Space

                return o;
            }

            //FUNCION PARA CALCULAR REFLEXION ESPECULAR (p. 231)
            float3 SpecularReflection(float3 colorRefl, float specularInt, float3 normal, float3 lightDir, float3 viewDir, float specularPow)
            {
                float3 h = normalize(lightDir + viewDir); //Vector halfway para poder ver la refleccion desde cualquier lado sin necesidad de estar viendo exactamente desde el angulo contrario a la direccion de la luz

                return colorRefl * specularInt * pow(max(0, dot(normal, h)), specularPow);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                //CALCULOS PARA EL COLOR DE LA REFLEXION
                // fixed3 colorRefl = _LightColor0.rgb; //Descartado por que el funcionamiento que se requiere es con UNITY_LIGHTMODEL_AMBIENT
                fixed3 colorRefl = UNITY_LIGHTMODEL_AMBIENT; //UNITY_LIGHTMODEL_AMBIENT da acceso al ambient color de la escena y el color de este se puede cambiar desde Window > Renderign > Lighting > Enviroment > Ambient Color
                fixed3 specCol = tex2D(_SpecularTex, i.uv) * colorRefl; //Añade la textura de la refleccion especular a las UVs y se multiplica por el color de la reflexion para que asi su color se vea afectado por el color de la luz de la escena ?
                float3 normal = i.normal_world;
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); //_WorldSpaceLightPos[n] es una variable interna de 4 dimensiones que se refiere a la direccion de la luz de la escena en World-Space
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world); //Para calcular la direccion de la vista se restan los vertices en World-Space a la posicion de la camara en World-Space tambien(_WorldSpaceCameraPos, variable interna)

                half3 specular = SpecularReflection(specCol, _SpecularInt, normal, lightDir, viewDir, _SpecularPow);
                col.rgb += specular; //Se especifica que la reflexion especular se agrega solo a los canales .rgb de col debido a que este es de 4 dimensiones y specular de 3

                return col;
            }
            ENDCG
        }
    }
}