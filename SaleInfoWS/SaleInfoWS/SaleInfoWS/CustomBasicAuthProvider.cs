using ServiceStack;
using ServiceStack.Auth;
using ServiceStack.OrmLite;
using ServiceStack.OrmLite.PostgreSQL;
using System.Configuration;
using System.Data;

namespace BackOfficeWS
{
    public class CustomBasicAuthProvider : BasicAuthProvider
    {
        /// <summary>
        /// Abre la conexion de la BD configurada en el WebConfig.
        /// </summary>
        /// <returns>El objeto de conexion de la BD.</returns>
        private IDbConnection Connect()
        {
            OrmLiteConnectionFactory dbFactory = new OrmLiteConnectionFactory(
                ConfigurationManager.ConnectionStrings["FrontEndConnection"].ConnectionString, PostgreSqlDialect.Provider);

            return dbFactory.OpenDbConnection();
        }

        public override bool TryAuthenticate(IServiceBase authService,
            string userName, string password)
        {
            // Aqui se pone la logica para autenticar, y se retorna un
            // booleano dependiendo de si la autenticacion fue exitosa
            // o no (true, false). Se puede hacer uso del metodo Connect
            // para realizar la conexion a la base de datos y confirmar
            // las credenciales.
            return true;
        }
    }
}