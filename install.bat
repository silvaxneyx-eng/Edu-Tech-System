@echo off
title EduTech Tecnico - Instalador Windows
color 0B
echo =======================================================
echo    EDUTECH TECNICO V4.0 - INSTALADOR (WINDOWS)
echo =======================================================
echo.

:: Verifica se o Python esta instalado
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Python nao encontrado!
    echo Por favor, instale o Python 3 na Microsoft Store ou via python.org
    echo Nao esqueca de marcar a caixa "Add Python to PATH" durante a instalacao!
    pause
    exit /b 1
)

echo [1/2] Instalando bibliotecas graficas (CustomTkinter)...
pip install customtkinter
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao instalar dependencias do Python.
    pause
    exit /b 1
)

echo.
echo [2/2] Criando atalho na Area de Trabalho...
set "SCRIPT_PATH=%~dp0scripts\edutech-tecnico.py"
set "SHORTCUT_PATH=%USERPROFILE%\Desktop\EduTech Tecnico.url"
echo [InternetShortcut] > "%SHORTCUT_PATH%"
echo URL="file:///%SCRIPT_PATH%" >> "%SHORTCUT_PATH%"
echo IconIndex=0 >> "%SHORTCUT_PATH%"
echo IconFile=%windir%\system32\shell32.dll >> "%SHORTCUT_PATH%"

echo =======================================================
echo    SUCESSO! O painel esta pronto para uso.
echo =======================================================
echo Um atalho foi criado na sua Area de Trabalho.
echo Iniciando o painel agora...
python "%SCRIPT_PATH%"
pause
