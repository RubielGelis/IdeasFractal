namespace SaleInfoWS.ServiceModel
{
    /// <remarks/>
    [System.SerializableAttribute()]
    [System.ComponentModel.DesignerCategoryAttribute("code")]
    [System.Xml.Serialization.XmlTypeAttribute(AnonymousType = true)]
    public class Loc
    {

        private string productTypeField;

        private string locProviderField;

        private string statusIntegrationField;

        private string messageIntegrationField;

        /// <remarks/>
        public string ProductType
        {
            get
            {
                return this.productTypeField;
            }
            set
            {
                this.productTypeField = value;
            }
        }

        /// <remarks/>
        public string LocProvider
        {
            get
            {
                return this.locProviderField;
            }
            set
            {
                this.locProviderField = value;
            }
        }

        /// <remarks/>
        public string StatusIntegration
        {
            get
            {
                return this.statusIntegrationField;
            }
            set
            {
                this.statusIntegrationField = value;
            }
        }

        /// <remarks/>
        public string MessageIntegration
        {
            get
            {
                return this.messageIntegrationField;
            }
            set
            {
                this.messageIntegrationField = value;
            }
        }
    }
}
