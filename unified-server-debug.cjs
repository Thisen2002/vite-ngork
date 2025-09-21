const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const port = process.env.PORT || 8080;

// Enhanced logging middleware
app.use((req, res, next) => {
  const timestamp = new Date().toISOString();
  console.log(`[${timestamp}] ${req.method} ${req.url} - From: ${req.ip || req.connection.remoteAddress}`);
  console.log(`Headers:`, JSON.stringify(req.headers, null, 2));
  next();
});

// Serve static frontend files
app.use(express.static(path.join(__dirname, 'dist'), {
  setHeaders: (res, path) => {
    console.log(`[STATIC] Serving: ${path}`);
  }
}));

// Health check for the unified server
app.get('/health', (req, res) => {
  console.log(`[HEALTH] Health check requested`);
  res.json({ 
    status: 'OK', 
    service: 'Unified Exhibition App Server',
    timestamp: new Date().toISOString(),
    port: port,
    backend_services: {
      'api-gateway': 'localhost:5000',
      'events-api': 'localhost:3036', 
      'heatmap-api': 'localhost:3897',
      'maps-api': 'localhost:3001',
      'auth-api': 'localhost:5004'
    }
  });
});

// Debug endpoint to test all backend services
app.get('/debug/test-backends', async (req, res) => {
  console.log(`[DEBUG] Testing all backend services`);
  
  const services = [
    { name: 'API Gateway', url: 'http://localhost:5000', proxy: '/api' },
    { name: 'Events API', url: 'http://localhost:3036', proxy: '/events-api' },
    { name: 'Heatmap API', url: 'http://localhost:3897', proxy: '/heatmap-api' },
    { name: 'Maps API', url: 'http://localhost:3001', proxy: '/maps-api' },
    { name: 'Auth API', url: 'http://localhost:5004', proxy: '/auth' }
  ];

  const results = {};
  
  for (const service of services) {
    try {
      const response = await fetch(service.url);
      results[service.name] = {
        status: 'online',
        statusCode: response.status,
        proxy_path: service.proxy,
        direct_url: service.url
      };
      console.log(`[DEBUG] ${service.name}: ONLINE (${response.status})`);
    } catch (error) {
      results[service.name] = {
        status: 'offline',
        error: error.message,
        proxy_path: service.proxy,
        direct_url: service.url
      };
      console.log(`[DEBUG] ${service.name}: OFFLINE - ${error.message}`);
    }
  }

  res.json({
    timestamp: new Date().toISOString(),
    unified_server_port: port,
    backend_services: results
  });
});

// API Gateway proxy - all /api/* requests go to port 5000
app.use('/api', createProxyMiddleware({
  target: 'http://localhost:5000',
  changeOrigin: true,
  pathRewrite: {
    '^/api': '', // Remove /api prefix when forwarding
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[API-PROXY] ${req.method} ${req.url} -> http://localhost:5000${proxyReq.path}`);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`[API-PROXY] Response: ${proxyRes.statusCode} for ${req.url}`);
  },
  onError: (err, req, res) => {
    console.error(`[API-PROXY] ERROR:`, err.message);
    res.status(502).json({ error: 'API Gateway unavailable', details: err.message });
  }
}));

// Events API proxy - /events-api/* requests go to port 3036
app.use('/events-api', createProxyMiddleware({
  target: 'http://localhost:3036',
  changeOrigin: true,
  pathRewrite: {
    '^/events-api': '',
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[EVENTS-PROXY] ${req.method} ${req.url} -> http://localhost:3036${proxyReq.path}`);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`[EVENTS-PROXY] Response: ${proxyRes.statusCode} for ${req.url}`);
  },
  onError: (err, req, res) => {
    console.error(`[EVENTS-PROXY] ERROR:`, err.message);
    res.status(502).json({ error: 'Events API unavailable', details: err.message });
  }
}));

// Heatmap API proxy - /heatmap-api/* requests go to port 3897
app.use('/heatmap-api', createProxyMiddleware({
  target: 'http://localhost:3897',
  changeOrigin: true,
  pathRewrite: {
    '^/heatmap-api': '',
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[HEATMAP-PROXY] ${req.method} ${req.url} -> http://localhost:3897${proxyReq.path}`);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`[HEATMAP-PROXY] Response: ${proxyRes.statusCode} for ${req.url}`);
  },
  onError: (err, req, res) => {
    console.error(`[HEATMAP-PROXY] ERROR:`, err.message);
    res.status(502).json({ error: 'Heatmap API unavailable', details: err.message });
  }
}));

// Maps API proxy - /maps-api/* requests go to port 3001
app.use('/maps-api', createProxyMiddleware({
  target: 'http://localhost:3001',
  changeOrigin: true,
  pathRewrite: {
    '^/maps-api': '',
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[MAPS-PROXY] ${req.method} ${req.url} -> http://localhost:3001${proxyReq.path}`);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`[MAPS-PROXY] Response: ${proxyRes.statusCode} for ${req.url}`);
  },
  onError: (err, req, res) => {
    console.error(`[MAPS-PROXY] ERROR:`, err.message);
    res.status(502).json({ error: 'Maps API unavailable', details: err.message });
  }
}));

// WebSocket proxy for Socket.IO connections
app.use('/socket.io', createProxyMiddleware({
  target: 'http://localhost:3001',
  changeOrigin: true,
  ws: true, // Enable WebSocket proxying
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[SOCKET-PROXY] ${req.method} ${req.url} -> http://localhost:3001${proxyReq.path}`);
  },
  onError: (err, req, res) => {
    console.error(`[SOCKET-PROXY] ERROR:`, err.message);
    if (res) res.status(502).json({ error: 'WebSocket unavailable', details: err.message });
  }
}));

// Auth endpoints proxy
app.use('/auth', createProxyMiddleware({
  target: 'http://localhost:5004',
  changeOrigin: true,
  pathRewrite: {
    '^/auth': '',
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[AUTH-PROXY] ${req.method} ${req.url} -> http://localhost:5004${proxyReq.path}`);
  },
  onProxyRes: (proxyRes, req, res) => {
    console.log(`[AUTH-PROXY] Response: ${proxyRes.statusCode} for ${req.url}`);
  },
  onError: (err, req, res) => {
    console.error(`[AUTH-PROXY] ERROR:`, err.message);
    res.status(502).json({ error: 'Auth API unavailable', details: err.message });
  }
}));

// Admin/Dashboard API proxy
app.use('/admin-api', createProxyMiddleware({
  target: 'http://localhost:5000',
  changeOrigin: true,
  pathRewrite: {
    '^/admin-api': '/admin',
  },
  onProxyReq: (proxyReq, req, res) => {
    console.log(`[ADMIN-PROXY] ${req.method} ${req.url} -> http://localhost:5000${proxyReq.path}`);
  },
  onError: (err, req, res) => {
    console.error(`[ADMIN-PROXY] ERROR:`, err.message);
    res.status(502).json({ error: 'Admin API unavailable', details: err.message });
  }
}));

// Catch-all handler for React Router (must be last)
app.use((req, res) => {
  console.log(`[FRONTEND] Serving index.html for: ${req.url}`);
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(port, '0.0.0.0', () => {
  console.log(`🌐 DEBUG Unified Exhibition App Server running on port ${port}`);
  console.log(`📱 Frontend: http://localhost:${port}`);
  console.log(`🔌 API Gateway: http://localhost:${port}/api`);
  console.log(`📅 Events API: http://localhost:${port}/events-api`);
  console.log(`🗺️  Maps API: http://localhost:${port}/maps-api`);
  console.log(`🔥 Heatmap API: http://localhost:${port}/heatmap-api`);
  console.log(`🔐 Auth API: http://localhost:${port}/auth`);
  console.log(`⚕️  Health Check: http://localhost:${port}/health`);
  console.log(`🐛 Debug Backend Test: http://localhost:${port}/debug/test-backends`);
  console.log(`\n🔍 Detailed request logging enabled`);
});