using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using ServiceStack.OrmLite;
using ServiceStack.OrmLite.PostgreSQL;
using ServiceStack.OrmLite.SqlServer;
using ServiceStack.Text;

namespace SaleInfoWS
{
    public class LicenseValidationResult
    {
        public bool IsValid { get; set; }
        public string ErrorMessage { get; set; }
        public string ClientName { get; set; }
        public string Nit { get; set; }
        public string ExpirationDate { get; set; }
    }

    public static class LicenseValidator
    {
        private const string DEFAULT_SECRET_KEY = "Korex_Master_License_Secret_Key_2026_Secure";

        /// <summary>
        /// Valida la licencia configurada en la BD o en el Web.config.
        /// </summary>
        public static LicenseValidationResult ValidateLicense()
        {
            string licenseKey = GetConfigValue("LICENSE_KEY", "LicenseKey");
            string configuredNit = GetConfigValue("AGENCY_NIT", "ClientNit");

            if (string.IsNullOrWhiteSpace(licenseKey))
            {
                return new LicenseValidationResult
                {
                    IsValid = false,
                    ErrorMessage = "Licencia no configurada (UNLICENSED). Ingrese una clave de licencia KOR1 válida para habilitar el servicio."
                };
            }

            var verification = VerifyToken(licenseKey);
            if (!verification.IsValid)
            {
                return verification;
            }

            // Validar NIT de la empresa si está configurado
            if (!string.IsNullOrWhiteSpace(configuredNit) && !string.IsNullOrWhiteSpace(verification.Nit))
            {
                string normConfig = CleanNit(configuredNit);
                string normToken = CleanNit(verification.Nit);

                if (!string.IsNullOrEmpty(normConfig) && !string.IsNullOrEmpty(normToken) && normConfig != normToken)
                {
                    return new LicenseValidationResult
                    {
                        IsValid = false,
                        ErrorMessage = string.Format(
                            "Incompatibilidad de licencia: El NIT de la licencia ({0}) no coincide con el NIT configurado en la agencia ({1}).",
                            verification.Nit, configuredNit)
                    };
                }
            }

            // Validar fecha de expiración
            if (!string.IsNullOrWhiteSpace(verification.ExpirationDate))
            {
                DateTime expDate;
                if (DateTime.TryParse(verification.ExpirationDate, out expDate))
                {
                    // Expiración al final del día
                    DateTime endOfDay = expDate.Date.AddDays(1).AddTicks(-1);
                    if (DateTime.Now > endOfDay)
                    {
                        return new LicenseValidationResult
                        {
                            IsValid = false,
                            ErrorMessage = string.Format(
                                "Licencia de IdeasFractal vencida el {0}. El servicio ha sido desactivado y no procesará más solicitudes a no ser que se aplique la actualización de la licencia.",
                                verification.ExpirationDate)
                        };
                    }
                }
            }

            return verification;
        }

        /// <summary>
        /// Verifica criptográficamente la estructura y firma HMAC-SHA256 del token KOR1
        /// </summary>
        public static LicenseValidationResult VerifyToken(string licenseKey)
        {
            if (string.IsNullOrWhiteSpace(licenseKey))
            {
                return new LicenseValidationResult { IsValid = false, ErrorMessage = "La clave de licencia está vacía." };
            }

            string[] parts = licenseKey.Trim().Split('.');
            if (parts.Length != 3 || parts[0] != "KOR1")
            {
                return new LicenseValidationResult { IsValid = false, ErrorMessage = "Formato de clave de licencia desconocido. Debe iniciar con 'KOR1.'" };
            }

            string payloadBase64 = parts[1];
            string signature = parts[2];

            string secretKey = ConfigurationManager.AppSettings["LicenseSecret"] ?? DEFAULT_SECRET_KEY;

            try
            {
                // Recomputar firma HMAC SHA256
                string expectedSignature;
                using (var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secretKey)))
                {
                    byte[] hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(payloadBase64));
                    StringBuilder hex = new StringBuilder(hash.Length * 2);
                    foreach (byte b in hash)
                    {
                        hex.AppendFormat("{0:x2}", b);
                    }
                    expectedSignature = hex.ToString();
                }

                if (!string.Equals(signature, expectedSignature, StringComparison.OrdinalIgnoreCase))
                {
                    return new LicenseValidationResult
                    {
                        IsValid = false,
                        ErrorMessage = "La firma de la clave de licencia es inválida o fue alterada."
                    };
                }

                // Decodificar Base64Url
                string json = DecodeBase64Url(payloadBase64);
                var jsonObj = JsonObject.Parse(json);

                string client = jsonObj.Get("c");
                string nit = jsonObj.Get("n");
                string expirationDate = jsonObj.Get("e");

                if (string.IsNullOrWhiteSpace(client) || string.IsNullOrWhiteSpace(nit) || string.IsNullOrWhiteSpace(expirationDate))
                {
                    return new LicenseValidationResult
                    {
                        IsValid = false,
                        ErrorMessage = "Contenido de la clave de licencia incompleto."
                    };
                }

                return new LicenseValidationResult
                {
                    IsValid = true,
                    ClientName = client,
                    Nit = nit,
                    ExpirationDate = expirationDate
                };
            }
            catch (Exception ex)
            {
                return new LicenseValidationResult
                {
                    IsValid = false,
                    ErrorMessage = "Error al decodificar la clave de licencia: " + ex.Message
                };
            }
        }

        private static string GetConfigValue(string codeName, string appSettingsFallbackKey)
        {
            // 1. Intentar consultar desde la Base de Datos
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["FrontEndConnection"] != null 
                    ? ConfigurationManager.ConnectionStrings["FrontEndConnection"].ConnectionString 
                    : null;

                if (!string.IsNullOrEmpty(connStr))
                {
                    string dbType = ConfigurationManager.AppSettings["DatabaseType"] ?? "PostgreSQL";
                    OrmLiteConnectionFactory dbFactory;
                    if (dbType.Equals("SqlServer", StringComparison.OrdinalIgnoreCase))
                    {
                        dbFactory = new OrmLiteConnectionFactory(connStr, SqlServerDialect.Provider);
                    }
                    else
                    {
                        dbFactory = new OrmLiteConnectionFactory(connStr, PostgreSqlDialect.Provider);
                    }

                    using (var db = dbFactory.OpenDbConnection())
                    {
                        string query = dbType.Equals("SqlServer", StringComparison.OrdinalIgnoreCase)
                            ? "SELECT value FROM dbo.SystemParameter WHERE code = @code"
                            : "SELECT \"value\" FROM public.\"SystemParameter\" WHERE \"code\" = @code";

                        string dbVal = db.Scalar<string>(query, new { code = codeName });
                        if (!string.IsNullOrWhiteSpace(dbVal))
                        {
                            return dbVal.Trim();
                        }
                    }
                }
            }
            catch
            {
                // Si la BD aún no está disponible o falla la tabla, hace fallback a Web.config
            }

            // 2. Fallback a Web.config
            string configVal = ConfigurationManager.AppSettings[codeName] 
                            ?? ConfigurationManager.AppSettings[appSettingsFallbackKey];

            return configVal != null ? configVal.Trim() : null;
        }

        private static string DecodeBase64Url(string base64Url)
        {
            string base64 = base64Url.Replace('-', '+').Replace('_', '/');
            switch (base64.Length % 4)
            {
                case 2: base64 += "=="; break;
                case 3: base64 += "="; break;
            }
            byte[] bytes = Convert.FromBase64String(base64);
            return Encoding.UTF8.GetString(bytes);
        }

        private static string CleanNit(string nit)
        {
            if (string.IsNullOrWhiteSpace(nit)) return "";
            return Regex.Replace(nit, @"\D", "");
        }
    }
}
