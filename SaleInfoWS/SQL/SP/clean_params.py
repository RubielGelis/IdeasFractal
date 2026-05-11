import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Buscamos el inicio y fin del bloque de parametros a limpiar
    # Inicia despues de p_typetransaction VARCHAR(1) = '1',
    # Termina antes de WITH Encryption
    
    clean_params = """
	-- Parametros de Productos (BookingProductGDS)
	p_amount DOUBLE PRECISION = null,
	p_tax DOUBLE PRECISION = null,
	p_fee DOUBLE PRECISION = null,
	p_vat DOUBLE PRECISION = null,
	p_provider VARCHAR(25) = null,
	p_status VARCHAR(25) = null,
	
	-- Parametros de Itinerario (BookingProductItineraryGDS)
	p_orden INTEGER = null,
	p_origin VARCHAR(3) = null,
	p_destination VARCHAR(3) = null,
	p_class VARCHAR(2) = null,
	p_checkInDate TIMESTAMP = null,
	p_checkOutDate TIMESTAMP = null,
	p_terminal VARCHAR(25) = null,
	p_prestadoraCode VARCHAR(3) = null,
	p_farebasis VARCHAR(25) = null,
	p_Numflight VARCHAR(25) = null,
	p_Typeflight VARCHAR(1) = null,

	-- Parametros de Pasajeros (BookingProductPassangerGDS)
	p_firstName VARCHAR(50) = null,
	p_lastName VARCHAR(50) = null,
	p_documentType VARCHAR(25) = null,
	p_identification VARCHAR(25) = null,
	p_email VARCHAR(100) = null,
	p_phone VARCHAR(25) = null,
	p_type VARCHAR(25) = null,

	-- Parametros de Pagos (BookingProductPaymentGDS)
	p_creditCard VARCHAR(2) = null,
	p_creditCardNumber VARCHAR(16) = null,
	p_expirationDate VARCHAR(5) = null,
	p_feeNumber INTEGER = null,
	p_bank VARCHAR(25) = null,
	p_check VARCHAR(25) = null,
	p_authorization VARCHAR(25) = null,
	p_voucher VARCHAR(25) = null,
	p_reference VARCHAR(50) = null,
	
	-- Extra (necesario para la firma pero obsoleto para la logica limpia)
	p_Bookingxml TEXT = null
"""

    # Hacemos el reemplazo usando regex (re.DOTALL para que .* abarque saltos de linea)
    pattern = r"(p_typetransaction\s+VARCHAR\(\d+\)\s*=\s*'1',)(.*?)(WITH\s+Encryption)"
    
    def replacer(match):
        return match.group(1) + clean_params + match.group(3)

    new_content = re.sub(pattern, replacer, content, flags=re.IGNORECASE | re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_content)
        
    print("Parametros limpiados exitosamente.")
except Exception as e:
    print(f"Error: {e}")
