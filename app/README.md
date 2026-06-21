# Portal Proposta Comercial - Aplicativo Flutter

Este é o aplicativo mobile e desktop do **Portal Propostas**, construído em **Flutter**, integrado à API RESTful em Go (`backend`).

---

## 🏗️ Arquitetura do Projeto

O projeto segue boas práticas de arquitetura, modularidade e gerenciamento de estado:

- `/lib/core`: Contém constantes visuais, temas (suporte automático a Dark/Light Mode), tokens visuais premium e o cliente HTTP (`ApiClient`) com resolução de loopback automática para testes no Emulador Android (`10.0.2.2`).
- `/lib/models`: Estruturas de dados fortemente tipadas que refletem os modelos GORM do backend, incluindo rotinas de validação de CPF/CNPJ.
- `/lib/providers`: Gerenciadores de estado reativos baseados no pacote `provider` (`ChangeNotifier`).
- `/lib/widgets`: Componentes reutilizáveis (como badges de status de corretagem e campos de formulário dinâmicos).
- `/lib/screens`: Telas da aplicação organizadas por domínio (Dashboard, Clientes, Propostas, Empresas, Supervisor e Configurações).

---

## ⚡ Como Executar Localmente

### Pré-requisitos
- **Flutter SDK** instalado e configurado na máquina (versão estável compatível com Dart >=3.0.0).

---

### Passo a Passo

1. **Baixar as dependências do projeto**
   Na pasta `app`, execute:
   ```bash
   flutter pub get
   ```

2. **Iniciar o Backend em Go**
   Certifique-se de que a API Go está rodando localmente na porta `8080` (conforme instruções no README raiz).

3. **Executar a Aplicação**
   Selecione o dispositivo alvo (Emulador, Navegador Chrome, ou Desktop local) e execute:
   ```bash
   flutter run
   ```

---

## 🌟 Recursos Principais

1. **Formulários 100% Dinâmicos:** Adapta-se automaticamente a propostas do tipo `Imobiliaria`, `Auto`, `CompraVenda` ou qualquer outro tipo criado em tempo de execução no construtor dinâmico de campos.
2. **Dashboard Visual com fl_chart:** Gráficos interativos exibindo a distribuição e o valor total de propostas por status e tipo.
3. **Fluxo do Supervisor Integrado:** Autorização imediata via validação de senha do supervisor ou agendamento de liberação em lote na fila de solicitações.
4. **Layout Responsivo Premium:** Suporte completo para telas mobile (barra de navegação inferior elegante) e telas grandes de desktop (barra de navegação lateral estendida).
