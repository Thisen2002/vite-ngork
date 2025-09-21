module.exports = {
  apps: [
    // Frontend Production Server
    {
      name: 'frontend-prod',
      script: 'server-frontend.cjs',
      cwd: '.',
      env: {
        PORT: 3000,
        NODE_ENV: 'production'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '1G',
      log_file: './logs/frontend-prod.log',
      out_file: './logs/frontend-prod-out.log',
      error_file: './logs/frontend-prod-error.log'
    },

    // API Gateway (Main Entry Point)
    {
      name: 'api-gateway-prod',
      script: 'src/index.js',
      cwd: './backend/Organizer_Dashboard-main/backend/api-gateway',
      env: {
        NODE_ENV: 'production',
        PORT: 5000,
        HOST: '0.0.0.0'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      log_file: './logs/api-gateway-prod.log',
      out_file: './logs/api-gateway-prod-out.log',
      error_file: './logs/api-gateway-prod-error.log'
    },

    // Events Service
    {
      name: 'events-service-prod',
      script: 'index.js',
      cwd: './backend/events',
      env: {
        NODE_ENV: 'production',
        PORT: 3036,
        HOST: '0.0.0.0'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      log_file: './logs/events-service-prod.log',
      out_file: './logs/events-service-prod-out.log',
      error_file: './logs/events-service-prod-error.log'
    },

    // Heatmap Service
    {
      name: 'heatmap-service-prod',
      script: 'index.js',
      cwd: './backend/heatmap/backend/exhibition-map-backend',
      env: {
        NODE_ENV: 'production',
        PORT: 3897,
        HOST: '0.0.0.0'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      log_file: './logs/heatmap-service-prod.log',
      out_file: './logs/heatmap-service-prod-out.log',
      error_file: './logs/heatmap-service-prod-error.log'
    },

    // Maps Service
    {
      name: 'maps-service-prod',
      script: 'app.js',
      cwd: './backend/Maps/backend map',
      env: {
        NODE_ENV: 'production',
        PORT: 3001,
        HOST: '0.0.0.0'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      log_file: './logs/maps-service-prod.log',
      out_file: './logs/maps-service-prod-out.log',
      error_file: './logs/maps-service-prod-error.log'
    },

    // Auth Service
    {
      name: 'auth-service-prod',
      script: 'src/index.js',
      cwd: './backend/Organizer_Dashboard-main/backend/services/auth-service',
      env: {
        NODE_ENV: 'production',
        PORT: 5004,
        HOST: '0.0.0.0'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      log_file: './logs/auth-service-prod.log',
      out_file: './logs/auth-service-prod-out.log',
      error_file: './logs/auth-service-prod-error.log'
    },

    // Organization Management Service
    {
      name: 'org-management-service-prod',
      script: 'src/index.js',
      cwd: './backend/Organizer_Dashboard-main/backend/services/orgMng-service',
      env: {
        NODE_ENV: 'production',
        PORT: 5001,
        HOST: '0.0.0.0'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      log_file: './logs/org-management-service-prod.log',
      out_file: './logs/org-management-service-prod-out.log',
      error_file: './logs/org-management-service-prod-error.log'
    },

    // Event Service (Dashboard)
    {
      name: 'event-service-dashboard-prod',
      script: 'src/index.js',
      cwd: './backend/Organizer_Dashboard-main/backend/services/event-service',
      env: {
        NODE_ENV: 'production',
        PORT: 5002,
        HOST: '0.0.0.0'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      log_file: './logs/event-service-dashboard-prod.log',
      out_file: './logs/event-service-dashboard-prod-out.log',
      error_file: './logs/event-service-dashboard-prod-error.log'
    },

    // Building Service
    {
      name: 'building-service-prod',
      script: 'src/index.js',
      cwd: './backend/Organizer_Dashboard-main/backend/services/building-service',
      env: {
        NODE_ENV: 'production',
        PORT: 5003,
        HOST: '0.0.0.0'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      log_file: './logs/building-service-prod.log',
      out_file: './logs/building-service-prod-out.log',
      error_file: './logs/building-service-prod-error.log'
    },

    // Alert Service
    {
      name: 'alert-service-prod',
      script: 'src/index.js',
      cwd: './backend/Organizer_Dashboard-main/backend/services/alert-service',
      env: {
        NODE_ENV: 'production',
        PORT: 5010,
        HOST: '0.0.0.0'
      },
      watch: false,
      instances: 1,
      autorestart: true,
      max_memory_restart: '512M',
      log_file: './logs/alert-service-prod.log',
      out_file: './logs/alert-service-prod-out.log',
      error_file: './logs/alert-service-prod-error.log'
    }
  ]
};