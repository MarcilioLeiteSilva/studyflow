require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const rateLimit = require('express-rate-limit');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;
const ADMIN_SECRET = process.env.ADMIN_API_SECRET || 'studyflow_admin_secret_token_change_me';

// Middlewares
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-admin-key']
}));
app.use(express.json());

// Serve static admin if present
const adminDistPath = path.join(__dirname, 'public');
if (fs.existsSync(adminDistPath)) {
  app.use('/admin', express.static(adminDistPath));
}

// -------------------------------------------------------------
// Database Configuration (PostgreSQL with JSON Fallback)
// -------------------------------------------------------------
let pool = null;
let usePostgres = false;
const plansFilePath = path.join(__dirname, 'data', 'premade_plans.json');
let localPlans = [];

// Load local JSON fallback
try {
  if (fs.existsSync(plansFilePath)) {
    const raw = fs.readFileSync(plansFilePath, 'utf8');
    localPlans = JSON.parse(raw);
    console.log(`[Database] Carregados ${localPlans.length} planos do arquivo JSON local.`);
  }
} catch (e) {
  console.warn('[Database] Erro ao ler JSON local:', e.message);
}

if (process.env.DATABASE_URL) {
  try {
    pool = new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.NODE_ENV === 'production' && !process.env.DATABASE_URL.includes('localhost') && !process.env.DATABASE_URL.includes('studyflow-db') ? { rejectUnauthorized: false } : false
    });

    pool.on('error', (err) => {
      console.error('[PostgreSQL Pool Error]', err.message);
    });

    pool.query(`
      CREATE TABLE IF NOT EXISTS study_plans (
        id VARCHAR(100) PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        category VARCHAR(100) NOT NULL,
        description TEXT,
        duration_days INT DEFAULT 7,
        language VARCHAR(10) DEFAULT 'pt',
        tasks JSONB NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `).then(async () => {
      usePostgres = true;
      console.log('[PostgreSQL] Conectado e tabela "study_plans" pronta.');

      // Check if we need to seed
      const countRes = await pool.query('SELECT COUNT(*) FROM study_plans');
      if (parseInt(countRes.rows[0].count, 10) === 0 && localPlans.length > 0) {
        console.log('[PostgreSQL] Tabela vazia. Executando seed inicial com planos pré-prontos...');
        for (const plan of localPlans) {
          await pool.query(
            `INSERT INTO study_plans (id, title, category, description, duration_days, language, tasks, is_active)
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
             ON CONFLICT (id) DO NOTHING;`,
            [
              plan.id,
              plan.title,
              plan.category,
              plan.description || '',
              plan.durationDays || 7,
              plan.language || 'pt',
              JSON.stringify(plan.tasks || []),
              true
            ]
          );
        }
        console.log('[PostgreSQL] Seed concluído com sucesso!');
      }
    }).catch(err => {
      console.error('[PostgreSQL] Erro ao inicializar banco:', err.message);
      console.log('[Database] Continuando com armazenamento JSON em memória.');
    });
  } catch (err) {
    console.error('[PostgreSQL] Falha na conexão com pool:', err.message);
  }
} else {
  console.log('[Database] DATABASE_URL não definida. Operando em modo JSON local.');
}

// -------------------------------------------------------------
// Rate Limiter para geração de rotinas via IA (Proteção de custos)
// -------------------------------------------------------------
const aiRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 20, // Limite de 20 gerações por IP a cada 15 min
  message: {
    success: false,
    error: 'Limite de solicitações de IA atingido temporariamente. Tente novamente em alguns minutos ou use sua chave própria no app.'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// Middleware de Autenticação do Administrador
function requireAdmin(req, res, next) {
  const token = req.headers['x-admin-key'] || req.query.token;
  if (!token || token !== ADMIN_SECRET) {
    return res.status(401).json({ success: false, error: 'Acesso não autorizado. Chave de administrador inválida.' });
  }
  next();
}

// -------------------------------------------------------------
// Rotas Públicas (Consumidas pelo App Flutter)
// -------------------------------------------------------------

// Health check
app.get('/health', async (req, res) => {
  let count = localPlans.length;
  if (usePostgres && pool) {
    try {
      const r = await pool.query('SELECT COUNT(*) FROM study_plans WHERE is_active = true');
      count = parseInt(r.rows[0].count, 10);
    } catch (e) {}
  }

  res.json({
    status: 'ok',
    service: 'StudyFlow Backend API',
    database: usePostgres ? 'PostgreSQL' : 'JSON Local',
    activePlansCount: count,
    timestamp: new Date().toISOString()
  });
});

// GET /api/plans - Listar planos disponíveis
app.get('/api/plans', async (req, res) => {
  const { category, language } = req.query;

  try {
    if (usePostgres && pool) {
      let query = 'SELECT id, title, category, description, duration_days as "durationDays", jsonb_array_length(tasks) as "totalTasks", language FROM study_plans WHERE is_active = true';
      const params = [];

      if (category) {
        params.push(category);
        query += ` AND LOWER(category) = LOWER($${params.length})`;
      }
      if (language) {
        params.push(language);
        query += ` AND LOWER(language) = LOWER($${params.length})`;
      }
      query += ' ORDER BY created_at DESC';

      const result = await pool.query(query, params);
      return res.json({
        success: true,
        count: result.rows.length,
        plans: result.rows
      });
    }

    // Fallback JSON local
    let result = localPlans.map(plan => ({
      id: plan.id,
      title: plan.title,
      category: plan.category,
      description: plan.description,
      durationDays: plan.durationDays,
      totalTasks: plan.tasks ? plan.tasks.length : (plan.totalTasks || 0),
      language: plan.language || 'pt'
    }));

    if (category) {
      result = result.filter(p => p.category.toLowerCase() === category.toLowerCase());
    }
    if (language) {
      result = result.filter(p => (p.language || 'pt').toLowerCase() === language.toLowerCase());
    }

    res.json({
      success: true,
      count: result.length,
      plans: result
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/plans/:id - Baixar plano completo com tarefas
app.get('/api/plans/:id', async (req, res) => {
  const planId = req.params.id;

  try {
    if (usePostgres && pool) {
      const result = await pool.query(
        'SELECT id, title, category, description, duration_days as "durationDays", language, tasks FROM study_plans WHERE id = $1 AND is_active = true',
        [planId]
      );
      if (result.rows.length === 0) {
        return res.status(404).json({ success: false, error: 'Plano não encontrado' });
      }
      return res.json({ success: true, plan: result.rows[0] });
    }

    const plan = localPlans.find(p => p.id === planId);
    if (!plan) {
      return res.status(404).json({ success: false, error: 'Plano não encontrado' });
    }

    res.json({ success: true, plan });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/plans/generate - Proxy seguro de geração com IA
app.post('/api/plans/generate', aiRateLimiter, async (req, res) => {
  const { subjects, examDate, languageCode } = req.body;

  if (!subjects || !examDate) {
    return res.status(400).json({
      success: false,
      error: 'Parâmetros "subjects" e "examDate" são obrigatórios.'
    });
  }

  const apiKey = process.env.GEMINI_API_KEY || process.env.OPENROUTER_API_KEY;
  if (!apiKey) {
    return res.status(503).json({
      success: false,
      error: 'Chave de IA não configurada no servidor (.env). Configure GEMINI_API_KEY ou use chave própria no app.'
    });
  }

  try {
    const targetDate = new Date(examDate);
    const now = new Date();
    const daysUntilExam = Math.max(1, Math.round((targetDate - now) / (1000 * 60 * 60 * 24)));

    const prompt = `
Atue como um tutor acadêmico especialista. Crie um plano de estudos estruturado para as seguintes disciplinas: ${subjects}.
A prova será em ${daysUntilExam} dias (${examDate}).
Requisitos:
1. Retorne APENAS um JSON válido (sem markdown, sem crases \`\`\`).
2. Uma lista de objetos com os campos:
   - "title": Título curto da tarefa (no idioma do código: ${languageCode || 'pt'})
   - "category": Nome da disciplina correspondente
   - "priority": "High", "Medium" ou "Low"
   - "days_from_now": Número inteiro de dias a partir de hoje (0 para hoje, 1 para amanhã, etc.)
Exemplo:
[
  {"title": "Revisar Álgebra Básica", "category": "Matemática", "priority": "High", "days_from_now": 0},
  {"title": "Leitura do Capítulo 1", "category": "História", "priority": "Medium", "days_from_now": 1}
]
`;

    // Provedor 1: Gemini Direct
    if (process.env.GEMINI_API_KEY) {
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${process.env.GEMINI_API_KEY}`;
      const response = await fetch(geminiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { temperature: 0.7 }
        })
      });

      if (!response.ok) {
        const errText = await response.text();
        throw new Error(`Gemini API Error: ${response.status} - ${errText}`);
      }

      const data = await response.json();
      const rawText = data.candidates?.[0]?.content?.parts?.[0]?.text || '[]';
      const cleanJson = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
      const tasks = JSON.parse(cleanJson);

      return res.json({ success: true, source: 'gemini', tasks });
    }

    // Provedor 2: OpenRouter
    if (process.env.OPENROUTER_API_KEY) {
      const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`
        },
        body: JSON.stringify({
          model: 'google/gemini-2.0-flash-001',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.7
        })
      });

      if (!response.ok) {
        const errText = await response.text();
        throw new Error(`OpenRouter Error: ${response.status} - ${errText}`);
      }

      const data = await response.json();
      const rawText = data.choices?.[0]?.message?.content || '[]';
      const cleanJson = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
      const tasks = JSON.parse(cleanJson);

      return res.json({ success: true, source: 'openrouter', tasks });
    }
  } catch (error) {
    console.error('[StudyFlow API] Erro ao gerar com IA:', error.message);
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/plans/generate-from-doc - Gerador de Micro-Aulas Narradas com Exercícios por Documento
app.post('/api/plans/generate-from-doc', aiRateLimiter, async (req, res) => {
  const { contentText, durationMinutes, methodology, lessonsCount, languageCode } = req.body;

  if (!contentText || contentText.trim().length === 0) {
    return res.status(400).json({ success: false, error: 'O conteúdo ou texto do documento é obrigatório.' });
  }

  const apiKey = process.env.GEMINI_API_KEY || process.env.OPENROUTER_API_KEY;
  if (!apiKey) {
    return res.status(503).json({
      success: false,
      error: 'Chave de IA não configurada no servidor (.env).'
    });
  }

  const targetLessons = lessonsCount || 5;
  const targetDuration = durationMinutes || 10;
  const lang = languageCode || 'pt';

  const prompt = `
Você é um Tutor Acadêmico de Áudio especialista em microlearning e fixação de aprendizado.
Analise com rigor o seguinte conteúdo/ementa/documento e crie exatamente ${targetLessons} micro-aulas narradas (cada uma com ${targetDuration} minutos de duração estimada) e exercícios de fixação comentados.

CONTEÚDO DO DOCUMENTO:
${contentText}

REQUISITOS IMPORTANTES:
1. Retorne APENAS um JSON válido bruto (sem crases \`\`\` nem markdown).
2. O formato deve ser um array de objetos:
[
  {
    "id": "aula_1",
    "title": "Título conciso da micro-aula",
    "category": "Nome da disciplina ou tópico",
    "durationMinutes": ${targetDuration},
    "summaryLesson": "Texto completo, didático e envolvente da aula, escrito em tom de fala natural de professor explicando diretamente ao aluno para ser lido pelo leitor de voz. Use analogias, exemplos práticos e resuma as regras fundamentais.",
    "exercises": [
      {
        "question": "Enunciado claro da questão sobre o que acabou de ser ensinado",
        "options": ["Opção A", "Opção B", "Opção C", "Opção D"],
        "correctIndex": 0,
        "explanation": "Comentário falado pelo tutor justificando por que a opção está correta e alertando sobre as armadilhas das opções incorretas."
      }
    ]
  }
]
`;

  try {
    if (process.env.GEMINI_API_KEY) {
      const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${process.env.GEMINI_API_KEY}`;
      const response = await fetch(geminiUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: prompt }] }],
          generationConfig: { temperature: 0.7 }
        })
      });

      if (!response.ok) {
        const errText = await response.text();
        throw new Error(`Gemini API Error: ${response.status} - ${errText}`);
      }

      const data = await response.json();
      const rawText = data.candidates?.[0]?.content?.parts?.[0]?.text || '[]';
      const cleanJson = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
      const lessons = JSON.parse(cleanJson);

      return res.json({ success: true, source: 'gemini', lessons });
    }

    if (process.env.OPENROUTER_API_KEY) {
      const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`
        },
        body: JSON.stringify({
          model: 'google/gemini-2.0-flash-001',
          messages: [{ role: 'user', content: prompt }],
          temperature: 0.7
        })
      });

      if (!response.ok) {
        const errText = await response.text();
        throw new Error(`OpenRouter Error: ${response.status} - ${errText}`);
      }

      const data = await response.json();
      const rawText = data.choices?.[0]?.message?.content || '[]';
      const cleanJson = rawText.replace(/```json/g, '').replace(/```/g, '').trim();
      const lessons = JSON.parse(cleanJson);

      return res.json({ success: true, source: 'openrouter', lessons });
    }
  } catch (error) {
    console.error('[StudyFlow API] Erro ao gerar plano por documento:', error.message);
    res.status(500).json({ success: false, error: error.message });
  }
});

// -------------------------------------------------------------
// Rotas Administrativas (Painel Admin & Gerenciamento)
// -------------------------------------------------------------

// GET /api/admin/stats - Estatísticas para o painel admin
app.get('/api/admin/stats', requireAdmin, async (req, res) => {
  try {
    let totalPlans = localPlans.length;
    let totalTasks = 0;
    const categories = new Set();

    if (usePostgres && pool) {
      const resCount = await pool.query('SELECT COUNT(*) FROM study_plans');
      const resCat = await pool.query('SELECT DISTINCT category FROM study_plans');
      const resAll = await pool.query('SELECT tasks FROM study_plans');

      totalPlans = parseInt(resCount.rows[0].count, 10);
      resCat.rows.forEach(r => categories.add(r.category));
      resAll.rows.forEach(r => {
        if (Array.isArray(r.tasks)) totalTasks += r.tasks.length;
      });

      return res.json({
        success: true,
        stats: {
          totalPlans,
          totalCategories: categories.size,
          totalTasks,
          database: 'PostgreSQL'
        }
      });
    }

    localPlans.forEach(p => {
      categories.add(p.category);
      if (Array.isArray(p.tasks)) totalTasks += p.tasks.length;
    });

    res.json({
      success: true,
      stats: {
        totalPlans,
        totalCategories: categories.size,
        totalTasks,
        database: 'JSON Local'
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/admin/plans - Listar todos os planos (incluindo inativos) com tarefas
app.get('/api/admin/plans', requireAdmin, async (req, res) => {
  try {
    if (usePostgres && pool) {
      const result = await pool.query('SELECT * FROM study_plans ORDER BY created_at DESC');
      return res.json({ success: true, plans: result.rows });
    }
    res.json({ success: true, plans: localPlans });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/admin/plans - Criar novo plano de estudos
app.post('/api/admin/plans', requireAdmin, async (req, res) => {
  const { id, title, category, description, durationDays, language, tasks } = req.body;

  if (!title || !category || !tasks || !Array.isArray(tasks)) {
    return res.status(400).json({
      success: false,
      error: 'Campos "title", "category" e "tasks" (array) são obrigatórios.'
    });
  }

  const planId = id || `plan_${Date.now()}_${Math.random().toString(36).substring(2, 6)}`;
  const newPlan = {
    id: planId,
    title,
    category,
    description: description || '',
    durationDays: durationDays || 7,
    language: language || 'pt',
    tasks,
    is_active: true
  };

  try {
    if (usePostgres && pool) {
      await pool.query(
        `INSERT INTO study_plans (id, title, category, description, duration_days, language, tasks, is_active)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         ON CONFLICT (id) DO UPDATE SET
           title = EXCLUDED.title,
           category = EXCLUDED.category,
           description = EXCLUDED.description,
           duration_days = EXCLUDED.duration_days,
           language = EXCLUDED.language,
           tasks = EXCLUDED.tasks,
           updated_at = CURRENT_TIMESTAMP;`,
        [planId, title, category, description || '', durationDays || 7, language || 'pt', JSON.stringify(tasks), true]
      );
    } else {
      const idx = localPlans.findIndex(p => p.id === planId);
      if (idx >= 0) {
        localPlans[idx] = newPlan;
      } else {
        localPlans.push(newPlan);
      }
      fs.writeFileSync(plansFilePath, JSON.stringify(localPlans, null, 2));
    }

    res.json({ success: true, message: 'Plano salvo com sucesso!', plan: newPlan });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// DELETE /api/admin/plans/:id - Excluir plano de estudos
app.delete('/api/admin/plans/:id', requireAdmin, async (req, res) => {
  const planId = req.params.id;

  try {
    if (usePostgres && pool) {
      await pool.query('DELETE FROM study_plans WHERE id = $1', [planId]);
    } else {
      localPlans = localPlans.filter(p => p.id !== planId);
      fs.writeFileSync(plansFilePath, JSON.stringify(localPlans, null, 2));
    }

    res.json({ success: true, message: 'Plano removido com sucesso!' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`[StudyFlow API] Servidor rodando na porta ${PORT}`);
});
