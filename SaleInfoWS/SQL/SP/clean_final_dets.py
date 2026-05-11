import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Definir la función de nacionalidad como un snippet para reutilizar
    nationality_logic = """
			-- Validar Nacionalidad (Nacional=1, Internacional=2)
			IF EXISTS(SELECT A.id FROM public."Airports" A
			  INNER JOIN public."Cities" C ON C.id = A."citiesId"
			  INNER JOIN public."Countries" P ON P.id = C."countriesId"
			  INNER JOIN public."SystemParameter" PR ON PR.code='Pais' AND PR.value<>P.name 
			  WHERE A.code = {loc_var})
			THEN
				v_inNationality := 2;
			ELSE
				v_inNationality := 1;
			END IF;
"""

    # 2. Reemplazar DetCar con la lógica de nacionalidad integrada
    # Buscamos el bloque DetCar que insertamos antes
    new_detcar = """If(p_Op='DetCar')
	Begin
		DECLARE 
			v_BookingProductId INTEGER;
			v_inNationality INTEGER := 1;
		BEGIN
			""" + nationality_logic.replace("{loc_var}", "COALESCE(p_cd_citysalida, p_origin)") + """

			-- 1. Insertamos el Producto Principal (Auto)
			INSERT INTO public."BookingProductGDS" (
				"bookingId", code, type, "service", "description", "provider", "quantity",
				price, cost, "checkInDate", "checkOutDate", "reservationcode", "state", "inNationality"
			) VALUES (
				p_id_Booking, COALESCE(p_code, ''), COALESCE(p_productType, 'Auto'),
				COALESCE(p_productService, 'Renta de Auto'), COALESCE(p_productDescription, 'Servicio de Renta de Auto'),
				p_provider, 1, COALESCE(p_amount, 0), 0, p_checkInDate, p_checkOutDate, p_code, 'NUEVO', v_inNationality
			) RETURNING id INTO v_BookingProductId;

			-- 2. Impuestos si aplican
			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId", code, name, type, percentage, amount
				) VALUES (
					v_BookingProductId, COALESCE(p_taxCode, 'IVA'), COALESCE(p_taxName, 'IVA Auto'),
					COALESCE(p_taxType, 'IMP'), COALESCE(p_perTax, 0), p_tax
				);
			END IF;
			RETURN;
		END;
	End"""

    # 3. Reemplazar DetHotel
    new_dethotel = """If(p_Op='DetHotel')
	Begin
		DECLARE 
			v_BookingProductId INTEGER;
			v_inNationality INTEGER := 1;
		BEGIN
			""" + nationality_logic.replace("{loc_var}", "COALESCE(p_cd_city, p_origin)") + """

			-- 1. Insertamos el Producto Principal (Hotel)
			INSERT INTO public."BookingProductGDS" (
				"bookingId", code, type, "service", "description", "provider", "quantity",
				price, cost, "checkInDate", "checkOutDate", "reservationcode", "state", "inNationality"
			) VALUES (
				p_id_Booking, COALESCE(p_code, ''), COALESCE(p_productType, 'Hotel'),
				COALESCE(p_productService, 'Alojamiento'), COALESCE(p_productDescription, 'Reserva de Hotel'),
				p_provider, 1, COALESCE(p_amount, 0), 0, p_checkInDate, p_checkOutDate, p_code, 'NUEVO', v_inNationality
			) RETURNING id INTO v_BookingProductId;

			-- 2. Impuestos si aplican
			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId", code, name, type, percentage, amount
				) VALUES (
					v_BookingProductId, COALESCE(p_taxCode, 'IVA'), COALESCE(p_taxName, 'IVA Hotel'),
					COALESCE(p_taxType, 'IMP'), COALESCE(p_perTax, 0), p_tax
				);
			END IF;
			RETURN;
		END;
	End"""

    # 4. Definir DetSrv (Servicios de Terceros)
    new_detsrv = """If(p_Op='DetSrv')
	Begin
		DECLARE 
			v_BookingProductId INTEGER;
			v_inNationality INTEGER := 1;
		BEGIN
			""" + nationality_logic.replace("{loc_var}", "COALESCE(p_origin, '')") + """

			-- 1. Insertamos el Producto Principal (Servicio/Otros)
			INSERT INTO public."BookingProductGDS" (
				"bookingId", code, type, "service", "description", "provider", "quantity",
				price, cost, "checkInDate", "checkOutDate", "reservationcode", "state", "inNationality"
			) VALUES (
				p_id_Booking, COALESCE(p_code, ''), COALESCE(p_productType, 'Servicio'),
				COALESCE(p_productService, 'Servicio Adicional'), COALESCE(p_productDescription, 'Servicio de Terceros'),
				p_provider, 1, COALESCE(p_amount, 0), 0, p_checkInDate, p_checkOutDate, p_code, 'NUEVO', v_inNationality
			) RETURNING id INTO v_BookingProductId;

			-- 2. Impuestos si aplican
			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId", code, name, type, percentage, amount
				) VALUES (
					v_BookingProductId, COALESCE(p_taxCode, 'IVA'), COALESCE(p_taxName, 'IVA Servicio'),
					COALESCE(p_taxType, 'IMP'), COALESCE(p_perTax, 0), p_tax
				);
			END IF;
			RETURN;
		END;
	End"""

    # Realizar reemplazos
    # Reemplazar DetCar
    content = re.sub(r"If\(p_Op='DetCar'\).*?End", new_detcar, content, flags=re.IGNORECASE | re.DOTALL)
    # Reemplazar DetHotel
    content = re.sub(r"If\(p_Op='DetHotel'\).*?End", new_dethotel, content, flags=re.IGNORECASE | re.DOTALL)
    # Reemplazar DetSrv
    content = re.sub(r"If\(p_Op='DetSrv'\).*?End", new_detsrv, content, flags=re.IGNORECASE | re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("DetSrv limpiado e integrada lógica de nacionalidad en todos los productos.")
except Exception as e:
    print(f"Error: {e}")
