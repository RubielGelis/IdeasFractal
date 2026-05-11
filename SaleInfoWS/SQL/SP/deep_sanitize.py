import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Definir los bloques limpios
    
    # SNIPPET NACIONALIDAD
    nat_logic = """
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

    # DETCAR
    block_car = """	IF p_Op = 'DetCar' THEN
		DECLARE 
			v_BookingProductId INTEGER;
			v_inNationality INTEGER := 1;
		BEGIN
			""" + nat_logic.replace("{loc_var}", "COALESCE(p_cd_citysalida, p_origin)") + """

			INSERT INTO public."BookingProductGDS" (
				"bookingId", code, type, "service", "description", "provider", "quantity",
				price, cost, "checkInDate", "checkOutDate", "reservationcode", "state", "inNationality"
			) VALUES (
				p_id_Booking, COALESCE(p_code, ''), COALESCE(p_productType, 'Auto'),
				COALESCE(p_productService, 'Renta de Auto'), COALESCE(p_productDescription, 'Servicio de Renta de Auto'),
				p_provider, 1, COALESCE(p_amount, 0), 0, p_checkInDate, p_checkOutDate, p_code, 'NUEVO', v_inNationality
			) RETURNING id INTO v_BookingProductId;

			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId", code, name, type, percentage, amount
				) VALUES (
					v_BookingProductId, COALESCE(p_taxCode, 'IVA'), COALESCE(p_taxName, 'IVA Auto'),
					COALESCE(p_taxType, 'IMP'), COALESCE(p_perTax, 0), p_tax
				);
			END IF;
		END;
	END IF;
"""

    # DETHOTEL
    block_hotel = """	IF p_Op = 'DetHotel' THEN
		DECLARE 
			v_BookingProductId INTEGER;
			v_inNationality INTEGER := 1;
		BEGIN
			""" + nat_logic.replace("{loc_var}", "COALESCE(p_cd_city, p_origin)") + """

			INSERT INTO public."BookingProductGDS" (
				"bookingId", code, type, "service", "description", "provider", "quantity",
				price, cost, "checkInDate", "checkOutDate", "reservationcode", "state", "inNationality"
			) VALUES (
				p_id_Booking, COALESCE(p_code, ''), COALESCE(p_productType, 'Hotel'),
				COALESCE(p_productService, 'Alojamiento'), COALESCE(p_productDescription, 'Reserva de Hotel'),
				p_provider, 1, COALESCE(p_amount, 0), 0, p_checkInDate, p_checkOutDate, p_code, 'NUEVO', v_inNationality
			) RETURNING id INTO v_BookingProductId;

			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId", code, name, type, percentage, amount
				) VALUES (
					v_BookingProductId, COALESCE(p_taxCode, 'IVA'), COALESCE(p_taxName, 'IVA Hotel'),
					COALESCE(p_taxType, 'IMP'), COALESCE(p_perTax, 0), p_tax
				);
			END IF;
		END;
	END IF;
"""

    # DETSRV
    block_srv = """	IF p_Op = 'DetSrv' THEN
		DECLARE 
			v_BookingProductId INTEGER;
			v_inNationality INTEGER := 1;
		BEGIN
			""" + nat_logic.replace("{loc_var}", "COALESCE(p_origin, '')") + """

			INSERT INTO public."BookingProductGDS" (
				"bookingId", code, type, "service", "description", "provider", "quantity",
				price, cost, "checkInDate", "checkOutDate", "reservationcode", "state", "inNationality"
			) VALUES (
				p_id_Booking, COALESCE(p_code, ''), COALESCE(p_productType, 'Servicio'),
				COALESCE(p_productService, 'Servicio Adicional'), COALESCE(p_productDescription, 'Servicio de Terceros'),
				p_provider, 1, COALESCE(p_amount, 0), 0, p_checkInDate, p_checkOutDate, p_code, 'NUEVO', v_inNationality
			) RETURNING id INTO v_BookingProductId;

			IF COALESCE(p_tax, 0) > 0 THEN
				INSERT INTO public."BookingProductTaxGDS" (
					"bookingProductId", code, name, type, percentage, amount
				) VALUES (
					v_BookingProductId, COALESCE(p_taxCode, 'IVA'), COALESCE(p_taxName, 'IVA Servicio'),
					COALESCE(p_taxType, 'IMP'), COALESCE(p_perTax, 0), p_tax
				);
			END IF;
		END;
	END IF;
"""

    # Poliza, PaxAdicional, etc
    block_rest = """	IF p_Op = 'Poliza' THEN
		INSERT INTO public."BookingProductVariableGDS"("bookingProductId", code, name, "value")
		VALUES (p_bookingProductId, 'POLIZA', 'Poliza', COALESCE(p_policy, ''));
	END IF;

	IF p_Op = 'PaxAdicional' THEN
		INSERT INTO public."BookingProductPassangerGDS"("bookingProductId", "firstName", "lastName", "identification", "type")
		VALUES (p_bookingProductId, p_firstName, p_lastName, p_identification, p_type);
	END IF;

	IF p_Op = 'VarAdicional' THEN 
		INSERT INTO public."BookingProductVariableGDS"("bookingProductId", code, name, "value")
		VALUES (p_bookingProductId, COALESCE(p_varName, 'VAR'), p_varName, p_varValue);
	END IF;
	
	IF p_Op = 'CargosImpuestos' THEN
		INSERT INTO public."BookingProductTaxGDS"("bookingProductId", code, name, type, percentage, amount)
		VALUES (p_bookingProductId, COALESCE(p_taxCode, 'TAX'), COALESCE(p_taxName, 'Impuesto'), COALESCE(p_taxType, 'IMP'), COALESCE(p_perTax, 0), p_tax);
	END IF;

	IF p_Op = 'FormasPagos' THEN
		INSERT INTO public."BookingProductPaymentGDS"(
			"bookingProductId", code, name, type, "typecreditcard", "numbercreditcard", 
			"vouchercreditcard", "expiredcreditcard", "authcreditcard", "quotas", 
			"bank", "square", "reference", "policy", "policyannex", amount
		)
		VALUES (
			p_bookingProductId, COALESCE(p_paymentCode, 'PAG'), COALESCE(p_paymentName, 'Pago'), COALESCE(p_paymentType, 'EFECTIVO'), p_creditCardType, p_creditCardNumber, 
			p_voucher, p_expirationDate, p_authorization, p_quotas, 
			p_bank, p_square, p_reference, p_policy, p_policyAnnex, p_amount
		);
	END IF;

	IF p_Op = 'FEE' THEN
		INSERT INTO public."BookingProductFEEGDS"(
			"bookingProductId", code, name, type, "description", "billigconcept", "servicetype", amount, tax, other, total
		)
		VALUES (
			p_bookingProductId, COALESCE(p_feeCode, 'FEE'), COALESCE(p_feeName, 'Fee'), COALESCE(p_feeType, 'FEE'), COALESCE(p_feeDescription, ''), 
			COALESCE(p_feeBillingConcept, '1'), COALESCE(p_feeServiceType, '1'), p_amount, 0, 0, p_amount
		);
	END IF;
"""

    # 2. Reemplazar desde DetCar hasta el final (incluyendo el desorden)
    # Buscamos IF p_Op = 'DetCar'
    pattern_replace = r"IF\s+p_Op\s*=\s*'DetCar'\s+THEN.*"
    
    final_logic = block_car + "\n" + block_hotel + "\n" + block_srv + "\n" + block_rest + "\nEND;\n$$ LANGUAGE plpgsql;"
    
    content = re.sub(pattern_replace, final_logic, content, flags=re.IGNORECASE | re.DOTALL)

    # 3. Corregir sintaxis general de asignaciones y bloques IF/END IF en el resto del archivo
    content = re.sub(r"SET\s+([\w\"]+)\s*=\s*", r"\1 := ", content, flags=re.IGNORECASE)
    content = re.sub(r"If\s*\((p_Op\s*=\s*'[^']+')\)\s*Begin", r"IF \1 THEN\n\tBEGIN", content, flags=re.IGNORECASE)
    content = re.sub(r"End\s+IF", r"END IF", content, flags=re.IGNORECASE)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Saneamiento completo realizado.")
except Exception as e:
    print(f"Error: {e}")
