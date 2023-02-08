using UnityEngine;

[ExecuteInEditMode]
public class ReplacementController : MonoBehaviour
{
    public Shader replacementShader;

    private void OnEnable() //Al estar habilitado este script...
    {
        if(replacementShader != null) //... y si la variable replacementShader contiene algo...
        {
            GetComponent<Camera>().SetReplacementShader(replacementShader, "RenderType"); //... reemplaza el shader del objeto que vea la camara por el que guarda la variable shader si ambos tienen el mismo RenderType
        }
    }

    private void OnDisable() //Al estar desabilitado el script...
    {
        GetComponent<Camera>().ResetReplacementShader(); //... resetea el remplazo del shader en el objeto
    }
}