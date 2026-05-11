import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Corregir el punto y coma por coma en el parámetro
    content = content.replace("p_taxismain  BOOLEAN = false;", "p_taxismain  BOOLEAN = false,")
    
    # 2. Actualizar INSERTS de BookingProductTaxGDS
    # Caso 1: Los bloques de DetCar, DetHotel, DetSrv (multilínea)
    pattern_tax = r"(INSERT INTO\s+public\.\"BookingProductTaxGDS\"\s*\(\s*\"bookingProductId\",\s*code,\s*name,\s*type,\s*percentage,\s*amount\s*\)\s*VALUES\s*\(\s*v_BookingProductId,\s*COALESCE\(p_taxCode,\s*'[^']+'\),\s*COALESCE\(p_taxName,\s*'[^']+'\),\s*COALESCE\(p_taxType,\s*'IMP'\),\s*COALESCE\(p_perTax,\s*0\),\s*p_tax\s*\);)"
    
    def replacer_tax(match):
        orig = match.group(1)
        new = orig.replace("\"bookingProductId\", code, name, type, percentage, amount", "\"bookingProductId\", code, name, type, ismain, percentage, amount")
        new = new.replace("COALESCE(p_perTax, 0), p_tax", "COALESCE(p_perTax, 0), p_taxismain, p_tax") # Wait, order was percentage, amount. Table has percentage then amount.
        # Wait, TABLEINI.sql: ismain boolean DEFAULT false, percentage double precision, amount double precision
        # So it's: ismain, percentage, amount
        return new

    # Re-check the table structure in my head:
    # TABLEINI: "bookingProductId", code, name, type, "ismain", "percentage", "amount"
    
    new_tax_fields = "\"bookingProductId\", code, name, type, ismain, percentage, amount"
    
    # DetPas uses p_id_Booking or v_BookingProductId?
    # Let's just do a generic replacement for the field list and the values list
    content = content.replace(
        "\"bookingProductId\", code, name, type, percentage, amount",
        "\"bookingProductId\", code, name, type, ismain, percentage, amount"
    )
    
    # Now fix the values list.
    # We look for the values part of the INSERT into BookingProductTaxGDS
    content = re.sub(
        r"(VALUES\s*\(\s*v_BookingProductId,\s*COALESCE\(p_taxCode,\s*'[^']+'\),\s*COALESCE\(p_taxName,\s*'[^']+'\),\s*COALESCE\(p_taxType,\s*'IMP'\),)(\s*COALESCE\(p_perTax,\s*0\),\s*p_tax\s*\))",
        r"\1 p_taxismain,\2",
        content, flags=re.IGNORECASE
    )
    
    # For DetPas (using v_BookingProductId too)
    # Actually the script above should cover it if it uses the same pattern.
    
    # For the last FEE/Cargos block (line 1057 in previous run_command):
    # INSERT INTO public."BookingProductTaxGDS"("bookingProductId", code, name, type, percentage, amount)
    # VALUES (p_bookingProductId, COALESCE(p_taxCode, 'TAX'), COALESCE(p_taxName, 'Impuesto'), COALESCE(p_taxType, 'IMP'), COALESCE(p_perTax, 0), p_tax);
    content = re.sub(
        r"(VALUES\s*\(\s*p_bookingProductId,\s*COALESCE\(p_taxCode,\s*'TAX'\),\s*COALESCE\(p_taxName,\s*'Impuesto'\),\s*COALESCE\(p_taxType,\s*'IMP'\),)(\s*COALESCE\(p_perTax,\s*0\),\s*p_tax\s*\))",
        r"\1 p_taxismain,\2",
        content, flags=re.IGNORECASE
    )

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Parámetro p_taxismain integrado en todos los INSERTS de impuestos.")
except Exception as e:
    print(f"Error: {e}")
