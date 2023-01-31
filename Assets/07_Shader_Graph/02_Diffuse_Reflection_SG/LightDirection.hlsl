//Custom functions p.308-312
//Este script p.310
//El calculo que se replica en shader graph es el de la variable interna _WordlSpaceLightPos[n] (p.222), para la refleccion difusa (p. 219)

void LightDirection_float(out half3 direction)
{
    #ifdef SHADERGRAPH_PREVIEW //Si la previsualizacion en shader graph esta habilitada...
        direction = half3(0, 1, 0); //... proyectara la iluminacion en 90° sobre el eje y
    #else //Si no...
        #if defined(UNIVERSAL_LIGHTING_INCLUDED) //Si se ha definido URP...
            Light mainLight = GetMainLight(); //... se obtiene la luz principal de la escena...
            direction = mainLight.direction; //... y el output direction es igual a la direccion de esta
        #endif
    #endif
}