Shader "USB/Stencil_ref"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "Queue"="Geometry-1" //-1 hace que se renderice primero en el Z-Buffer con respecto a otros objetos que tambien son Geometry(2000), pero sin -1
        }
        ZWrite Off //Desactiva el algoritmo de pintado convencional para que el objeto que tiene este shader se renderice primero pero a la inversa, de la camara hacia atras (y Queue al valer ahora 1999 se renderizara primero aunque se cambie de lugar, y porque se trabajara con transparencia haciendo el objeto transparente con ColorMask 0), para que asi el efecto de mascara tambien funcione por delante del objeto al cual le aplica la mascara, si no solo funcionara cuando el objeto que tenga este shader este detras de el
        ColorMask 0 //Descarta los pixeles del objeto en el Frame Buffer, haciendolo transparente

        //Activa el efecto mascara en el objeto. Esto se logra creando el Stencil Buffer, en resumen es como una textura que puede guardar un valor de 0 a 255 por cada pixel en el Frame Buffer. Funciona activando el Stencil Test, el cual permite descartar pixeles para que no se procesen en el Fragment Shader, generando asi un efecto de mascara
        Stencil //BOTH. ESTE EFECTO TAMBIEN PUEDE SER USADO PARA CREAR PORTALES, VENTANAS O ESPEJOS EMBRUJADOS
        {
            Ref 2 //Stencil Ref. Valor de referencia que tendra el Stencil Buffer y que tambien debe tener el objeto a enmascarar en su propio shader para que funcione
            Comp Always //Se refiere a que siempre renderizara los pixeles del objeto que TENGA ESTE SHADER (aunque arriba se descartaron con ColorMask en 0)
            Pass Replace //Reemplaza el valor del Stencil Buffer por el valor del Stencil Ref (2) EN ESTE SHADER, para actuar como mascara con un objeto que tenga el mismo valor de Ref (2) en su shader
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}