using SaleInfoWS.ServiceModel.Types;
using ServiceStack;
using ServiceStack.DataAnnotations;
using System;

namespace SaleInfoWS.ServiceModel.SaleInfo
{
    [Serializable()]
    [System.ComponentModel.DesignerCategory("code")]
    [System.Xml.Serialization.XmlType(AnonymousType = true)]
    [System.Xml.Serialization.XmlRoot(Namespace = "", IsNullable = false)]
    [Alias("backoffice_integracion")]
    [Route("/sale-info", Notes = "Servicio que envia información de la venta desde el sistema " +
        "de Ideas a un Backoffice externo y devuelve la respuesta al sistema de Ideas.",
        Summary = "Intermediario entre sistema de ideas y backoffice externo.", Verbs = "POST")]
    public class SaleInfoRQ
    {

        private string locField;

        private DateTime dateBookField;

        private Channel channelField;

        private string portalField;

        private Technology technologyField;

        private Event eventField;

        private string payloadField;

        private bool includeFlightsField;

        private bool includeCarsField;

        private bool includeHotelsField;

        private bool includeInsuranceField;

        private bool includePackageField;

        private char statusField;

        private string observationField;

        private ShippingMethod shippingMethodField;

        private DateTime? readDateField;


        /// <remarks/>
        [Alias("localizador")]
        [ApiMember(Description = "Localizador generado por Ideas.", IsRequired = true)]
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
        [Alias("date_book")]
        [ApiMember(Description = "Fecha de creación de la reserva en el sistema.", IsRequired = true)]
        public DateTime DateBook
        {
            get
            {
                return dateBookField;
            }
            set
            {
                dateBookField = value;
            }
        }

        /// <remarks/>
        [Alias("canal")]
        [ApiMember(Description = "Canal por el que se hizo la reserva.", IsRequired = true)]
        [ApiAllowableValues("Channel", typeof(Channel))]
        public Channel Channel
        {
            get
            {
                return channelField;
            }
            set
            {
                channelField = value;
            }
        }

        /// <remarks/>
        [Alias("portal")]
        [ApiMember(Description = "Portal (URL) desde donde se hizo la reserva.", IsRequired = true)]
        public string Portal
        {
            get
            {
                return portalField;
            }
            set
            {
                portalField = value;
            }
        }

        /// <remarks/>
        [Alias("medio")]
        [ApiMember(Description = "Medio tecnologico usado para hacer la reserva.", IsRequired = true)]
        [ApiAllowableValues("Technology", typeof(Technology))]
        public Technology Technology
        {
            get
            {
                return technologyField;
            }
            set
            {
                technologyField = value;
            }
        }

        /// <remarks/>
        [Alias("evento")]
        [ApiMember(Description = "Evento que se genero.", IsRequired = true)]
        [ApiAllowableValues("Event", typeof(Event))]
        public Event Event
        {
            get
            {
                return eventField;
            }
            set
            {
                eventField = value;
            }
        }

        /// <remarks/>
        [Alias("xml")]
        [ApiMember(Description = "XML con la informacion completa de la reserva.", IsRequired = true)]
        public string Payload
        {
            get
            {
                return payloadField;
            }
            set
            {
                payloadField = value;
            }
        }

        /// <remarks/>
        [Alias("incluye_vuelos")]
        [ApiMember(Description = "Identifica si la reserva contiene por lo menos una reserva de vuelo.")]
        public bool IncludeFlights
        {
            get
            {
                return includeFlightsField;
            }
            set
            {
                includeFlightsField = value;
            }
        }

        /// <remarks/>
        [Alias("incluye_carros")]
        [ApiMember(Description = "Identifica si la reserva contiene por lo menos una reserva de auto.")]
        public bool IncludeCars
        {
            get
            {
                return includeCarsField;
            }
            set
            {
                includeCarsField = value;
            }
        }

        /// <remarks/>
        [Alias("incluye_hoteles")]
        [ApiMember(Description = "Identifica si la reserva contiene por lo menos una reserva de hoteles.")]
        public bool IncludeHotels
        {
            get
            {
                return includeHotelsField;
            }
            set
            {
                includeHotelsField = value;
            }
        }

        /// <remarks/>
        [Alias("incluye_seguros")]
        [ApiMember(Description = "Identifica si la reserva contiene por lo menos una reserva de seguros.")]
        public bool IncludeInsurance
        {
            get
            {
                return includeInsuranceField;
            }
            set
            {
                includeInsuranceField = value;
            }
        }

        [Alias("incluye_paquetes")]
        [ApiMember(Description = "Identifica si la reserva contiene por lo menos una reserva de paquetes.")]
        public bool IncludePackage
        {
            get
            {
                return includePackageField;
            }
            set
            {
                includePackageField = value;
            }
        }

        [Alias("status")]
        [ApiMember(Description = "1 - OK 0 - Error")]
        public char Status
        {
            get
            {
                return statusField;
            }
            set
            {
                statusField = value;
            }
        }

        [Alias("observacion")]
        [ApiMember(Description = "Observaciones adicionales.")]
        public string Observation
        {
            get
            {
                return observationField;
            }
            set
            {
                observationField = value;
            }
        }

        [Alias("modoEnvio")]
        [ApiMember(Description = "Modo en que se envio la informacion A(Automatica)  M(manual) el automatico se da " +
            "cuando el envio se da por la generacion de alguno de los eventos arriba mencionados")]
        [ApiAllowableValues("SendForm", typeof(ShippingMethod))]
        public ShippingMethod ShippingMethod
        {
            get
            {
                return shippingMethodField;
            }
            set
            {
                shippingMethodField = value;
            }
        }

        [Alias("fecha_lectura")]
        [ApiMember(Description = "Este campo debe ser actualizado por la agencia para que pueda llevar un control de cuando fue procesada hacia su backoffice")]
        public DateTime? ReadDate
        {
            get
            {
                return readDateField;
            }
            set
            {
                readDateField = value;
            }
        }

        /// <summary>
        /// Valida los campos requeridos en el request.
        /// </summary>
        public void Validate()
        {
            if (string.IsNullOrEmpty(Loc))
            {
                throw new ArgumentNullException("Loc");
            }
            if (DateBook == DateTime.MinValue)
            {
                throw new ArgumentNullException("DateBook");
            }
            if (string.IsNullOrEmpty(Payload))
            {
                throw new ArgumentNullException("Payload");
            }
            if (string.IsNullOrEmpty(Portal))
            {
                throw new ArgumentNullException("Portal");
            }
        }
    }
}
