import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Cambiar todas las variables restantes que empiecen con @ a p_
    content = re.sub(r'@([a-zA-Z0-9_]+)', r'p_\1', content)

    # Reemplazar tipos de datos de SQL Server a PostgreSQL
    content = re.sub(r'\bINT\b', 'INTEGER', content, flags=re.IGNORECASE)
    content = re.sub(r'\bCHAR\s*\(', 'VARCHAR(', content, flags=re.IGNORECASE)
    content = re.sub(r'\bVARCHAR\s*\(\s*MAX\s*\)', 'TEXT', content, flags=re.IGNORECASE)
    content = re.sub(r'\bBIT\b', 'BOOLEAN', content, flags=re.IGNORECASE)
    content = re.sub(r'\bMONEY\b', 'DOUBLE PRECISION', content, flags=re.IGNORECASE)
    content = re.sub(r'\bDATETIME\b', 'TIMESTAMP', content, flags=re.IGNORECASE)
    content = re.sub(r'\bTINYINT\b', 'SMALLINT', content, flags=re.IGNORECASE)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Tipos de datos y arrobas convertidos exitosamente.")
except Exception as e:
    print(f"Error: {e}")
