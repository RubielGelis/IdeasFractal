import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Eliminar comentarios que empiecen con /*rgelis
    content = re.sub(r"/\*rgelis.*?\*/", "", content, flags=re.IGNORECASE | re.DOTALL)
    
    # 2. También eliminar comentarios que digan --rgelis
    content = re.sub(r"--rgelis.*", "", content, flags=re.IGNORECASE)

    # 3. Eliminar comentarios de JARG o JRamirez que suelen acompañar a los de rgelis
    content = re.sub(r"/\*JARG.*?\*/", "", content, flags=re.IGNORECASE | re.DOTALL)
    content = re.sub(r"/\*JRamirez.*?\*/", "", content, flags=re.IGNORECASE | re.DOTALL)
    content = re.sub(r"--JARG.*", "", content, flags=re.IGNORECASE)
    content = re.sub(r"--JRamirez.*", "", content, flags=re.IGNORECASE)

    # 4. Asegurar que no queden líneas vacías excesivas tras borrar comentarios
    content = re.sub(r"\n\s*\n\s*\n+", "\n\n", content)

    # 5. Corrección de asignaciones en IFs que pudieron quedar mal
    # IF (v_Mr > v_M::INTEGER AND v_YAr >= v_Y::INTEGER) THEN
    # (Ya debería estar bien, pero revisamos)
    
    # 6. Eliminar el "[" y "]" que suelen quedar de SQL Server
    content = content.replace("[", "").replace("]", "")

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Pulido final completado: comentarios legacy eliminados y corchetes removidos.")
except Exception as e:
    print(f"Error: {e}")
