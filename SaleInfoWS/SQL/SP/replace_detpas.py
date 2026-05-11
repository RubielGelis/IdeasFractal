import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    new_detpas_block = """
	If(p_Op='DetPas')
	Begin
		DECLARE 
			v_BookingProductId INTEGER;
		BEGIN
			-- 1. Insertamos el Producto Principal (Tiquete)
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
				"reservationcode",
				"state"
			) VALUES (
				p_id_Booking,
				COALESCE(p_code, ''),
				'Tiquete',
				'Tiquete Aereo',
				'Emision de Tiquete',
				p_provider,
				1,
				COALESCE(p_amount, 0),
				0,
				p_code,
				'NUEVO'
			) RETURNING id INTO v_BookingProductId;

			-- 2. Insertamos el Pasajero
			IF COALESCE(p_firstName, '') <> '' THEN
				INSERT INTO public."BookingProductPassangerGDS" (
					"bookingProductId",
					"firstName",
					"lastName",
					"documentType",
					"identification",
					"email",
					"phone",
					"type"
				) VALUES (
					v_BookingProductId,
					p_firstName,
					p_lastName,
					p_documentType,
					p_identification,
					p_email,
					p_phone,
					p_type
				);
			END IF;

			-- 3. Insertamos el Itinerario
			IF COALESCE(p_origin, '') <> '' THEN
				INSERT INTO public."BookingProductItineraryGDS" (
					"bookingProductId",
					"orden",
					"origin",
					"destination",
					"class",
					"checkInDate",
					"checkOutDate",
					"terminal",
					"prestadoraCode",
					"farebasis",
					"Numflight",
					"Typeflight",
					"amount"
				) VALUES (
					v_BookingProductId,
					COALESCE(p_orden, 1),
					p_origin,
					p_destination,
					p_class,
					p_checkInDate,
					p_checkOutDate,
					p_terminal,
					p_prestadoraCode,
					p_farebasis,
					p_Numflight,
					p_Typeflight,
					COALESCE(p_amount, 0)
				);
			END IF;

			-- 4. Insertamos los Impuestos (si los hay)
			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId",
					code,
					name,
					amount
				) VALUES (
					v_BookingProductId,
					'IVA',
					'IVA Tiquete',
					p_tax
				);
			END IF;
			
			IF COALESCE(p_fee, 0) > 0 THEN
				INSERT INTO public."BookingProductFEEGDS" (
					"bookingProductId",
					code,
					name,
					type,
					description,
					billigconcept,
					servicetype,
					amount,
					tax,
					other,
					total
				) VALUES (
					v_BookingProductId,
					'FEE',
					'Fee de Emision',
					'TAO',
					'Cargo Administrativo',
					'1',
					'1',
					p_fee,
					0,
					0,
					p_fee
				);
			END IF;

			RETURN;
		END;
	End

"""

    # Usamos re.DOTALL para que .* abarque los saltos de linea
    # Buscamos desde "If(p_Op='DetPas')" hasta "If(p_Op='DetItinerario')"
    pattern = r"(If\(p_Op='DetPas'\))(.*?)(If\(p_Op='DetItinerario'\))"
    
    def replacer(match):
        return new_detpas_block + match.group(3)

    new_content = re.sub(pattern, replacer, content, flags=re.IGNORECASE | re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_content)
        
    print("Bloque DetPas reemplazado exitosamente.")
except Exception as e:
    print(f"Error: {e}")
