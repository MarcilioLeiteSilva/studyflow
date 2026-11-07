# StudyFlow — Plataforma Completa de Gestão de Estudos

> **Aplicativo Mobile Flutter + Backend API + Painel Administrativo Web (Deploy EasyPanel / VPS)**

---

## 📁 Estrutura do Repositório (Monorepo)

```
.
├── backend/               # API Node.js Express + PostgreSQL + Proxy de IA (Porta 3000)
│   ├── Dockerfile         # Imagem Docker leve baseada em Node 20 Alpine
│   ├── server.js          # Catálogo de planos, rotas de IA, rate limiter e admin API
│   ├── data/              # Planos pré-prontos de estudo em JSON (seed automático)
│   └── public/            # Fallback embutido do painel admin em /admin
│
├── admin/                 # Painel Web Administrativo (Porta 3001)
│   ├── Dockerfile         # Container isolado para o painel operacional
│   ├── server.js          # Servidor estático com injeção de configurações
│   └── public/            # Interface moderna com Tailwind CSS e Phosphor Icons
│
├── studyflow/             # Aplicativo Mobile em Flutter (Android / iOS)
│   ├── lib/               # Código Dart modular (l10n pt/en/es, Hive offline, IA)
│   └── android/           # Configurações Gradle 8.13 e SDK 36.1
│
├── docker-compose.yml     # Orquestração completa para testes locais ou EasyPanel
└── README.md
```

---

## 🚀 Como Fazer o Deploy no EasyPanel (VPS / Hostinger)

No painel do seu **EasyPanel**, crie um novo projeto chamado `studyflow` e adicione os seguintes serviços:

### 1. Serviço de Banco de Dados (PostgreSQL)
* Clique em **+ Service** -> **Database** -> **PostgreSQL**.
* Nome do serviço: `studyflow-db`
* O EasyPanel criará as credenciais. Guarde a senha para a `DATABASE_URL`.
* **Database Name:** `studyflow`
* **Username:** `studyflow`

### 2. Serviço de Cache (Redis - Opcional / Recomendado)
* Clique em **+ Service** -> **Database** -> **Redis**.
* Nome do serviço: `studyflow-redis`

### 3. Serviço da API Backend (`studyflow-backend`)
* Clique em **+ Service** -> **App**.
* **Nome do serviço:** `studyflow-backend`
* **Source:** GitHub (`https://github.com/MarcilioLeiteSilva/studyflow`)
* **Branch:** `main`
* **Build Type:** Dockerfile
* **Root Directory:** `/backend`
* **Porta Interna:** `3000`
* **Domínio:** `api.seudominio.com` (com SSL Let's Encrypt automático)
* **Variáveis de Ambiente (`Environment`):**
  ```env
  NODE_ENV=production
  PORT=3000
  DATABASE_URL=postgres://studyflow:SUA_SENHA@studyflow-db:5432/studyflow
  REDIS_URL=redis://studyflow-redis:6379
  ADMIN_API_SECRET=SUA_CHAVE_SECRETA_AQUI
  GEMINI_API_KEY=sua_chave_do_google_ai_studio_opcional
  OPENROUTER_API_KEY=sua_chave_do_openrouter_opcional
  CORS_ORIGIN=*
  ```

### 4. Serviço do Painel Administrativo (`studyflow-admin`)
* Clique em **+ Service** -> **App**.
* **Nome do serviço:** `studyflow-admin`
* **Source:** GitHub (`https://github.com/MarcilioLeiteSilva/studyflow`)
* **Branch:** `main`
* **Build Type:** Dockerfile
* **Root Directory:** `/admin`
* **Porta Interna:** `3001`
* **Domínio:** `admin.seudominio.com`
* **Variáveis de Ambiente (`Environment`):**
  ```env
  NODE_ENV=production
  PORT=3001
  API_URL=https://api.seudominio.com
  ```

---

## 🛡️ Endpoints da API

| Método | Rota | Descrição | Autenticação |
| :--- | :--- | :--- | :--- |
| `GET` | `/health` | Status da API e contagem de planos | Pública |
| `GET` | `/api/plans` | Lista resumida de planos para download | Pública |
| `GET` | `/api/plans/:id` | Download completo de um plano com tarefas | Pública |
| `POST` | `/api/plans/generate` | Gerador de rotinas com IA protegida | Pública (Rate Limit) |
| `GET` | `/api/admin/stats` | Métricas de planos, tarefas e banco | `x-admin-key` |
| `GET` | `/api/admin/plans` | Listagem completa para o painel admin | `x-admin-key` |
| `POST` | `/api/admin/plans` | Criar ou atualizar um plano de estudos | `x-admin-key` |
| `DELETE`| `/api/admin/plans/:id` | Excluir plano de estudos do catálogo | `x-admin-key` |

---

## 📱 Conectar o App Flutter ao Backend

No aplicativo Flutter, aponte a URL do backend nas configurações ou arquivo de constantes:
```dart
const String backendBaseUrl = 'https://api.seudominio.com';
```
Por padrão local, o app usa `http://10.0.2.2:3000` (emulador) ou `http://127.0.0.1:3000` (via ADB reverse).

