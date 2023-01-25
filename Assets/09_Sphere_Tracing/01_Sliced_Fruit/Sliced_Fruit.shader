Shader "USB/Sliced_Fruit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PlaneTex ("Plane Texture", 2D) = "white" {}
        _Edge ("Edge", Range(-0.5, 0.5)) = 0.0 //Sus valores son tales porque el diametro de la esfera es 1
        _CircleRad ("Circle Radius", Range(0.0, 0.5)) = 0.45
        _CircleCol ("Circle Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        Cull Off //Hace posible proyectar ambas caras de la esfera al descartar los pixeles sobre el _Edge
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
                float3 hitPos : TEXCOORD1; //Vector para poder descartar los pixeles que esten sobre el plano y el exterior de la fruta, pero dada la naturaleza de esto, solo se puede hacer en el fragment shader, asi que se llevaran los valores del vertex shader al fragment shader, por eso este vector solo va aqui en el vertex output y no proviene de una propiedad. Este vector tiene dos funcionalidades: La primera es definir la posicion de los vertices y la segunda calcular la posicion del plano y el exterior de la fruta, esto para que ambas superficies esten en el mismo punto
            };

            sampler2D _MainTex;
            sampler2D _PlaneTex;
            float4 _MainTex_ST;
            float4 _CircleCol;
            float _Edge;
            float _CircleRad;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.hitPos = v.vertex; //Asigna a hitPos la posicion de los vertices en Object-Space
                return o;
            }

            //Constantes globales
            #define MAX_MARCHING_STEPS 50 //Maximo de pasos para determinar la interseccion de una superficie
            #define MAX_DISTANCE 10.0 //Distancia maxima para encontrar la inserseccion de la superficie, se refiere a 10 metros o bloques de la cuadricula en la escena
            #define SURFACE_DISTANCE 0.001 //Distancia de la superficie

            //Funcion para proyectar la textura del plano y el exterior de la fruta
            //En si es una funcion de tipo SDF (Signed Distance Functions), las cuales toman un punto como input y retornan la distancia mas corta entre tal punto y la superficie de una figura
            float planeSDF(float3 ray_position)
            {
                float exterior = ray_position.y - _Edge; //Se resta el _Edge a la posicion del rayo en Y, para aumentar o disminuir la posicion del plano y el exterior de la fruta
                return exterior;
            }

            //Funcion para calcular el Sphere Casting, o sea, la distancia del objeto a la cámara
            float sphereCasting(float3 ray_origin, float3 ray_direction)
            /*
            • ray_origin: Punto inicial del rayo, o sea, posicion de la camara en World-Space
            • ray_direction: Posicion de los vertices
            */
            {
                float distance_origin = 0;
                for(int i = 0; i < MAX_MARCHING_STEPS; i++)
                {
                    float3 ray_position = ray_origin + ray_direction * distance_origin;
                    float fruit_distance = planeSDF(ray_position);
                    distance_origin += fruit_distance;

                    if(fruit_distance < SURFACE_DISTANCE || distance_origin > MAX_MARCHING_STEPS) //MAX_DISTANCE ?
                    {
                        break;
                    }
                }

                return distance_origin;
            }

            fixed4 frag (v2f i, bool face : SV_ISFRONTFACE) : SV_Target //SV_ISFRONTFACE hace posible proyectar tambien los pixeles de la esfera en su cara trasera
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 ray_origin = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1)); //Transforma las coordenadas de la camara a Local-Space
                float3 ray_direction = normalize(i.hitPos - ray_origin); //Calcula la direccion del rayo
                float t = sphereCasting(ray_origin, ray_direction); //Uso de la funcion sphereCasting(), guarda la distancia de la fruta respecto a la camara

                float4 planeCol = 0; //Guarda la texura del plano
                float4 circleCol = 0; //Guarda el borde del plano, borde del plano 1/5

                //Determina que la textura del plano se renderice siempre y cuando la camara este cerca de la fruta (dentro del parametro de MAX_DISTANCE)
                if(t < MAX_DISTANCE)
                {
                    float3 p = ray_origin + ray_direction * t; //Calcula la posicion de la fruta
                    float2 uv_p = p.xz; //Crea las UVs para el plano

                    float l = pow(-abs(_Edge), 2) + pow(-abs(_Edge) - 1, 2); //Permite que la textura del plano cambie de tamaño al aumentar/disminuir el _Edge

                    float c = length(uv_p); //Genera un circulo siguiento las UVs del plano, borde del plano 2/5
                    circleCol = (smoothstep(c - 0.01, c + 0.01, _CircleRad - abs(pow(_Edge * (1 * 0.5), 2)))); //Se aplica un esquema parecido al radio de l, borde del plano 3/5

                    planeCol = tex2D(_PlaneTex, (uv_p * (1 + abs(pow(_Edge * l, 2)))) - 0.5); //Sampleo de la textura del plano, se resta 0.5 para centrar la textura, ya que su centro esta en 0, 0, 0

                    planeCol *= circleCol; //Elimina los bordes de la textura para poder mostrar bien el circulo, borde del plano 4/5
                    planeCol += (1 - circleCol) * _CircleCol; //Agrega el circulo y se le aplica el color, borde del plano 5/5
                }

                //Descarta los pixeles que esten sobre el _Edge
                if(i.hitPos.y > _Edge)
                {
                    discard;
                }

                return face ? col : planeCol;
            }
            ENDCG
        }
    }
}