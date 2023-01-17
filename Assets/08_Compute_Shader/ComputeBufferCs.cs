using UnityEngine;

public class ComputeBufferCs : MonoBehaviour
{
    public ComputeShader m_shader;

    [Range(0.0f, 0.5f)] public float m_radius = 0.5f;
    [Range(0.0f, 1.0f)] public float m_center = 0.5f;
    [Range(0.0f, 0.5f)] public float m_smooth = 0.01f;

    public Color m_mainColor = new Color();

    private RenderTexture m_mainTex;
    private int m_texSize = 128;
    private Renderer m_rend;

    //Struct con los valores que se usaran en el compute shader
    struct Circle
    {
        public float radius;
        public float center;
        public float smooth;
    }

    //Lista tipo Cricle para poder acceder a cada variable
    Circle[] m_circle;

    //Buffer tipo ComputeBuffer, una vez se llene la lista con sus respectivos valores, se copia la data al buffer y finalmente se pasa al compute shader
    //NOTA: Tanto el ComputeBuffer aqui como el StructuredBuffer<> en el compute shader se usan siempre simultaneamente en su lugar
    ComputeBuffer m_buffer;

    void Start()
    {
        CreateShaderTex();
    }

    //NOTA: Recordar que en C# las funciones se declaran despues del lugar en el que se llaman ?

    void CreateShaderTex()
    {
        //Creacion de la textura
        m_mainTex = new RenderTexture(m_texSize, m_texSize, 0, RenderTextureFormat.ARGB32);
        m_mainTex.enableRandomWrite = true;
        m_mainTex.Create();

        //Acceso y activacion del componente Renderer del mesh
        m_rend = GetComponent<Renderer>();
        m_rend.enabled = true;
    }

    void Update()
    {
        SetShaderTex();
    }

    void SetShaderTex()
    {
        uint threadGroupSizeX;
        m_shader.GetKernelThreadGroupSizes(0, out threadGroupSizeX, out _, out _);
        /*
        • El primer valor de GetKernelThreadGroupSizes() se refiere al kernel del compute shader
        • Los otros 3 a los valores de numthreads[]: 128, 1, 1
        */
        int size = (int)threadGroupSizeX;
        m_circle = new Circle[size];

        for(int i = 0; i < size; i++)
        {
            Circle circle = m_circle[i];
            circle.radius = m_radius;
            circle.center = m_center;
            circle.smooth = m_smooth;
            m_circle[i] = circle;
        }

        int stride = 12; //Tamaño de los elementos en conjunto en bytes, en este caso son 12 porque cada uno es un float de 4 bytes
        m_buffer = new ComputeBuffer(m_circle.Length, stride, ComputeBufferType.Default);
        /*
        • m_circle: Numero de elementos en el buffer
        • stride: Bytes que ocupan todos los elementos
        • ComputeBufferType.Default: Tipo de buffer que se crea, corresponde al StructuredBuffer de tipo Circle del compute shader
        */
        m_buffer.SetData(m_circle); //Manda m_circle a m_buffer
        m_shader.SetBuffer(0, "CircleBuffer", m_buffer); //Manda el m_buffer al CircleBuffer en el compute shader
        m_shader.SetTexture(0, "Result", m_mainTex); //Manda la textura m_mainTex a Result en el compute shader
        m_shader.SetVector("MainColor", m_mainColor); //Manda el color m_mainColor a MainColor en el compute shader
        m_rend.material.SetTexture("_MainTex", m_mainTex); //Manda la textura m_mainTex a la propiedad interna del material del mesh _MainTex

        m_shader.Dispatch(0, m_texSize, m_texSize, 1); //Genera los grupos de hilos para procesar la textura
        /*
        • 0 es el indice del kernel
        • El segundo y tercer parametro son la cantidad de columnas y filas que tendra respectivamente
        • Y 1 la cantidad de dimensiones
        */
        m_buffer.Release(); //Al final cuando el buffer ya no sera usado, se usa Release() o Dispose() para liberar el buffer
    }
}