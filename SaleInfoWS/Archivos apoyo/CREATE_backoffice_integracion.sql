CREATE TABLE Consolidator20_pruebas.dbo.backoffice_integracion (
  id int IDENTITY, -- Consecutivo de la tabla
  fecha_creacion_registro datetime NOT NULL DEFAULT GETDATE(), -- Fecha de creacion del registro
  portal varchar(100) NOT NULL, -- Direccion web en la que se hizo la reserva
  canal varchar(10) NOT NULL, -- Canal por el que se hizo la reserva b2b/b2c
  medio varchar(20) NOT NULL, -- Portal, WS, App
  evento varchar(20) NOT NULL,  Eventio que genero el envio de informacion al backoffice RESERVA|EMISION|ANULACION|APROBACION
  localizador varchar(10) NOT NULL,  --Codig interno en la plataforma de ideasfractal
  date_book datetime NULL,  --Fecha en que se hizo la reserva en el portal
  incluye_vuelos bit NULL,  --Indica si lanformacion enviada contiene vuelos
  incluye_hoteles bit NULL,--Indica si lanformacion enviada contiene hotels
  incluye_carros bit NULL,--Indica si lanformacion enviada contiene autos
  incluye_seguros bit NULL,--Indica si lanformacion enviada contiene seguros
  incluye_paquetes bit NULL,--Indica si lanformacion enviada contiene paquetes
  xml varchar(max) NOT NULL,   --En este campo se almacena l informacion del XML que contiene todos los dato de la reserva
  fecha_lectura datetime NULL,   --este campo debe ser actualizado por la agencia para que pueda llevar un control de cuando fue procesada hacia su backoffice
  status
  observacion
  modoEnvio    varchar(1)  --Modo en que se envio la informacion A(Automatica)  M(manual) el automatico se da cuando el envio se da por la generacion de alguno de los eventos arriba mencionados
)