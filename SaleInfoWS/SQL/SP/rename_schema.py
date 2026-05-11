import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Mapeos especificos de las nuevas tablas de TABLEINI.sql
    table_mappings = {
        r'dbo\.BookingsGDS\b': 'public."BookingGDS"',
        r'dbo\.BookingGDS_Product\b': 'public."BookingProductGDS"',
        r'dbo\.BookingGDS_Itinerarios\b': 'public."BookingProductItineraryGDS"',
        r'dbo\.BookingGDS_Pax\b': 'public."BookingProductPassangerGDS"',
        r'dbo\.BookingGDS_Pagos\b': 'public."BookingProductPaymentGDS"',
        r'dbo\.BookingGDS_Variables\b': 'public."BookingProductVariableGDS"',
        r'dbo\.BookingGDS_Impuestos\b': 'public."BookingProductTaxGDS"',
        r'dbo\.BookingGDS_FEE\b': 'public."BookingProductFEEGDS"',
        
        # Opcionales (dependiendo de si usas BookingProductGDS para estos o si se eliminan)
        r'dbo\.BookingGDS_CAR\b': 'public."BookingProductGDS"',
        r'dbo\.BookingGDS_HTL\b': 'public."BookingProductGDS"',
        r'dbo\.BookingGDS_Tiquetes\b': 'public."BookingProductGDS"',
    }
    
    for old, new in table_mappings.items():
        content = re.sub(old, new, content, flags=re.IGNORECASE)

    # Reemplazo generico para todo lo demas que tenga dbo.Tabla o dbo..Tabla
    # ej: dbo.Sucursales -> public."Sucursales"
    content = re.sub(r'dbo\.\.?([a-zA-Z0-9_]+)', r'public."\1"', content, flags=re.IGNORECASE)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Esquemas dbo. reemplazados a public. exitosamente.")
except Exception as e:
    print(f"Error: {e}")
