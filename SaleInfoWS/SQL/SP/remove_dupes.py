import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Eliminar duplicados de ismain en la lista de campos
    content = content.replace("ismain, ismain,", "ismain,")
    
    # También por si acaso hay espacios diferentes
    content = re.sub(r"ismain,\s*ismain,", "ismain,", content)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Duplicados eliminados.")
except Exception as e:
    print(f"Error: {e}")
