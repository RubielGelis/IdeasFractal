using System;

namespace SaleInfoWS
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Habilitar soporte para protocolos de seguridad TLS (TLS 1.2 y TLS 1.3)
            System.Net.ServicePointManager.SecurityProtocol |= System.Net.SecurityProtocolType.Tls12 | (System.Net.SecurityProtocolType)12288;
            
            new AppHost().Init();
        }
    }
}