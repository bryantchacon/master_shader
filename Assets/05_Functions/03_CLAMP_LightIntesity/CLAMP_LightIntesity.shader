Shader "USB/CLAMP_LightIntesity"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MinLight ("Min Light", Range(0, 1)) = 0.1
        _MaxLight ("Max Light", Range(0, 1)) = 0.9
        _Light ("Light Intesity", Range(0, 1)) = 0.5
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
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MinLight;
            float _Light;
            float _MaxLight;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            //Sintaxis de clamp
            /*
            float ourClamp(float a, float x, float b)
            {
                return max(a, min(x, b));
            }
            */

            fixed4 frag (v2f i) : SV_Target
            {
                float light = clamp(_MinLight, _Light, _MaxLight); //Uso de clamp (funcion interna), para manipular la intensidad de la luz (en este caso)

                fixed4 col = tex2D(_MainTex, i.uv) * light; //Para aplicar el efecto, basta con multiplicar la textura por light

                return col;
            }
            ENDCG
        }
    }
}