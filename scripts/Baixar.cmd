@echo off
title Iso LOuca - Download
cd /d "%~dp0"

if "%~1"=="" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Baixar.ps1"
    goto fim
)

if /i "%~1"=="listar" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Baixar.ps1" -Listar
    goto fim
)

if /i "%~1"=="tudo" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Baixar.ps1" -Tudo
    goto fim
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Baixar.ps1" -Nome %*

:fim
pause
