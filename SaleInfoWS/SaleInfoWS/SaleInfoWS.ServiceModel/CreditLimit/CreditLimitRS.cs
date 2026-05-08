using ServiceStack;
using System;

namespace SaleInfoWS.ServiceModel.CreditLimit
{

    // NOTE: Generated code may require at least .NET Framework 4.5 or .NET Core/Standard 2.0.
    /// <remarks/>
    [Serializable()]
    [System.ComponentModel.DesignerCategory("code")]
    [System.Xml.Serialization.XmlType(AnonymousType = true)]
    [System.Xml.Serialization.XmlRoot(Namespace = "", IsNullable = false)]
    public class CreditLimitRS
    {

        /// <remarks/>
        [ApiMember(Description = "Codigo del cliente en el BackOffice de la agencia.")]
        public int CodeClientBackOffice { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Codigo del cliente en el OBT-KontrolTravel.")]
        public int CodeClientOBT { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Estado de la transaccion, OK (Proceder) - NO-OK (No proceder).")]
        public string Status { get; set; }

        /// <remarks/>
        [ApiMember(Description = "Mensaje que se debe mostrar de la evaluacion en caso que no se pueda proceder.")]
        public string Message { get; set; }
    }


}
