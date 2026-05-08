

0.  Crear una clase que es la que llama el wrapper que genera el JSON
0.1 Debe tener el almacenamiento en los logs.
0.2 Es la que vas a llamar en el manejador de senales y en el listado de reintentos(punto 5)

1. Crear source   BackofficeGenerico
   Datos de conexion son:
         Nombre: Nombre de la conexion, ejemplo: Cocha-backoffice
		 URL: Direccion donde esta el WS, ejemplo:https://facturacion.vemsa.travel/dconect
		 Autenticacion: basic generado por la agencia, ejemplo: Basic aWRlYXMuYWRtaW46WEFkbWluSyowMQ==
		 Productos: Nombre de los productos a integrar, Aereo, Hotel, Asistencia,
		 CodigosSource: Codigo de los sources a integrar, ejemplo:  4,23,56
2. Crear la senal con codigo 20(ejemplo)
3. Guardar los locs de ejecucion, crear tabla log_SalesInfoRQ
     -Id
	 -CodigoEntidad: Codigo de la entidad que hizo la peticion
 	 -UsuarioLlamo: Usuario que hizo el proceso de integracion
	 -loc: Localizador interno 
	 -dateBook: fecha en que se hizo la peticion 
	 -evento: Evento de integracion [Reserva|Aprobacion|Emision|]
	 -Channel:  Canal de integracion: WS|COnsola(web o automatica)
	 -portal:  URL
	 -Technology: 
	 -includeFlights
	 -includeCars
	 -includeHotels
	 -includeInsurance
	 -includePackage
	 -payloadRQ  TEXT
	 -SalesInfoRS  TEXT
	 -Sendform
	 -statusIntegracion
	 A) Antes de llamar el servicio de la agencia grabas en la tabla menos los campos:statusIntegracion y payloadRS
	 b) Grabas la informacion y acualizas los campos  statusIntegracion y payloadRS
4.  Reporte de ejecucion
    -Parametro que indique la entidad raiz
    - Reporte select trayendo lo hijos de la entidad raiz
    - la forma del reporte como el que le mostre a laura de bogota	
3. Hacer un listado que permita hacer reintentos, debe recibir el loc, la entidad y los mismos datos