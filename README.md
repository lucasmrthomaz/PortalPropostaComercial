<img width="1639" height="867" alt="image" src="https://github.com/user-attachments/assets/72857167-6538-408d-8494-2eccdd2338a4" />

# Portal de Propostas Comerciais

Sistema completo de gestão de propostas comerciais com cadastro de clientes, propostas por tipo (Imobiliária, Automotiva, Diversas) e dashboard de métricas.

O projeto está dividido entre um backend construído em **.NET 10**, uma aplicação web frontend construída em **Vue 3** com TypeScript, e um aplicativo móvel/desktop em **Flutter**.

---

## 🚀 Funcionalidades

- **Cadastro de Clientes** com validação de e-mail e CPF/CNPJ.
- **Formulários Dinâmicos** para diferentes tipos de propostas de acordo com as configurações do sistema.
- **Dashboard** completo com métricas, gráficos e resumos de propostas.
- **Busca e Filtros** avançados para controle e gerenciamento.
- **Design Responsivo** com estilo premium totalmente customizado em CSS nativo (Design System estruturado com variáveis CSS).

---

## 🛠️ Tecnologias

### Backend
- **.NET 10.0** (ASP.NET Core Web API)
- **Entity Framework Core 10** com provedor **SQLite**
- Validação e filtros globais para tratamento de exceções

### Frontend Web
- **Vue 3** (Single File Components - SFC)
- **TypeScript**
- **Vite** - Build tool e Servidor de Desenvolvimento
- **Vue Router** - Gerenciamento de rotas
- **CSS Customizado** (sem uso de frameworks CSS pesados, apenas variáveis CSS e design system limpo)

### Aplicativo Mobile / Desktop (Opcional)
- **Flutter** com Dart (Localizado na pasta `/app`)
- Gerenciamento de estado com **Provider**
- Integração reativa via API REST

---

## ⚙️ Instalação e Execução

### Pré-requisitos
- .NET 10 SDK
- Node.js 20+
- Flutter SDK (opcional, apenas para rodar o aplicativo mobile)

---

### Execução Combinada (Windows)

Na raiz do projeto, existe o script `run-project.bat`. Ele automatiza a compilação do backend e a inicialização de ambos os serviços:

```cmd
run-project.bat
```

Após executar, os serviços estarão disponíveis em:
- **Backend (API):** `http://localhost:8080`
- **Frontend (Web):** `http://localhost:5173`

---

### Execução Manual

#### 🖥️ Backend (.NET 10)
1. Navegue até a pasta do backend:
   ```bash
   cd backend
   ```
2. Restaure as dependências e inicie o servidor:
   ```bash
   dotnet run
   ```
   *O backend escutará por padrão na porta **8080** (`http://localhost:8080`).*

#### 🌐 Frontend (Vue 3 + Vite)
1. Navegue até a pasta do frontend:
   ```bash
   cd frontend
   ```
2. Instale as dependências:
   ```bash
   npm install
   ```
3. Inicie o servidor de desenvolvimento:
   ```bash
   npm run dev
   ```
   *A aplicação iniciará na porta **5173** (`http://localhost:5173`) e possui proxy configurado para redirecionar chamadas `/api` automaticamente para o backend.*

#### 📱 Aplicativo Flutter
1. Navegue até a pasta do aplicativo:
   ```bash
   cd app
   ```
2. Obtenha as dependências do pubspec:
   ```bash
   flutter pub get
   ```
3. Execute o aplicativo no emulador ou dispositivo conectado:
   ```bash
   flutter run
   ```

---

## 📂 Estrutura do Projeto

```
/backend                      - API Web RESTful desenvolvida em .NET 10
  /Controllers                - Endpoints expostos para a aplicação
  /Data                       - Inicialização do banco SQLite via Entity Framework Core (AppDbContext)
  /Models                     - Modelos de domínio (Clientes, Propostas, etc.)
  /Services                   - Serviços com as regras de negócio
  /Infrastructure             - Filtros e manipuladores globais de requisições / erros
  Program.cs                  - Inicialização global e injeção de dependências do ASP.NET Core
  backend.csproj              - Arquivo de configuração de projeto .NET

/frontend                     - Interface Web do Portal em Vue 3 + TypeScript
  /src/components             - Componentes modulares reutilizáveis (formulários, tabelas, modais)
  /src/views                  - Páginas principais da aplicação web (Dashboard, Clientes, Configurações)
  /src/services               - Camada de comunicação com a API REST
  /src/styles                 - Variáveis e estilos globais do design system
  vite.config.ts              - Configuração do Vite com suporte a proxy reverso para `/api`

/app                          - Interface Mobile / Desktop em Flutter (Dart)
  /lib/screens                - Telas do aplicativo organizadas por domínio
  /lib/providers              - Gerenciamento de estado reativo
  /lib/core                   - Configurações da aplicação e cliente HTTP (ApiClient)
```

---

## 📝 Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

