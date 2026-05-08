using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SaleInfoWS.ServiceModel.SaleInfo
{

    // NOTE: Generated code may require at least .NET Framework 4.5 or .NET Core/Standard 2.0.
    /// <remarks/>
    [Serializable()]
    [System.ComponentModel.DesignerCategory("code")]
    [System.Xml.Serialization.XmlType(AnonymousType = true)]
    [System.Xml.Serialization.XmlRoot(Namespace = "", IsNullable = false)]
    public class SaleInfoRS
    {
        private string locField;

        private string codeIntegrationBackofficeField;

        private string statusIntegrationField;

        private string messageIntegrationField;

        private List<Loc> locsField;

        /// <remarks/>
        public string Loc
        {
            get
            {
                return locField;
            }
            set
            {
                locField = value;
            }
        }

        /// <remarks/>
        public string CodeIntegrationBackoffice
        {
            get
            {
                return codeIntegrationBackofficeField;
            }
            set
            {
                codeIntegrationBackofficeField = value;
            }
        }

        /// <remarks/>
        public string StatusIntegration
        {
            get
            {
                return statusIntegrationField;
            }
            set
            {
                statusIntegrationField = value;
            }
        }

        /// <remarks/>
        public string MessageIntegration
        {
            get
            {
                return messageIntegrationField;
            }
            set
            {
                messageIntegrationField = value;
            }
        }

        /// <remarks/>
        [System.Xml.Serialization.XmlArrayItem("loc", IsNullable = false)]
        public List<Loc> Locs
        {
            get
            {
                return locsField;
            }
            set
            {
                locsField = value;
            }
        }
    }
}
