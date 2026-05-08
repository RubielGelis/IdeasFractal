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
                    // Guarda el request en la base de datos y obtiene el id con el que se guardo el registro.
                    var lastId = db.Insert(request, selectIdentity:true);

                    // En este bloque se hace la logica necesaria para la comunicacion con el servicio externo.


                    // Ejemplo de la respuesta con los datos que se obtendrian del servicio externo.
                    return new SaleInfoRS
                    {
                        Loc = request.Loc,
                        CodeIntegrationBackoffice = "AF580",
                        MessageIntegration = "Exito!",
                        StatusIntegration = "OK",
                        Locs = new List<Loc>
                        {
                            new Loc { LocProvider = "IOS89", MessageIntegration = "Ok", StatusIntegration = "OK", ProductType = "Flight" },
                            new Loc { LocProvider = "FOC31", MessageIntegration = "Ok", StatusIntegration = "OK", ProductType = "Hotel" },
                            new Loc { LocProvider = "VIOJO", MessageIntegration = "Ok", StatusIntegration = "OK", ProductType = "Car" },
                        }
                    };
                }
                catch (Exception e)
                {
                    throw e;
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