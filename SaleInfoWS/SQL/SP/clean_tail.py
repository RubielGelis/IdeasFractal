import re

file_path = r"c:\Proyectos\IdeasFractal\SaleInfoWS\SQL\SP\spBookingGDS.sql"

try:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # 1. Agregar los nuevos parámetros si no están
    params_to_add = """
	-- Parametros Adicionales (Pagos, Variables, etc)
	p_bookingProductId INTEGER = null,
	p_paymentCode VARCHAR(50) = null,
	p_paymentName VARCHAR(50) = null,
	p_paymentType VARCHAR(50) = null,
	p_creditCardType VARCHAR(25) = null,
	p_quotas INTEGER = null,
	p_square VARCHAR(30) = null,
	p_policy VARCHAR(25) = null,
	p_policyAnnex VARCHAR(25) = null,
	p_varName TEXT = null,
	p_varValue TEXT = null,
"""
    if "p_bookingProductId" not in content:
        # insert after p_feeServiceType
        content = content.replace("p_feeServiceType TEXT = null,", "p_feeServiceType TEXT = null," + params_to_add)
        
    # 2. Reemplazar la cola desde /*inicio rgelis 2013/07/02 req.15175*/ hasta el final
    pattern_tail = r"/\*inicio rgelis 2013/07/02 req.15175\*/.*"
    
    new_tail = """
	If(p_Op='Poliza')
	BEGIN
		INSERT INTO public."BookingProductVariableGDS"("bookingProductId", code, name, "value")
		VALUES (p_bookingProductId, 'POLIZA', 'Poliza', COALESCE(p_policy, ''));
	END

	If(p_Op='PaxAdicional')
	BEGIN
		INSERT INTO public."BookingProductPassangerGDS"("bookingProductId", "firstName", "lastName", "identification", "type")
		VALUES (p_bookingProductId, p_firstName, p_lastName, p_identification, p_type);
	END

	If(p_Op='VarAdicional')
	BEGIN 
		INSERT INTO public."BookingProductVariableGDS"("bookingProductId", code, name, "value")
		VALUES (p_bookingProductId, COALESCE(p_varName, 'VAR'), p_varName, p_varValue);
	END
	
	If(p_Op='CargosImpuestos')
	BEGIN
		INSERT INTO public."BookingProductTaxGDS"("bookingProductId", code, name, type, percentage, amount)
		VALUES (p_bookingProductId, COALESCE(p_taxCode, 'TAX'), COALESCE(p_taxName, 'Impuesto'), COALESCE(p_taxType, 'IMP'), COALESCE(p_perTax, 0), p_tax);
	END

	If(p_Op='FormasPagos')
	BEGIN
		INSERT INTO public."BookingProductPaymentGDS"(
			"bookingProductId", code, name, type, "typecreditcard", "numbercreditcard", 
			"vouchercreditcard", "expiredcreditcard", "authcreditcard", "quotas", 
			"bank", "square", "reference", "policy", "policyannex", amount
		)
		VALUES (
			p_bookingProductId, COALESCE(p_paymentCode, 'PAG'), COALESCE(p_paymentName, 'Pago'), COALESCE(p_paymentType, 'EFECTIVO'), p_creditCardType, p_creditCardNumber, 
			p_voucher, p_expirationDate, p_authorization, p_quotas, 
			p_bank, p_square, p_reference, p_policy, p_policyAnnex, p_amount
		);
	END

	If(p_Op='FEE')
	BEGIN
		INSERT INTO public."BookingProductFEEGDS"(
			"bookingProductId", code, name, type, "description", "billigconcept", "servicetype", amount, tax, other, total
		)
		VALUES (
			p_bookingProductId, COALESCE(p_feeCode, 'FEE'), COALESCE(p_feeName, 'Fee'), COALESCE(p_feeType, 'FEE'), COALESCE(p_feeDescription, ''), 
			COALESCE(p_feeBillingConcept, '1'), COALESCE(p_feeServiceType, '1'), p_amount, 0, 0, p_amount
		);
	END
END;
$$ LANGUAGE plpgsql;
"""

    content = re.sub(pattern_tail, new_tail.strip(), content, flags=re.IGNORECASE | re.DOTALL)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)
        
    print("Cola del SP limpiada y ajustada a las nuevas tablas.")
except Exception as e:
    print(f"Error: {e}")
