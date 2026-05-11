import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Asegurar THEN en el IF de RESPETARVALOR
    content = re.sub(r"(IF\s+EXISTS\s*\(.*?\)\s*OR\s*EXISTS\s*\(.*?\))\s*(?!THEN)", r"\1 THEN\n\t", content, flags=re.IGNORECASE | re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("THEN corregido.")
except Exception as e:
    print(f"Error: {e}")
