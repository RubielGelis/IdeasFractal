import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_detcar_block = """If(p_Op='DetCar')
	Begin
		DECLARE 
			v_BookingProductId INTEGER;
		BEGIN
			-- 1. Insertamos el Producto Principal (Auto)
			INSERT INTO public."BookingProductGDS" (
				"bookingId",
				code,
				type,
				"service",
				"description",
				"provider",
				"quantity",
				price,
				cost,
				"checkInDate",
				"checkOutDate",
				"reservationcode",
				"state"
			) VALUES (
				p_id_Booking,
				COALESCE(p_code, ''),
				COALESCE(p_productType, 'Auto'),
				COALESCE(p_productService, 'Renta de Auto'),
				COALESCE(p_productDescription, 'Servicio de Renta de Auto'),
				p_provider,
				1,
				COALESCE(p_amount, 0),
				0,
				p_checkInDate,
				p_checkOutDate,
				p_code,
				'NUEVO'
			) RETURNING id INTO v_BookingProductId;

			-- 2. Impuestos si aplican
			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId",
					code,
					name,
					type,
					percentage,
					amount
				) VALUES (
					v_BookingProductId,
					COALESCE(p_taxCode, 'IVA'),
					COALESCE(p_taxName, 'IVA Auto'),
					COALESCE(p_taxType, 'IMP'),
					COALESCE(p_perTax, 0),
					p_tax
				);
			END IF;

			RETURN;
		END;
	End
"""

    new_dethotel_block = """	If(p_Op='DetHotel')
	Begin
		DECLARE 
			v_BookingProductId INTEGER;
		BEGIN
			-- 1. Insertamos el Producto Principal (Hotel)
			INSERT INTO public."BookingProductGDS" (
				"bookingId",
				code,
				type,
				"service",
				"description",
				"provider",
				"quantity",
				price,
				cost,
				"checkInDate",
				"checkOutDate",
				"reservationcode",
				"state"
			) VALUES (
				p_id_Booking,
				COALESCE(p_code, ''),
				COALESCE(p_productType, 'Hotel'),
				COALESCE(p_productService, 'Alojamiento'),
				COALESCE(p_productDescription, 'Reserva de Hotel'),
				p_provider,
				1,
				COALESCE(p_amount, 0),
				0,
				p_checkInDate,
				p_checkOutDate,
				p_code,
				'NUEVO'
			) RETURNING id INTO v_BookingProductId;

			-- 2. Impuestos si aplican
			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId",
					code,
					name,
					type,
					percentage,
					amount
				) VALUES (
					v_BookingProductId,
					COALESCE(p_taxCode, 'IVA'),
					COALESCE(p_taxName, 'IVA Hotel'),
					COALESCE(p_taxType, 'IMP'),
					COALESCE(p_perTax, 0),
					p_tax
				);
			END IF;

			RETURN;
		END;
	End
"""

    # Buscar el bloque DetCar y reemplazarlo
    pattern_car = r"(If\(p_Op='DetCar'\))(.*?)(If\(p_Op='DetHotel'\))"
    def replacer_car(match):
        return new_detcar_block + "\n" + match.group(3)
    content = re.sub(pattern_car, replacer_car, content, flags=re.IGNORECASE | re.DOTALL)

    # Buscar el bloque DetHotel y reemplazarlo
    pattern_hotel = r"(If\(p_Op='DetHotel'\))(.*?)(If\(p_Op='DetSrv'\))"
    def replacer_hotel(match):
        return new_dethotel_block + "\n" + match.group(3)
    content = re.sub(pattern_hotel, replacer_hotel, content, flags=re.IGNORECASE | re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Bloques DetCar y DetHotel reemplazados exitosamente.")
except Exception as e:
    print(f"Error: {e}")
