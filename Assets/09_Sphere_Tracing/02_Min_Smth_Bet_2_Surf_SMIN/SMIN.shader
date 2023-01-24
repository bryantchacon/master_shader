Shader "USB/SMIN"
{
    Properties
    {
        _Position ("Circle Position", Range(0, 1)) = 0.5
        _CirSmooth ("Circle Smooth", Range(0.0, 0.1)) = 0.01
        _InterLerp ("Intersection Lerp", Range(0.0, 0.5)) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
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

            float _Position;
            float _CirSmooth;
            float _InterLerp;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            //Funcion para crear un circulo
            float circle(float2 uvs, float r)
            {
                float c = length(uvs) - r;
                return c;
            }

            //Funcion smin para crear una interpolacion entre a y b, donde cada uno se refiere a una forma independiente, y se controla con k
            float smin(float a, float b, float k)
            {
                float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
                return lerp(b, a, h) - k * h * (1.0 - h);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float a = circle(i.uv, 0.5);
                float b = circle(i.uv - _Position, 0.2);

                float s = smin(a, b, _InterLerp); //Genera la interpolacion entre los circulos
                float render = smoothstep(s - _CirSmooth, s + _CirSmooth, 0.0); //Agrega suavisado a ambos

                return float4(render.xxx, 1);
            }
            ENDCG
        }
    }
}