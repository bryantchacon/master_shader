Shader "USB/MasterShader" //Ruta en el shader inspector/Nombre del shader
{
    Properties //Propiedades
    {
        //NUMEROS Y SLIDERS--------------------------------------------------------------------------------------------
        [Header(NUMEROS Y SLIDERS)] //MPD de encabezado
        [Space(10)] //MPD de espaciado
        _Specular ("Specular", Range(0.0, 1.1)) = 0.3 //Slider
        _Factor ("Factor", Float) = 0.3 //Decimal
        _Cid ("Cid", Int) = 2 //Entero
        /*
        _Cid: Nombre de la propiedad en el codigo
        "Cid": Nombre de la propiedad en el inspector
        Int: Tipo
        2: Valor por defecto
        */

        //COLORES Y VECTORES-------------------------------------------------------------------------------------------
        [Header(COLORES Y VECTORES)]
        [Space(10)]
        _Color ("Color", Color) = (1, 1, 1, 1) //Color
        _vPos ("Vertex Position", Vector) = (0, 0, 0, 1) //Vector

        //TEXTURAS-----------------------------------------------------------------------------------------------------
        [Header(TEXTURAS)]
        [Space(10)]
        _MainTex ("Texture", 2D) = "white" {} //2D
        _Reflection ("Reflection", Cube) = "black" {} //Cube
        _3DTexture ("3D Texture", 3D) = "white" {} //3D

        //MATERIAL PROPERTY DRAWERS (MPD)------------------------------------------------------------------------------
        [Header(MATERIAL PROPERTY DRAWERS (MPD))] //Encabezado para secciones de propiedades
        [Space(10)] //Espaciado entre propiedades
        [Toggle]
        _Enable ("Enable?", Float) = 0 //Shaderlab no tiene soporte para booleanos, pero Toggle cumple esa funcion al aparecer como un check en el inspector. 0 es apagado (desactivado) y 1 encendido (activado). Para usar este drawer hay que agregar el shader variant #pragma shader_feature. Toggle se usa para propiedades que iran DENTRO DEL PASS
        [KeywordEnum(Off, Red, Blue)]
        _Options ("Color Options", Float) = 0 //Permite configurar hasta 9 estados diferentes con un menu desplegable en el inspector. Se puede usar tanto #pragma shader_feature o #pragma multi_compile como shader variant, la diferencia es que shader_feature solo compilara la opcion seleccionada en el inspector, mientras que multi_compile todas para poder ir cambiando de una a otra en tiempo de ejecucion. KeywordEnum se usa para propiedades que iran DENTRO DEL PASS
        [Enum(UnityEngine.Rendering.CullMode)]
        _Face ("Face Culling", Float) = 0 //Es parecido a KeywordEnum, tambien con menu desplegable en el inspector, pero sus valores se almacenan como un diccionario; valor/ID. (Off, 0, Back, 1, Front, 2. Ejemplo con los valores de Cull) y no usa shader variant ya que se pasa sobre un comando o funcion, en este caso Cull. Enum se usa para propiedades que iran DENTRO EL SUBSHADER O PASS, (BOTH) y con valores YA DETERMINADOS DE SHADERLAB O DEPENDENCIAS EQUIVALENTES A ELLOS, como lo es aqui UnityEngine.Rendering.CullMode de los valores de Cull
        [PowerSlider(3.0)]
        _Brightness ("Brightness", Range(0.01, 1)) = 0.08 //Slider de decimales, este drawer se declara con una variable de coneccion como si fuera una propiedad normal
        [IntRange]
        _Samples ("Samples", Range(0, 255)) = 100 //Slider de enteros, tambien se declara con una variable de coneccion

        //OPCIONES DE BLENDING (Optimizadas con la dependencia UnityEngine.Rendering.BlendMode)------------------------
        [Header(OPCIONES DE BLENDING)]
        [Space(10)]
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor ("SrcFactor", Float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor ("DstFactor", Float) = 1

        //MASCARA ALPHA------------------------------------------------------------------------------------------------
        [Header(MASCARA ALPHA)]
        [Space(10)]
        [Enum(Off, 0, On, 1)]
        _AlphaMask ("Alpha Mask", Float) = 0

        //ZWRITE-------------------------------------------------------------------------------------------------------
        [Header(ZWRITE)]
        [Space(10)]
        [Enum(Off, 0, On, 1)]
        _ZWrite ("ZWrite", Float) = 0
    }
    SubShader
    {
        Tags //BOTH, se pueden usar tanto en los Subshader o en los Pass
        {
            // "RenderType"="Opaque" //Valor por default, principalmente se usa para sustituir un shader por otro por medio de un script en la camara
            // "Queue"="Geometry" //Valor por default, no viene en el codigo. Queue sirve para RENDERIZAR OBJETOS TRANSPARENTES, SEMI TRANSPARENTES U OPACOS(?) usando el ALGORITMO DE PINTADO CONVENCIONAL (p.67 y 96); toma como referencia el orden de los objetos en la escena iniciando desde el mas lejano a la camara en su eje Z y finalizando en el mas cercano a la misma, finalmente, se dibujan en pantalla en ese mismo orden
            "RenderType"="Transparent" //Necesario para usar Blend (opciones de blending) 1/2
            "Queue"="Transparent" //Necesario para usar Blend 2/2
            "IgnoreProjector"="False" //Valor por default, su funcion es activar/desactivar que la camara proyecte algo sobre los objetos, False proyectara, True no proyectara
        }
        Blend [_SrcFactor] [_DstFactor] //BOTH. Para poder hacer uso de blend primero hay que configurar el Queue y el RenderType en Transparent. En este caso esta configurado para poder cambiar los valores desde el inspector. Ejemplos de tipos de blending;
        /*
        • SrcAlpha OneMinusSrcAlpha      //Blending normal (se puede modificar su intensidad), activa el canal alpha
        • One One                        //Blending aditivo (NO se puede modificar su intensidad)
        • OneMinusDstColor One           //Blending aditivo suave (NO se puede modificar su intensidad)
        • DstColor Zero                  //Blending multiplicativo (NO se puede modificar su intensidad)
        • DstColor SrcColor              //Blending multiplicativo x2 (NO se puede modificar su intensidad)
        • SrcColor One                   //Blending overlay (NO se puede modificar su intensidad)
        • OneMinusSrcColor One           //Blending luz suave (NO se puede modificar su intensidad)
        • Zero OneMinusSrcColor          //Blending negativo (NO se puede modificar su intensidad)
        • One OneMinusSrcAlpha           //Blending premultiplicado (se puede modificar su intensidad)
        */
        BlendOp Add //Blending operation. Valor por default, no viene escrito en el codigo
        // BlendOp Sub
        // BlendOp Max
        // BlendOp Min
        // BlendOp RevSub
        //PARA MAS INFORMACION SOBRE Blend CHECAR: https://docs.unity3d.com/Manual/SL-Blend.html

        ZWrite [_ZWrite] //BOTH. Valor por default On, no viene en el codigo. Generalmente se desactiva (Off), cuando:
        /*
        • Se usan transparencias, incluido Stencil (carpeta 04_Stencil del proyecto MasterShader), al configurar el ColorMask en 0
        • Se usan las opciones de blending
        • Se quiere evitar errores graficos entre objetos semi transparentes (p. 88), sin embargo, tambien sera necesario (ademas de desactivar el ZWrite y poner el RenderType y Queue en Transparent), ponerlos en diferentes layers sumando o restando uno al valor del Queue, por ejemplo: 3000+1, 3000-1 y 3000 (si son 3 que uno quede con el valor por default)
        */

        AlphaToMask [_AlphaMask] //BOTH. Valor por default Off, no viene en el codigo. Para activarlo basta con escribirlo con On. Actua como una mascara para hacer el canal alpha completamente transparente ya que solo evuelve 0 o 1, siendo 0 transparente para el canal alpha y 1 para opaco. Ademas no es necesario agregar Tags de transparencia ni otros comandos. Es muy util para vegetacion en general o para crear efectos de portales. Configurado para poder cambiar los valores desde el inspector

        // ColorMask R //BOTH. Permite renderizar uno o varios canales de color del shader, incluido el alpha. Si se pone 0 descartara todos los pixeles, volviendo el objeto transparente

        Cull [_Face] //BOTH. Valor por default Back (las caras externas del objeto son renderizadas y las de internas no), no viene en el codigo.Selecciona que caras del objeto no se renderizaran con respecto a la profundidad del pixel. Sus otros dos valores son Front (las caras internas son renderizadas y las externas no) y Off (todas las caras son renderizadas). Configurado para poder cambiar los valores desde el inspector

        ZTest LEqual //BOTH. Valor por default, no viene en el codigo. ZTest controla como se debe realizar el Depth Testing, este a su vez determina si un pixel debe o no ser actualizado en el Depth Buffer, tambien llamado Z-Buffer. Tiene 7 valores diferentes (p.89):
        //NOTA: Aunque se puede aplicar a objetos, no funciona al 100 con estos y al parecer si lo hace si se aplica a la camara, debido a su frustrum.
        /*
        • Less: Renderiza el efecto que indique el shader (o uno de sus pases), por delante de los demas objetos, los que esten a la misma distancia o por detras no.
        • Greater: Renderiza el efecto que indique el shader (o uno de sus pases), por detras de los demas objetos, los que esten a la misma distancia o por delante no.
        • LEqual (Valor por default): Renderiza el efecto que indique el shader (o uno de sus pases), por delante o a la misma distancia de los demas objetos, los que esten por detras no.
        • GEqual: Renderiza el efecto que indique el shader (o uno de sus pases), por detras o a la misma distancia de los demas objetos, los que esten por delante no.
        • Equal: Renderiza el efecto que indique el shader (o uno de sus pases), a la misma distancia de los demas objetos, los que esten por delante y por detras no.
        • NotEqual: Renderiza el efecto que indique el shader (o uno de sus pases), por delante y por detras de los demas objetos, los que esten a la misma distancia no.
        • Always: Siempre rederizara el efecto que indique el shader independientemente de a que distancia este con respecto a los demas.
        */
        //Generalmente se usa en shaders de pases multiples cuando se requiere generar diferencia de colores y profundidades, por ejemplo; un efecto de un personaje saliendo de las sombras hacia donde hay luz, o que al salir de cierto lugar se cambie el color de su ropa, para que esto quede mejor basta con descartar los pixeles del objeto por el que pasa de estar detras a estar por delante.

        LOD 100 //Level Of Detail. Indica cuan exigente en terminos computacionales es el shader

        Pass //Pass = 1 Render Pass = 1 Draw Call
        {
            Name "Pass 0" //La unica funcion de Name es asignarle nombre al pass, no tiene funcion sobre el calculo del shader

            CGPROGRAM //Inicio del CG program. Todas las funciones necesarias para que el shader compile van aqui

            //Pragmas que permiten compilar el vertexShader y fragmentShader como tales
            #pragma vertex vertexShader
            #pragma fragment fragmentShader

            //Pragma que permite compilar el fog, se compone de multi_compile (un shader variant) y _fog que permite habilitar/deshabilitar las opciones de fog desde la ventana Lighting en Window > Rendering > Lighting (la ventana) > Enviroment > Other Settings > Fog
            #pragma multi_compile_fog

            //Pragma para poder usar Toggle, se escribe en mayusculas porque los shader variants son constantes, al final lleva _ON u _OFF que sera el valor de la variable a comparar cuando se active/desactive en el inspector y a verificar en el CG if en el fragment shader. Configurado para la variable _Enable
            #pragma shader_feature _ENABLE_ON

            //Pragma para poder usar KeywordEnum. Configurado para la variable _Options
            #pragma multi_compile _OPTIONS_OFF _OPTIONS_RED _OPTIONS_BLUE

            //include tiene la misma funcion que using en C# en Unity
            #include "UnityCG.cginc"

             //VERTEX INPUT: Guarda las propiedades del objeto
            struct vertInput
            {
                float4 vertex : POSITION; //La semantica POSITION[n] da acceso a la posicion de los vertices en Object-Space y se asigna al vector de 4 dimensiones vertex, posteriormente en el Vertex Shader se transforman a Clip-Space (coordenadas en pantalla), con la funcion UnityObjectToClipPos(), para esto, su similar con el que se conectara en el vertexShader es el vertex del vertOutput
                //NOTA: Para mas informacion sobre las semanticas checar: https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics
                float2 uv : TEXCOORD0; //Da acceso a las coordenadas UV, su similar con el que se conectara en el vertexShader es el uv del vertOutput, esto para dar tilign y offset a la textura POR MEDIO de las UVs, 1/3

                float3 tangent : TANGENT0; //Da acceso a las tangentes, necesario para crear mapas de normales, su similar con el que se conectara en el vertexShader es el tangentWorld del vertOutput
                float3 normal : NORMAL0; //Da acceso a las normales, fundamental para la implementacion de luz y mapas de normales, su similar con el que se conectara en el vertexShader es el normalWorld del vertOutput
                float3 vertColor : COLOR0; //Da acceso al color de los vertices, su valor por default es blanco o gris, su similar con el que se conectara en el vertexShader es el vertColor del vertOutput
            }; //Los struct se cierran con ;

             //VERTEX OUTPUT: Permite pasar propiedades desde el vertexShader al fragmentShader ya que en el vertexShader los valores del vertInput se pasan como parametros en funciones para reasignar los valores que sean necesarios de este, el vertOutput
            struct vertOutput
            {
                float4 vertex : SV_POSITION; //SV se refiere a System Value
                float2 uv : TEXCOORD0; //Variable donde se guardaran las coordenadas uv de su similar uv en el vertInput ya que sirve para dar tiling y offset a la textura, 2/3
                UNITY_FOG_COORDS(1)

                float3 tangentWorld : TEXCOORD1;
                float3 binormalWorld : TEXCOORD2;
                float3 normalWorld : TEXCOORD3;
                float3 vertColor : COLOR0;
            };

            //VARIABLES GLOBALES DE CONEXION DE LAS PROPIEDADES
            float _Specular;
            float _Factor;
            int _Cid;
            float4 _Color;
            float4 _vPos;
            sampler2D _MainTex;
            float4 _MainTex_ST; //Variable para poder usar el tiling y el offset de _MainTex, se usa de forma interna en la funcion TRANSFORM_TEX() en el vertexShader(), 3/3
            float4 _Reflection;
            float4 _3DTexture;
            float _Brightness;
            int _Samples;

            //VERTEX SHADER: Procesa los vertices
            vertOutput vertexShader (vertInput v) //Es tipo de dato vertOutput porque ese tipo de dato retornara, y tal se usara como el tipo de dato del argumento en el fragmentShader, la variable v que se le pasa como parametro es un puntero al vertInput porque sus valores se usaran aqui, en el vertexShader
            {
                vertOutput o; //Variable para hacer uso de las variables internas del vertOutput
                o.vertex = UnityObjectToClipPos(v.vertex); //Transforma las coordenadas de los vertices de Object-Space a Clip-Space (3D a coordenadas en pantalla 2D), pasandole como parametro el vertex del vertInput por medio del parametro v, del mismo tipo
                o.uv = TRANSFORM_TEX(v.uv, _MainTex); //Permite controlar el tilign y el offset de la textura por medio de las UVs
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            //FRAGMENT SHADER: Procesa los pixeles
            fixed4 fragmentShader (vertOutput i) : SV_Target //El retorno sera de tipo fixed4, pero debido a esto solo compilara en Built-In RP, si se necesita que compile en Scriptable RP debe cambiarse este y todos los fixed por half o float, manteniendo el numero de dimensiones y la variable i que se le pasa como parametro es un puntero al vertOutput
            {
                fixed4 col = tex2D(_MainTex, i.uv); //Aplica la textura por medio de las UVs y se guarda en la variable col
                //Aplica el fog (si se activa)
                UNITY_APPLY_FOG(i.fogCoord, col);

                //CG if, en este caso para usar el Toggle _Enable. Si se va agregar color debe hacerse aqui ya que en el return final no funcionara
                // #if _ENABLE_ON
                //     return col;
                // #else
                //     return col * _Color;
                // #endif

                //CG if para usar los valores del KeywordEnum _Options
                // #if _OPTIONS_OFF
                //     return col;
                // #elif _OPTIONS_RED
                //     return col * float4(1, 0, 0, 1);
                // #elif _OPTIONS_BLUE
                //     return col * float4(0, 0, 1, 1);
                // #endif

                return col; //Retorna la textura
            }
            ENDCG //Fin del CG program
        }
    }
    //Fallback Off //Opcional, su formato es: Fallback "Ruta en el shader inspector/Nombre del shader"
}