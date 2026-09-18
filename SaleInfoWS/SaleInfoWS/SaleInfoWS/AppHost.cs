using Funq;
using ServiceStack;
using SaleInfoWS.ServiceInterface;
using BackOfficeWS;
using ServiceStack.Auth;

namespace SaleInfoWS
{
    //VS.NET Template Info: https://servicestack.net/vs-templates/EmptyAspNet
    public class AppHost : AppHostBase
    {
        /// <summary>
        /// Base constructor requires a Name and Assembly where web service implementation is located
        /// </summary>
        public AppHost()
            : base("SaleInfoWS", typeof(MyServices).Assembly) { }

        /// <summary>
        /// Application specific configuration
        /// This method should initialize any IoC resources utilized by your web service classes.
        /// </summary>
        public override void Configure(Container container)
        {
            //Config examples
            //this.Plugins.Add(new PostmanFeature());
            //this.Plugins.Add(new CorsFeature());

            this.Plugins.Add(new CorsFeature(allowedHeaders: "Content-Type, Authorization, Session-Id, Client-Id"));

            Plugins.Add(new AuthFeature(() => new CustomUserSession(), 
              new IAuthProvider[] { 
                new CustomBasicAuthProvider()//,  new IFOpenID()
              }));

            // Interceptor global de licenciamiento (KOR1)
            GlobalRequestFilters.Add((req, res, requestDto) =>
            {
                var validation = LicenseValidator.ValidateLicense();
                if (!validation.IsValid)
                {
                    res.StatusCode = (int)System.Net.HttpStatusCode.PaymentRequired;
                    res.ContentType = "application/json; charset=utf-8";
                    res.WriteToResponse(req, new
                    {
                        Status = "Error",
                        Code = "LICENSE_EXPIRED_OR_INVALID",
                        Message = validation.ErrorMessage
                    });
                    res.EndRequest();
                }
            });
        }
    }
}