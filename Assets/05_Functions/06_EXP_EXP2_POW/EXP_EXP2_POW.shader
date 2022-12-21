//EN ESTE SHADER SOLO SE EXPLICA EN QUE CONSISTEN exp(), exp2() y pow()

Shader "USB/EXP_EXP2_POW"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //exp(), exp2() y pow()
                float exponent1 = exp(2); //Retorna el resultado de elevar el numero "e" al exponente que se le pase como parametro, en este caso seria: 2.71828182846f²
                float exponent2 = exp2(2); //Retorna el resultado de elevar el numero 2 al exponente que se le pase como parametro, en este caso seria: 2²
                float exponent3 = pow(3, 2); //Retorna un numero elevado a cierto exponente, en este caso seria: 3²

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}