Shader "USB/Ambient_Color"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ambient ("Ambient Color", Range(0, 1)) = 1
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
            float _Ambient;

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
                float3 ambient_color = UNITY_LIGHTMODEL_AMBIENT * _Ambient; //UNITY_LIGHTMODEL_AMBIENT da acceso al ambient color de la escena, y al multiplicarlo por _Ambient se puede controlar su intensidad sobre el objeto desde el inspector, el color de este se puede cambiar desde Window > Renderign > Lighting > Enviroment > Enviroment Lighting > Source > Color & Ambient Color > Seleccionar el color. En Sun Source seleccionar la luz principal (Directional Light en este caso), si no esta seleccionada
                col.rgb += ambient_color;

                return col;
            }
            ENDCG
        }
    }
}