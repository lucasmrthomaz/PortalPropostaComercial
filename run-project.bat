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
echo [1/2] Iniciando o Servidor Backend (Go) em uma nova janela...
start "Backend (Go) - Porta 8080" cmd /k "cd backend && go run ./cmd/server"

echo.
echo [2/2] Iniciando o Servidor Frontend (Angular) em uma nova janela...
start "Frontend (Angular) - Porta 4200" cmd /k "cd frontend && npm start"

echo.
echo ==========================================================
echo  Tudo pronto!
echo  - Backend rodando em http://localhost:8080
echo  - Frontend rodando em http://localhost:4200
echo.
echo  Aguarde os servidores carregarem por completo.
echo  Pressione qualquer tecla nesta janela para fechar este script
echo  (as janelas do backend e frontend continuarao rodando).
echo ==========================================================
pause >nul