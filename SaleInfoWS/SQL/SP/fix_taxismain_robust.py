import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Corregir campo de parámetros (asegurar coma)
    content = re.sub(r"p_taxismain\s+BOOLEAN\s*=\s*false[;,]", "p_taxismain  BOOLEAN = false,", content, flags=re.IGNORECASE)

    # 2. Corregir el listado de campos (robusto contra espacios y saltos de línea)
    # Buscamos el paréntesis que sigue a public."BookingProductTaxGDS"
    content = re.sub(
        r"(public\.\"BookingProductTaxGDS\"\s*\()([^\)]*?)(percentage,\s*amount\s*\))",
        lambda m: m.group(1) + m.group(2) + "ismain, percentage, amount)",
        content, flags=re.IGNORECASE | re.DOTALL
    )

    # 3. Corregir el listado de valores
    # Buscamos COALESCE(p_taxType, '...') seguido de COALESCE(p_perTax, 0)
    # Queremos insertar p_taxismain en el medio
    content = re.sub(
        r"(COALESCE\(p_taxType,\s*'[^']+'\),)\s*(COALESCE\(p_perTax,\s*0\))",
        r"\1 p_taxismain, \2",
        content, flags=re.IGNORECASE
    )

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Corrección robusta completada.")
except Exception as e:
    print(f"Error: {e}")
