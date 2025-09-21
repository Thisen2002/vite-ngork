# Internet Access Setup Guide

## 🚀 Quick Internet Access with Ngrok (Recommended)

### Step 1: Download Ngrok
1. Go to https://ngrok.com/download
2. Sign up for free account
3. Download ngrok for Windows

### Step 2: Setup Ngrok
```powershell
# Extract ngrok.exe to your project folder
# Then run:
.\ngrok.exe authtoken YOUR_AUTHTOKEN_FROM_NGROK_DASHBOARD
.\ngrok.exe http 3000
```

### Step 3: Get Your Internet URL
Ngrok will display URLs like:
- **HTTP**: http://abc123.ngrok.io
- **HTTPS**: https://abc123.ngrok.io

### Step 4: Share Your App
Anyone worldwide can access your app using the ngrok URL!

---

## 🏠 Router Port Forwarding (Permanent)

### Step 1: Find Your Local IP
```powershell
ipconfig | findstr IPv4
```

### Step 2: Get Public IP
Visit: https://whatismyip.com

### Step 3: Router Configuration
1. Access router (usually 192.168.1.1)
2. Find "Port Forwarding" or "Virtual Server"
3. Forward port 3000 to your computer's local IP

### Step 4: Windows Firewall (Run as Administrator)
```powershell
New-NetFirewallRule -DisplayName "Exhibition App Frontend" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
New-NetFirewallRule -DisplayName "Exhibition App API Gateway" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow
```

### Step 5: Access Over Internet
Your app will be available at: `http://YOUR_PUBLIC_IP:3000`

---

## ☁️ Cloud Deployment Options

### A. Heroku (Easy)
1. Install Heroku CLI
2. Create Heroku app
3. Deploy using Git

### B. DigitalOcean/AWS/Linode (VPS)
1. Create Ubuntu VPS ($5-10/month)
2. Upload your project
3. Run: `./quick-host.ps1`
4. Access via VPS IP

### C. Vercel/Netlify (Frontend Only)
1. Connect GitHub repository
2. Auto-deploy frontend
3. Backend services need separate hosting

---

## 🐳 Docker Cloud Deployment

### Step 1: Build Docker Image
```powershell
docker build -t exhibition-app .
```

### Step 2: Deploy to Cloud
- **Docker Hub** + any VPS
- **Google Cloud Run**
- **AWS ECS**
- **Azure Container Instances**

---

## 🔒 Security Considerations

### For Production Internet Access:
1. **SSL Certificate**: Use HTTPS (Let's Encrypt)
2. **Environment Variables**: Secure API keys
3. **Database Security**: Use production database
4. **Rate Limiting**: Prevent abuse
5. **Authentication**: Secure admin areas

---

## 💡 Recommended Approach:

1. **For Testing**: Use **Ngrok** (5 minutes setup)
2. **For Production**: Use **Cloud VPS** (DigitalOcean/AWS)
3. **For Enterprise**: Use **Docker** + **Kubernetes**

## Quick Start with Ngrok:
```powershell
# Download ngrok.exe to your project folder
.\ngrok.exe http 3000
# Share the https://xyz.ngrok.io URL with anyone!
```