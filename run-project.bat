@echo off
title Portal Proposta Comercial


cd /d "%~dp0"

echo ==========================================================
echo  Iniciando o Sistema de Cadastro de Clientes e Propostas
echo ==========================================================

:: Adiciona caminhos padroes ao PATH caso nao estejam presentes
set "PATH=%PATH%;C:\Program Files\dotnet;C:\Program Files\nodejs"

:: Verifica se o .NET SDK esta instalado/disponivel
where dotnet >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] .NET SDK nao foi encontrado. Instale o .NET SDK 10.
    pause
    exit /b 1
)

:: Verifica se o Node/NPM esta instalado/disponivel
where npm >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] NPM nao foi encontrado. Instale o Node.js.
    pause
    exit /b 1
)

echo.
echo [1/3] Compilando o Backend (.NET 10)...
cd backend
dotnet build -c Release
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao compilar o backend.
    pause
    exit /b 1
)
echo  Backend compilado com sucesso.

echo.
echo [2/3] Iniciando o Backend (.NET 10) em background...
start /b "" bin\Release\net10.0\PortalProposta.exe

cd ..

echo.
echo [3/3] Iniciando o Frontend (Vue dev server)...
cd frontend
start /b "" npx vite --port 5173
cd ..

echo.
echo ==========================================================
echo  Tudo pronto!
echo  - Backend:  http://localhost:8080
echo  - Frontend: http://localhost:5173
echo.
echo  Pressione qualquer tecla para encerrar.
echo ==========================================================
pause >nul

taskkill /F /IM PortalProposta.exe /T >nul 2>&1
taskkill /F /IM node.exe /T >nul 2>&1