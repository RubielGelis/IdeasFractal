-- =================================================================
-- Script de Inicialización de Licenciamiento KOR1 - IdeasFractal
-- =================================================================

-- 1. PostgreSQL (Korex_colaereo)
INSERT INTO public."SystemParameter" (code, name, value) 
VALUES ('LICENSE_KEY', 'Clave de Licencia del Sistema (IdeasFractal)', 'KOR1.eyJjIjoiSURFQVMgRlJBQ1RBTCBQUlVFQkEiLCJuIjoiNzk4OTg0NTYiLCJlIjoiMjAyNy0xMi0zMSIsImkiOiIyMDI2LTA5LTA5In0.9006bff9957eeb6e1a95bfa63934e54c02c919d771919d87525c1b0cd49c7b02') 
ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) 
VALUES ('AGENCY_NIT', 'NIT de la Agencia / Cliente', '79898456') 
ON CONFLICT (code) DO NOTHING;

INSERT INTO public."SystemParameter" (code, name, value) 
VALUES ('AGENCY_NAME', 'Nombre o Razón Social del Cliente', 'IDEAS FRACTAL PRUEBA') 
ON CONFLICT (code) DO NOTHING;
