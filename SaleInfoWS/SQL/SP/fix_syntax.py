import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Reemplazar ISNULL por COALESCE
    content = re.sub(r'\bISNULL\s*\(', 'COALESCE(', content, flags=re.IGNORECASE)
    
    # Reemplazar el inicio de la función a formato PostgreSQL (si aún no se ha hecho)
    content = re.sub(r'CREATE Procedure \[dbo\]\.\[spBookingGDS\]', 'CREATE OR REPLACE FUNCTION public."spBookingGDS"(', content, flags=re.IGNORECASE)
    
    # Reemplazar el "WITH Encryption As Set Nocount On" por el cierre de los parametros y el inicio del DECLARE
    content = re.sub(r'WITH\s+Encryption\s+As\s+Set\s+Nocount\s+On', ') RETURNS void AS $$\nDECLARE', content, flags=re.IGNORECASE)
    
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Sintaxis PostgreSQL aplicada exitosamente.")
except Exception as e:
    print(f"Error: {e}")
