using UnityEngine;

public class SimpleColorController : MonoBehaviour
{
    public ComputeShader m_shader; //Guarda el compute shader desde el inspector
    public Texture m_tex; //Por medio de esta variable se asignara una textura desde el inspector

    public RenderTexture m_mainTex; //Sirve para escribir los colores que se generan en el compute shader
    int m_texSize = 256;
    Renderer m_rend; //Almacenara el componente Renderer del material del quad para escribir la textura

    void Start()
    {
        m_mainTex = new RenderTexture(m_texSize, m_texSize, 0, RenderTextureFormat.ARGB32);
        /*
        • RenderTexture tiene hasta 7 argumentos, pero ahora solo se necesitan 4 de ellos
        • Los primeros dos son el ancho y alto de la textura
        • 0 es el depth buffer
        • El cuarto elemento es la configuracion de la textura (RGBA de 32 bits)
        */
        m_mainTex.enableRandomWrite = true; //Habilita la escritura aleatoria
        m_mainTex.Create(); //Crea la textura como tal

        m_rend = GetComponent<Renderer>(); //Se obtiene el componente renderer del material
        m_rend.enabled = true; //Hace visible el objeto

        m_shader.SetTexture(0, "Result", m_mainTex); //Envia la textura m_mainTex a la variable Result en el compute shader
        /*
        • 0 se refiere al indice del kernel que se esta usando, en este caso es 0 porque Result, la variable de la textura, se usa en la funcion CSMain la cual es el kernel 0
        • "Result" se refiere a la variable de la textura en el compute shader
        • m_mainTex es la textura que se asignara a la variable Result en el compute shader, se procesa en la funcion CSMain
        */
        m_shader.SetTexture(0, "ColTex", m_tex); ////Envia la textura m_tex a la variable ColTex en el compute shader
        m_rend.material.SetTexture("_MainTex", m_mainTex); //Manda la textura m_mainTex a la propiedad _MainTex por medio de la funcion SetTexture() del material. Cualquier shader en unity tiene la propiedad _MainTex por defecto, asi que se puede asumir que el material del quad la tiene tambien

        m_shader.Dispatch(0, m_texSize/8, m_texSize/8, 1); //Genera los grupos de hilos para procesar la textura
        /*
        • 0 es el indice del kernel
        • El segundo y tercer parametro son la cantidad de columnas y filas que tendra respectivamente
        • Y 1 la cantidad de dimensiones
        */
        //Como ya se sabe m_texSize es igual a 256, por lo tanto, si se divide entre 8 da 32, o sea, la textura queda dividida en una cuadricula de 32 * 32 * 1, donde cada cuadro es un grupo de hilos, cada grupo de hilos se procesa en un nucleo de la GPU de manera independiente
        //Que el 8 coincida con los de numthreads() en el compute shader tiene relacion, ya que para que el resultado vuelva a ser 256, 32 debe multiplicarse por 8 otra vez, y si los valores en numthreads() son menos, por ejemplo 4 * 4 * 1, solo se renderizaria 1/4 de la textura, asi que, los valores del numero de columnas y filas en Dispatch() SIEMPRE DEBEN COINCIDIR CON LOS DE numthreads() EN EL COMPUTE SHADER (pero esto no se refleja mientras unity esta en play, se debe detener y volver a darle a play para que se vea el cambio)
        //Ahora bien, cuantos hilos tiene cada grupo en la cuadricula de la textura?, quien lo determina es numthreads() en el compute shader, basta con multiplicar sus valores entre si: 8 * 8 * 1 = 64 hilos por grupo
    }
}