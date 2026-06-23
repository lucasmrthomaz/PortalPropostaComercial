@echo off
title Cadastro Cliente Proposta - Startup Script
echo ==========================================================
echo  Iniciando o Sistema de Cadastro de Clientes e Propostas
echo ==========================================================

:: Adiciona caminhos padroes ao PATH caso nao estejam presentes
set "PATH=%PATH%;C:\Program Files\Go\bin;C:\Program Files\nodejs"

:: Verifica se o Go esta instalado/disponivel
where go >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Go nao foi encontrado no PATH. Por favor, instale o Go ou certifique-se de que ele esta no PATH.
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
echo [1/3] Compilando o Backend (Go)...
cd backend
go build -o server.exe ./cmd/server
if %errorlevel% neq 0 (
    echo [ERRO] Falha ao compilar o backend.
    pause
    exit /b 1
)
echo  Backend compilado com sucesso.

echo.
echo [2/3] Iniciando o Backend (binario compilado) em background...
start /b "" server.exe

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

taskkill /F /IM server.exe /T >nul 2>&1
taskkill /F /IM node.exe /T >nul 2>&1