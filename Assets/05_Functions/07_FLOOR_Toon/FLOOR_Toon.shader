Shader "USB/FLOOR_Toon"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [IntRange]_Sections ("Sections", Range(2, 10)) = 5 //Seteada para representarse en enteros desde el inspector
        _Gamma ("Gamma", Range(0, 1)) = 0
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
            float _Sections; //Aunque la propiedad se haya seteado para representarse en enteros en el inspector, la variable de coneccion seguira siendo float
            float _Gamma;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float fv = floor(i.uv.y * _Sections) * (_Sections / 100.0); //Agrega los bloques de color solido del efecto toon. Para un toon shader funciona igual, exepto que en el calculo se usa la iluminacion global en lugar de la coordenada V de las UVs, que en este caso aplica el efecto en vertical, si fuera la coordenada U(x), seria en horizontal

                return float4(fv.xxx, 1) + _Gamma; //Retorna el efecto con la gamma aplicada, .xxx se usa como sustituto de coordenadas porque fv es de una sola dimension, pero return es float4, el 1 es para el canal alpha
            }
            ENDCG
        }
    }
}