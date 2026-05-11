import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Eliminar duplicados de ismain (mantenimiento de pasos anteriores)
    content = re.sub(r"ismain,\s*ismain,", "ismain,", content)

    # 2. Refactorizar DetItinerario
    new_itinerary_block = """	IF p_Op = 'DetItinerario' THEN
	BEGIN
		DECLARE 
			v_checkIn TIMESTAMP;
			v_checkOut TIMESTAMP;
			v_fecha_salida TEXT := p_ds_fecha_salida;
			v_Y TEXT; v_M TEXT; v_D TEXT;
			v_Mr INTEGER; v_YAr INTEGER;
			v_Yr INTEGER;
		BEGIN
			-- Lógica de ajuste de año (legacy)
			IF LENGTH(v_fecha_salida) >= 8 THEN
				v_Y := SUBSTRING(v_fecha_salida, 1, 4);
				v_M := SUBSTRING(v_fecha_salida, 5, 2);
				v_D := SUBSTRING(v_fecha_salida, 7, 2);

				SELECT EXTRACT(MONTH FROM "date")::INTEGER, EXTRACT(YEAR FROM "date")::INTEGER 
				INTO v_Mr, v_YAr
				FROM public."BookingGDS" WHERE id = p_id_Booking;

				IF (v_Mr > v_M::INTEGER AND v_YAr >= v_Y::INTEGER) THEN
					v_Yr := v_Y::INTEGER + 1;
					v_Y := v_Yr::TEXT;
				END IF;

				v_fecha_salida := v_Y || LPAD(v_M, 2, '0') || LPAD(v_D, 2, '0');
			END IF;

			-- Construir Timestamps
			v_checkIn := TO_TIMESTAMP(v_fecha_salida || ' ' || COALESCE(p_ds_hora_salida, '00:00'), 'YYYYMMDD HH24:MI');
			v_checkOut := TO_TIMESTAMP(v_fecha_salida || ' ' || COALESCE(p_ds_hora_llegada, '00:00'), 'YYYYMMDD HH24:MI');

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
				COALESCE(p_bookingProductId, (SELECT MAX(id) FROM public."BookingProductGDS" WHERE "bookingId" = p_id_Booking)),
				p_orden,
				COALESCE(p_cd_aero_salida, p_origin),
				p_cd_aero_llegada,
				LEFT(p_class, 1),
				v_checkIn,
				v_checkOut,
				p_cd_aero_llegada, -- terminal (mapeo legacy)
				COALESCE(p_cd_aero_siglas, ''),
				COALESCE(p_farebasis, ''),
				p_Numflight,
				p_Typeflight,
				COALESCE(p_amount, 0)
			);
			
			RETURN p_id_Booking; -- O v_BookingProductId si tuviéramos uno
		END;
	END IF;"""

    # Reemplazar el bloque completo
    content = re.sub(r"IF\s+p_Op\s*=\s*'DetItinerario'\s+THEN.*?END\s+IF;", new_itinerary_block, content, flags=re.IGNORECASE | re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("DetItinerario refactorizado correctamente.")
except Exception as e:
    print(f"Error: {e}")
