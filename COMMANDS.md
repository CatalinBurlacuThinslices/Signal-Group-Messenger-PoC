# Signal PoC - Command Reference

## 🚀 **Quick Start (One Command)**

```bash
cd /Users/thinslicesacademy8/projects/safe-poc
./START_PROJECT.sh
```

This starts everything:
- Signal API (Docker)
- Backend server
- Frontend app
- Opens browser automatically

---

## 🛑 **Stop Everything**

```bash
./STOP_PROJECT.sh
```

---

## 📋 **Manual Commands**

### Start Signal API
```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-api
docker-compose up -d
```

### Start Backend
```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-poc/backend
PORT=5001 SIGNAL_NUMBER="+40751770274" SIGNAL_API_URL="http://localhost:8080" node server.js &
```

### Start Frontend
```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-poc/frontend
npm run dev &
```

---

## 🔍 **Check Status**

### Check All Services
```bash
# Docker
docker ps | grep signal

# Backend
ps aux | grep "node server.js" | grep -v grep

# Frontend
ps aux | grep "vite" | grep -v grep

# Ports
lsof -i :8080  # Signal API
lsof -i :5001  # Backend
lsof -i :3000  # Frontend
```

### Test Endpoints
```bash
# Signal API
curl http://localhost:8080/v1/health

# Backend
curl http://localhost:5001/api/health

# Frontend
curl http://localhost:3000
```

---

## 🔄 **Restart Services**

### Restart Everything
```bash
./STOP_PROJECT.sh
./START_PROJECT.sh
```

### Restart Backend Only
```bash
pkill -f "node server.js"
cd signal-poc/backend
PORT=5001 SIGNAL_NUMBER="+40751770274" SIGNAL_API_URL="http://localhost:8080" node server.js &
```

### Restart Frontend Only
```bash
pkill -f "vite"
cd signal-poc/frontend
npm run dev &
```

### Restart Signal API
```bash
cd signal-api
docker-compose restart
```

---

## 📱 **Signal Operations**

### Sync Groups
```bash
cd signal-api
./sync-groups.sh
```

### Link Device (Generate QR Code)
```bash
cd signal-api
./link-device.sh
# Then scan with Signal app
```

### Check if Linked
```bash
cd signal-api
./check-link.sh
```

---

## 🎮 **Switch Modes**

### Switch to Demo Mode (Mock Data)
```bash
cd signal-poc
./switch-mode.sh demo
```

### Switch to Real Mode (Actual Signal)
```bash
cd signal-poc
./switch-mode.sh real
```

---

## 📊 **View Logs**

### Signal API Logs
```bash
docker logs signal-api --tail 50 --follow
```

### Backend Logs
```bash
# If started in background
tail -f signal-poc/backend.log

# If started in foreground, check the terminal
```

### Frontend Logs
```bash
# Check browser console (F12 → Console tab)
# Or check terminal where npm run dev is running
```

---

## 🐛 **Troubleshooting Commands**

### Port Already in Use
```bash
# Find what's using the port
lsof -i :5001

# Kill it
lsof -ti :5001 | xargs kill -9
```

### Clean Restart
```bash
# Kill everything
pkill -f "node"
cd signal-api && docker-compose down
sleep 2

# Start fresh
cd ..
./START_PROJECT.sh
```

### Clear Signal Data (Start Fresh)
```bash
cd signal-api
docker-compose down
rm -rf signal-cli-config/data/*
docker-compose up -d
# Then link device again
```

---

## 📁 **Important Files**

| File | Location | Purpose |
|------|----------|---------|
| `START_PROJECT.sh` | Root | Start everything |
| `STOP_PROJECT.sh` | Root | Stop everything |
| `signal-api/link-device.sh` | signal-api/ | Generate QR code |
| `signal-api/sync-groups.sh` | signal-api/ | Sync new groups |
| `signal-poc/switch-mode.sh` | signal-poc/ | Switch demo/real mode |

---

## ⚡ **Daily Usage**

### Morning - Start Work
```bash
cd /Users/thinslicesacademy8/projects/safe-poc
./START_PROJECT.sh
```

### During Work - Send Messages
```bash
# Just use the browser
http://localhost:3000
```

### End of Day - Stop Everything
```bash
./STOP_PROJECT.sh
```

---

## 🎯 **Complete Command List**

```bash
# START
cd /Users/thinslicesacademy8/projects/safe-poc
./START_PROJECT.sh

# STOP
./STOP_PROJECT.sh

# CHECK STATUS
docker ps | grep signal
ps aux | grep "node\|vite" | grep -v grep

# VIEW LOGS
docker logs signal-api
tail -f signal-poc/backend.log

# SYNC GROUPS
cd signal-api && ./sync-groups.sh

# SWITCH MODE
cd signal-poc && ./switch-mode.sh demo  # or real
```

---

## 🌐 **URLs to Remember**

- **Web App:** http://localhost:3000
- **Backend API:** http://localhost:5001
- **Signal API:** http://localhost:8080

---

## 📝 **First Time Setup**

Only needed once:

```bash
# 1. Install dependencies
cd signal-poc/backend && npm install
cd ../frontend && npm install
cd ../..

# 2. Link your Signal device
cd signal-api
./link-device.sh
# Scan QR code with Signal app

# 3. Start project
cd ..
./START_PROJECT.sh
```

---

## ✅ **Simplest Workflow**

```bash
# Start
./START_PROJECT.sh

# Use
# Open: http://localhost:3000

# Stop
./STOP_PROJECT.sh
```

**That's it!** 🎉

