const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const port = process.env.PORT || 8080; // Single port for everything

// Serve static frontend files
app.use(express.static(path.join(__dirname, 'dist')));

// Health check for the unified server
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    service: 'Unified Exhibition App Server',
    timestamp: new Date().toISOString()
  });
});

// API Gateway proxy - all /api/* requests go to port 5000
app.use('/api', createProxyMiddleware({
  target: 'http://localhost:5000',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // Remove /api prefix when forwarding
  },
  onError: (err, req, res) => {
    console.log('API Gateway Error:', err.message);
    res.status(502).json({ error: 'API Gateway unavailable' });
  }
}));

// Events API proxy - /events-api/* requests go to port 3036
app.use('/events-api', createProxyMiddleware({
  target: 'http://localhost:3036',
  changeOrigin: true,
  pathRewrite: {
    '^/events-api': '',
  },
  onError: (err, req, res) => {
    console.log('Events API Error:', err.message);
    res.status(502).json({ error: 'Events API unavailable' });
  }
}));

// Heatmap API proxy - /heatmap-api/* requests go to port 3897
app.use('/heatmap-api', createProxyMiddleware({
  target: 'http://localhost:3897',
  changeOrigin: true,
  pathRewrite: {
    '^/heatmap-api': '',
  },
  onError: (err, req, res) => {
    console.log('Heatmap API Error:', err.message);
    res.status(502).json({ error: 'Heatmap API unavailable' });
  }
}));

// Maps API proxy - /maps-api/* requests go to port 3001
app.use('/maps-api', createProxyMiddleware({
  target: 'http://localhost:3001',
  changeOrigin: true,
  pathRewrite: {
    '^/maps-api': '',
  },
  onError: (err, req, res) => {
    console.log('Maps API Error:', err.message);
    res.status(502).json({ error: 'Maps API unavailable' });
  }
}));

// WebSocket proxy for Socket.IO connections
app.use('/socket.io', createProxyMiddleware({
  target: 'http://localhost:3001',
  changeOrigin: true,
  ws: true, // Enable WebSocket proxying
  onError: (err, req, res) => {
    console.log('WebSocket Error:', err.message);
    if (res) res.status(502).json({ error: 'WebSocket unavailable' });
  }
}));

// Auth endpoints proxy
app.use('/auth', createProxyMiddleware({
  target: 'http://localhost:5004',
  changeOrigin: true,
  pathRewrite: {
    '^/auth': '',
  }
}));

// Admin/Dashboard API proxy
app.use('/admin-api', createProxyMiddleware({
  target: 'http://localhost:5000', // API Gateway handles admin routes
  changeOrigin: true,
  pathRewrite: {
    '^/admin-api': '/admin',
  }
}));

// Catch-all handler for React Router (must be last)
app.use((req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🌐 Unified Exhibition App Server running on port ${port}`);
  console.log(`📱 Frontend: http://localhost:${port}`);
  console.log(`🔌 API Gateway: http://localhost:${port}/api`);
  console.log(`📅 Events API: http://localhost:${port}/events-api`);
  console.log(`🗺️  Maps API: http://localhost:${port}/maps-api`);
  console.log(`🔥 Heatmap API: http://localhost:${port}/heatmap-api`);
  console.log(`🔐 Auth API: http://localhost:${port}/auth`);
  console.log(`⚕️  Health Check: http://localhost:${port}/health`);
});