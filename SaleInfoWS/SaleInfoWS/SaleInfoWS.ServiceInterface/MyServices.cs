using ServiceStack;
using SaleInfoWS.ServiceModel;
using System.Data;
using ServiceStack.OrmLite;
using ServiceStack.OrmLite.PostgreSQL;
using System.Configuration;
using System;
using System.Collections.Generic;
using SaleInfoWS.ServiceModel.SaleInfo;
using SaleInfoWS.ServiceModel.CreditLimit;

namespace SaleInfoWS.ServiceInterface
{
    public class MyServices : Service
    {
        /// <summary>
        /// Servicio para guardar la información de ventas y retornar la 
        /// informacion de un backoffice externo.
        /// </summary>
        /// <param name="request">Información de la venta.</param>
        /// <returns>Information del backoffice externo.</returns>
        [Authenticate]
        public SaleInfoRS Any(SaleInfoRQ request)
        {
            // Se valida que el request tenga todos los datos obligatorios.
            request.Validate();
                
            // Se abre conexion a la base de datos que esta configurada en el Web.Config
            using (var db = Connect())
            {
                try
                {
                    // Llamada al procedimiento almacenado de PostgreSQL "spInterfaceIdeasFractal".
                    // Este procedimiento recibe el JSON (enviado en request.Payload) y orquesta la transformación e inserción.
                    // Al ser un PROCEDURE con un parámetro INOUT, se usa CALL y se captura el resultado.
                    var responseXml = db.SqlScalar<string>(
                        "CALL public.\"spInterfaceIdeasFractal\"(@op, @codigo, @xml, @pet, @res)",
                        new { 
                            op = "Booking", 
                            codigo = request.Loc, 
                            xml = request.Payload, 
                            pet = "API-REQUEST", // Identificador de petición
                            res = (string)null   // El parámetro INOUT se recibe como resultado del escalar
                        });

                    // Se determina el estado basado en la respuesta XML generada por el SP de respuesta.
                    bool isSuccess = responseXml != null && responseXml.Contains("<Status>Success</Status>");

                    return new SaleInfoRS
                    {
                        Loc = request.Loc,
                        CodeIntegrationBackoffice = request.Loc,
                        StatusIntegration = isSuccess ? "OK" : "Error",
                        MessageIntegration = responseXml ?? "No se recibió respuesta del servidor de base de datos."
                    };
                }
                catch (Exception e)
                {
                    return new SaleInfoRS
                    {
                        Loc = request.Loc,
                        StatusIntegration = "Error",
                        MessageIntegration = "Excepción al procesar la integración: " + e.Message
                    };
                }
            }
        }

        [Authenticate]
        public CreditLimitRS Any(CreditLimitRQ request)
        {
            using (var db = Connect())
            {

                try
                {
                    // Guarda el request en la base de datos y obtiene el id con el que se guardo el registro.
                    var lastId = db.Insert(request, selectIdentity:true);


                    // Ejemplo de la respuesta con los datos que se obtendrian del servicio externo.
                    return new CreditLimitRS
                    {
                        CodeClientBackOffice = 6252,
                        CodeClientOBT = 627,
                        Status = "OK",
                        Message = "Favor comunicarse con..."
                    };
                }
                catch (Exception e)
                {
                    throw e;
                }
            }
        }

        /// <summary>
        /// Abre la conexion de la BD configurada en el WebConfig.
        /// </summary>
        /// <returns>El objeto de conexion de la BD.</returns>
        private IDbConnection Connect()
        {
            var SessionToken = this.GetSession().Id;
            base.Response.AddHeader("Session-Id", SessionToken);

            OrmLiteConnectionFactory dbFactory = new OrmLiteConnectionFactory(
                ConfigurationManager.ConnectionStrings["FrontEndConnection"].ConnectionString, PostgreSqlDialect.Provider);

            return dbFactory.OpenDbConnection();
        }

    }
}