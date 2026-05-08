using ServiceStack;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SaleInfoWS
{
    /// <summary>
    /// Clase para configurar la informacion que se devolvera
    /// por el servicio de autenticacion en caso de que sea
    /// necesario alguna informacion del usuario esta debe ir
    /// en este lugar.
    /// </summary>
    public class CustomUserSession : AuthUserSession
    {
    }
}