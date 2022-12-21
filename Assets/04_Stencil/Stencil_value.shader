Shader "USB/Stencil_value"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "Queue"="Geometry"
        }

        Stencil //BOTH
        {
            Ref 2 //Stencil Ref. Valor de referencia que tendra el Stencil Buffer y que tambien tiene el objeto que aplica la mascara para que funcione
            Comp NotEqual //No renderizara los pixeles del objeto que TENGA ESTE SHADER al verse a travez de otro objeto (shader object), que tenga el mismo valor del Stencil Ref de ESTE SHADER (2) y asignado a su Stencil Buffer con Pass Replace
            // Pass Keep
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