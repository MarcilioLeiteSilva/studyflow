require('dotenv').config();
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;

// Serve public directory
app.use(express.static(path.join(__dirname, 'public')));

// Config endpoint for client-side to know API base URL
app.get('/api/config', (req, res) => {
  res.json({
    apiUrl: process.env.API_URL || 'http://localhost:3000',
    env: process.env.NODE_ENV || 'production'
  });
});

// Fallback to index.html
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`[StudyFlow Admin] Painel Administrativo rodando na porta ${PORT}`);
  console.log(`[StudyFlow Admin] Acesse em http://localhost:${PORT}`);
});
