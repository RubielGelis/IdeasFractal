import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Add parameters to the top
    param_insert = """	-- Parametros de Tipificacion Adicional
	p_productType VARCHAR(25) = null,
	p_productService TEXT = null,
	p_productDescription TEXT = null,
	p_taxCode VARCHAR(25) = null,
	p_taxName VARCHAR(50) = null,
	p_taxType VARCHAR(25) = null,
	p_feeCode VARCHAR(25) = null,
	p_feeName VARCHAR(50) = null,
	p_feeType VARCHAR(25) = null,
	p_feeDescription TEXT = null,
	p_feeBillingConcept TEXT = null,
	p_feeServiceType TEXT = null,
"""
    # Insert after p_status
    content = content.replace("p_status VARCHAR(25) = null,", "p_status VARCHAR(25) = null,\n" + param_insert)

    # 2. Replace hardcoded strings in DetPas
    content = content.replace("'Tiquete',", "COALESCE(p_productType, 'Tiquete'),", 1)
    content = content.replace("'Tiquete Aereo',", "COALESCE(p_productService, 'Tiquete Aereo'),", 1)
    content = content.replace("'Emision de Tiquete',", "COALESCE(p_productDescription, 'Emision de Tiquete'),", 1)

    content = content.replace("'IVA',", "COALESCE(p_taxCode, 'IVA'),", 1)
    content = content.replace("'IVA Tiquete',", "COALESCE(p_taxName, 'IVA Tiquete'),", 1)
    content = content.replace("'IMP',", "COALESCE(p_taxType, 'IMP'),", 1)

    content = content.replace("'FEE',", "COALESCE(p_feeCode, 'FEE'),", 1)
    content = content.replace("'Fee de Emision',", "COALESCE(p_feeName, 'Fee de Emision'),", 1)
    content = content.replace("'TAO',", "COALESCE(p_feeType, 'TAO'),", 1)
    content = content.replace("'Cargo Administrativo',", "COALESCE(p_feeDescription, 'Cargo Administrativo'),", 1)
    # The billing and service concepts were '1', '1'
    content = content.replace("'1',\n\t\t\t\t\t'1',", "COALESCE(p_feeBillingConcept, '1'),\n\t\t\t\t\tCOALESCE(p_feeServiceType, '1'),", 1)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Parametrizacion completada exitosamente.")
except Exception as e:
    print(f"Error: {e}")
