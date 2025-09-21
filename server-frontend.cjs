const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// Serve static files from the dist directory
app.use(express.static(path.join(__dirname, 'dist')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'frontend' });
});

// API proxy endpoints (if needed)
app.use('/api', (req, res) => {
  res.status(502).json({ error: 'API Gateway not configured for static server' });
});

// Handle React Router - catch all other routes
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Frontend server running at http://localhost:${port}`);
});