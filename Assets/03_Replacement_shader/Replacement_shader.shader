//Para crear el efecto de Replacement Shader por medio del tag RenderType se deben cumplir las siguientes condiciones:
/*
1. Ambos shaders, el de reemplazo y el que se va a reemplazar deben tener el mismo RenderType
2. Ambos deben tener propiedades en comun(la o las que se van a reemplazar entre uno y otro)
3. Usar la funcion SetReplacementShader() en un C# script
4. El Renderig Path de la camara debe ser Forward
*/

Shader "USB/Replacement_Shader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                _Color = float4(1,0,0,1);
                return _Color;
            }
            ENDCG
        }
    }
}