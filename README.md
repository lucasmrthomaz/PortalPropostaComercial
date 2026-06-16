# Cadastro de Clientes e Propostas Comerciais

Esta é uma aplicação completa e moderna com a separação correta entre **Backend em Go** e **Frontend em Angular 18+ com Angular Material**, utilizando **SQLite** como banco de dados fallback local.

---

## 🏗️ Estrutura do Projeto

O projeto é dividido em dois diretórios principais:

- `/backend`: API RESTful construída em Go seguindo o padrão Clean Architecture, utilizando `go-chi` para rotas, `GORM` como ORM, e o driver SQLite puramente em Go (sem CGO) para máxima portabilidade em ambientes Windows.
- `/frontend`: Aplicação SPA construída em Angular 18+, utilizando Angular Material para interface visual responsiva e moderna, formulários dinâmicos com validação para diferentes tipos de propostas comerciais (Imobiliária, Auto e Compra/Venda Diversas) e Dashboard de métricas.

---

## ⚡ Como Executar Localmente

### Pré-requisitos
- **Go** (versão 1.22+) instalado
- **Node.js** (versão 20+) instalado

---

### 1. Executar o Backend (Go)

O backend irá inicializar automaticamente o arquivo de banco de dados SQLite local `propostas.db` e rodar as migrações necessárias ao iniciar.

No terminal, navegue até a pasta `backend` e execute:

```bash
cd backend
go run cmd/server/main.go
```

O servidor iniciará por padrão na porta `8080` em:  
👉 **http://localhost:8080**

---

### 2. Executar o Frontend (Angular)

O Angular está configurado com um servidor proxy local para rotear requisições `/api` diretamente para a porta `8080` do backend.

Em um novo terminal, na pasta raiz do projeto, execute:

```bash
cd frontend
npm install
npm run start
```

O servidor de desenvolvimento do Angular iniciará em:  
👉 **http://localhost:4200**

---

## 🌟 Funcionalidades e Diferenciais

1. **Dashboard Consolidado:** Métricas em tempo real sobre o número total de clientes, propostas, valor acumulado geral, e detalhamentos estruturados por tipo de proposta e status.
2. **Cadastro Completo de Clientes:** Validação integrada de e-mail e CPF/CNPJ diretamente no backend e no frontend.
3. **Formulários Dinâmicos de Propostas:** Ao selecionar o tipo de proposta, o formulário se adapta exibindo os campos adequados:
   - **Imobiliária:** Endereço do imóvel, tipo (casa, apartamento, etc.) e área em m².
   - **Automotiva:** Marca, modelo, ano de fabricação e placa do veículo.
   - **Compra e Venda Diversas:** Descrição livre de itens e condições de pagamento.
4. **SQLite Zero-Config:** Conexão fallback automática para rodar localmente sem precisar de setups complexos de banco de dados.
