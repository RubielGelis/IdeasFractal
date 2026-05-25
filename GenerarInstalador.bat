@echo off
echo ========================================================
echo  Generador de Instalador - Ideas Fractal (Inno Setup)
echo ========================================================
echo.

REM Variables
SET "ISS_FILE=%~dp0SaleInfoWS_Installer.iss"
SET "ISCC_PATH_86=C:\Program Files (x86)\Inno Setup 7\ISCC.exe"
SET "ISCC_PATH_64=C:\Program Files\Inno Setup 7\ISCC.exe"

REM Verificar si el archivo .iss existe
if not exist "%ISS_FILE%" (
    echo [ERROR] No se encontro el archivo %ISS_FILE%
    echo.
    pause
    exit /b 1
)

REM Buscar el compilador de Inno Setup
if exist "%ISCC_PATH_86%" (
    SET "ISCC_EXE=%ISCC_PATH_86%"
) else if exist "%ISCC_PATH_64%" (
    SET "ISCC_EXE=%ISCC_PATH_64%"
) else (
    echo [ERROR] No se encontro Inno Setup Compiler ^(ISCC.exe^).
    echo Por favor, asegurate de tener instalado Inno Setup 7.
    echo.
    pause
    exit /b 1
)

echo Compilando el instalador...
echo Script: %ISS_FILE%
echo Compilador: %ISCC_EXE%
echo.

REM Ejecutar la compilacion
"%ISCC_EXE%" "%ISS_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================================
    echo  [EXITO] Instalador generado correctamente.
    echo  Revisa esta misma carpeta para encontrar el .exe
    echo ========================================================
) else (
    echo.
    echo ========================================================
    echo  [ERROR] Hubo un problema al compilar el instalador.
    echo ========================================================
)

echo.
pause
