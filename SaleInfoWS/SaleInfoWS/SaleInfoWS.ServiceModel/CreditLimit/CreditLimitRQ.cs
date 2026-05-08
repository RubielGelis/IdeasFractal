using SaleInfoWS.ServiceModel.Types;
using ServiceStack;
using ServiceStack.DataAnnotations;
using System;
using System.Runtime.Serialization;

namespace SaleInfoWS.ServiceModel.CreditLimit
{
    // NOTE: Generated code may require at least .NET Framework 4.5 or .NET Core/Standard 2.0.
    // <Summary>
    // Clase que define el request del micro servicio y que a su vez mapea la tabla
    // que guarda la informacion en la base de datos.
    // </Summary>
    /// <remarks/>
    [Serializable()]
    [System.ComponentModel.DesignerCategory("code")]
    [System.Xml.Serialization.XmlType(AnonymousType = true)]
    [System.Xml.Serialization.XmlRoot(Namespace = "", IsNullable = false)]
    [Route("/credit-limit", Notes = "Servicio que se encarga de guardar la informacion del " +
        "credito de un producto dado en una reserva.",
        Summary = "Informacion del limite crediticio", Verbs = "POST")]
    public class CreditLimitRQ
    {

        // Llave primaria del registro en la base de datos.
        [AutoIncrement]
        [IgnoreDataMember]
        public int? Id { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Codigo del cliente en el backoffice de la agencia.")]
        public int CodeClientBackOffice { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Codigo del cliente en el OBT-KontrolTravel.")]
        public int CodeClientOBT { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Nombre del cliente.")]
        public string Name { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Loc al que se le esta haciendo el proceso de reserva/emision.")]
        public string ValidationLoc { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Valor que tiene la transaccion que se esta validando.")]
        public int Value { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Moneda en la que se esta haciendo la transaccion.")]
        public string Currency { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Tipo de producto que se esta procesando.", DataType = "string")]
        [ApiAllowableValues("Product", typeof(Product))]
        public Product Product { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Descripcion de la transaccion que se esta validando.")]
        public string Description { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Forma de pago de la transaccion.", DataType = "string")]
        [ApiAllowableValues("PaymentType", typeof(PaymentType))]
        public PaymentType PaymentType { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Email del usuario que esta haciendo la transaccion.")]
        public string UserEmail { get; set; }

        // Estado de la transaccion en el sistema.
        [IgnoreDataMember]
        public string Status { get; set; }

        // Mensaje de validacion de la transaccion.
        [IgnoreDataMember]
        public string ValidationMessage { get; set; }
    }


}
