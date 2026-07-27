@echo off
title Cadastro Cliente Proposta - Startup Script

:: Garante que o diretorio de trabalho seja o mesmo de onde o script esta localizado
cd /d "%~dp0"

echo ==========================================================
echo  Iniciando o Sistema de Cadastro de Clientes e Propostas
echo ==========================================================

:: Adiciona caminhos padroes ao PATH caso nao estejam presentes
set "PATH=%PATH%;C:\Program Files\dotnet;C:\Program Files\nodejs"

:: Verifica se o .NET SDK esta instalado/disponivel
where dotnet >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] .NET SDK nao foi encontrado no PATH. Por favor, instale o .NET SDK 10 ou certifique-se de que ele esta no PATH.
    pause
    exit /b 1
)

:: Verifica se o Node/NPM esta instalado/disponivel
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] NPM nao foi encontrado no PATH. Por favor, instale o Node.js ou certifique-se de que ele esta no PATH.
    pause
    exit /b 1
)

echo.
echo [1/3] Compilando o Backend (.NET 10)...
cd backend-net10
dotnet build -c Release
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao compilar o backend NET 10.
    pause
    exit /b 1
)
echo  Backend compilado com sucesso.

echo.
echo [2/3] Iniciando o Backend (.NET 10) em background...
start /b "" bin\Release\net10.0\backend-net10.exe

cd ..

echo.
echo [3/3] Iniciando o Frontend (Angular dev server - porta 5173)...
cd frontend
start /b "" yarn run dev
cd ..

echo.
echo ==========================================================
echo  Tudo pronto!
echo  - Backend:  http://localhost:8080
echo  - Frontend: http://localhost:5173
echo.
echo  Aguarde o Angular carregar por completo antes de acessar.
echo  Pressione qualquer tecla para encerrar os processos e sair.
echo ==========================================================
pause >nul

taskkill /F /IM backend-net10.exe /T >nul 2>&1
taskkill /F /IM node.exe /T >nul 2>&1