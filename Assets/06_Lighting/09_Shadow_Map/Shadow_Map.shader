//p. 265-284, pero faltaron un par de cosas por explicar, asi que mejor cheque el shader en el package del libro y lo ajuste respecto a ese

Shader "USB/Shadow_Map"
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
        }
        LOD 100
        
        //SHADOW CASTER PASS
        Pass
        {
            Name "Shadow Caster" //La unica funcion de Name es asignarle nombre al pass, no tiene funcion sobre el calculo del shader
            Tags
            {
                "LightMode"="ShadowCaster" //Cuando un pass va a ser para el Shadow Caster, el LightMode se declara como tal
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //Para que se puedan compilar los macros V2F_SHADOW_CASTER;,TRANSFER_SHADOW_CASTER_NORMALOFFSET(o) y SHADOW_CASTER_FRAGMENT(i), se deben agregar el #pragma multi_compile_shadowcaster, y el #include "UnityCG.cginc" ya viene incluido
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            //NOTA: ESTE PASS NO LLEVA VERTEX INPUT ?

            struct v2f
            {
                V2F_SHADOW_CASTER; //Este macro posee:
                /*
                • Un output para la posicion de los vertices (vertex : SV_POSITION)
                • Un output para las normales (normal_world : TEXCOORD1)
                • Un output para las tangentes (tangent_world : TEXCOORD2)
                • Un output para las binormales (binormal_world : TEXCOORD3)
                */
            };

            v2f vert (appdata_base v) //?
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o) //Tiene la misma funcion que UnityObjectToClipPos(), y ademas calcula su Normal Offset, el cual permite incluir sombras en mapas de normales
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i) //Realiza el output de color para la proyeccion de las sombras
            }
            ENDCG
        }

        //DEFAULT COLOR PASS
        Pass
        {
            Name "Shadow Map Texture"
            Tags
            {
                "LightMode"="ForwardBase" //Indica que este pase se vera afectado (se encarga) de la iluminacion
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            //Se encarga de compilar todas las variantes de lightmaps y sombras producidas por luces direccionales para este pase (Shadow Map Texture), y para el correcto funcionamiento de los macros: SHADOW_COORDS(N), TRANSFER_SHADOW(O) Y SHADOW_ATTENUATION(O), paso 1/2
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            //Sirve para el correcto funcionamiento de los macros: SHADOW_COORDS(N), TRANSFER_SHADOW(O) Y SHADOW_ATTENUATION(O), paso 2/2
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0; //Al usar los macros de debe cambiar el nombre del input de UVs, uv, por texcoord
            };

            struct v2f
            {
                float4 pos : SV_POSITION; //Aqui tambien, al usar los macros se debe cambiar el nombre del output de los vertices, vertex, por pos
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1) //Este macro contiene las coordenadas UV que se pasan al Fragment Shader, y el 1 equivale a TEXCOORD1
            };

            sampler2D _MainTex;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o); //Para evitar posibles errores inicializa la variable o  en 0
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                TRANSFER_SHADOW(o) //Este macro calcula las coordenadas UVs para la textura de la sombra. Es igual a la funcion NDCToUV() p.276

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed shadow = SHADOW_ATTENUATION(i); //Este macro contiene la textura y su proyeccion, ademas, la variable es de una sola dimension porque solo se ocupa un canal en la proyeccion de la textura, en este caso el alpha, porque este guarda un rango entre 0.0f y 1.0f debido a que la textura de una sombra posee un rango de colres entre negro(no hay sombra) y blanco(hay sombra)
                col.rgb *= shadow;

                return col;
            }
            ENDCG
        }
    }
}