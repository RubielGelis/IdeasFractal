import re
import sys

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
        
    replacements = {
        r'@Op\b': 'p_Op',
        r'@cd_sucursal\b': 'p_blanch',
        r'@cd_implante\b': 'p_implant',
        r'@bl_externo\b': 'p_external',
        r'@iden_gds\b': 'p_gds',
        r'@cd_codigo\b': 'p_code',
        r'@ds_fecha\b': 'p_date',
        r'@codeador\b': 'p_tiquetPrinter',
        r'@cd_vendedor\b': 'p_seller',
        r'@cd_cliente\b': 'p_client',
        r'@Booking\b': 'p_booking',
        r'@cd_TipoTransaccion\b': 'p_typetransaction',
        r'@ds_moneda\b': 'p_currency',
        r'@am_TasaCambio\b': 'p_exchangeRate',
        r'@Cd_IATA\b': 'p_iata',
        r'@ds_descripcion\b': 'p_description',
        r'@ds_Observaciones\b': 'p_observation',
        
        # También arreglar los que acabo de inyectar con p_ en el UPDATE
        r'p_cd_codigo\b': 'p_code',
        r'p_iden_gds\b': 'p_gds',
        r'p_ds_fecha\b': 'p_date',
        r'p_codeador\b': 'p_tiquetPrinter',
        r'p_cd_vendedor\b': 'p_seller',
        r'p_cd_cliente\b': 'p_client',
        r'p_Booking\b': 'p_booking',
        r'p_cd_sucursal\b': 'p_blanch',
        r'p_cd_implante\b': 'p_implant',
        r'p_cd_TipoTransaccion\b': 'p_typetransaction',
        r'p_ds_Observaciones\b': 'p_observation',
        r'p_am_TasaCambio\b': 'p_exchangeRate',
        r'p_Cd_IATA\b': 'p_iata',
        r'p_ds_descripcion\b': 'p_description',
    }

    for old, new in replacements.items():
        content = re.sub(old, new, content, flags=re.IGNORECASE)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Reemplazo de parametros finalizado exitosamente.")
except Exception as e:
    print(f"Error: {e}")
