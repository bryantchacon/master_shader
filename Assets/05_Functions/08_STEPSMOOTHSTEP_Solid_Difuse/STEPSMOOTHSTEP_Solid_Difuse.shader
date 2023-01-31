Shader "USB/STEPSMOOTHSTEP_Solid_Difuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Edge ("Edge Location", Range(0, 1)) = 0.5
        _Smooth ("Smooth Intensity", Range(0.0, 0.3)) = 0.1
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Edge;
            float _Smooth;

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

                //CODIGO PARA CREAR UN EDGE SOLIDO CON step()
                // float edge = _Edge; //Indica a que altura estara el edge, paso 1/4
                // fixed3 sstep = 0; //Variable donde se guardara el edge ya generado, paso 2/4
                // sstep = step(edge, i.uv.y); //Se aplica la funcion step() para crear la division solida de valores, con la coordenada v de las UVs como parametro (por .y), paso 3/4

                //CODIGO PARA CREAR UN EDGE DIFUMINADO CON smoothstep()
                float edge = _Edge; //Indica a que altura estara el edge, paso 1/5
                float smooth = _Smooth; //Intensidad de la difuminacion del edge, paso 2/5
                fixed3 sstep = 0; //Variable donde se guardara el edge ya generado, paso 3/5
                sstep = smoothstep((i.uv.y - smooth), (i.uv.y + smooth), edge); //Aplica el suavisado del edge con smoothstep() sobre la coordenada v (por .y), paso 4/5

                col *= fixed4(sstep, 1); //Retorna el efecto guardado en sstep y 1 para el canal aplha, paso 4/4 de step() y 5/5 de smoothstep()

                return col;
            }
            ENDCG
        }
    }
}