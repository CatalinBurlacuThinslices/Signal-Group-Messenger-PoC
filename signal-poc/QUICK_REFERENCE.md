# Quick Reference Card

One-page reference for Signal Group Messenger PoC.

---

## 🚀 Quick Start (5 Minutes)

```bash
# 1. Start Signal API (first time)
cd ~/signal-api
docker-compose up -d

# 2. Register number (first time only)
curl -X POST http://localhost:8080/v1/register/+12345678900 \
  -d '{"use_voice": false}'
curl -X POST http://localhost:8080/v1/register/+12345678900/verify/CODE

# 3. Start PoC
cd <project-root>/signal-poc
./start.sh

# 4. Open http://localhost:3000
```

---

## 📂 Project Structure

```
signal-poc/
├── backend/          # Node.js + Express API
├── frontend/         # React + Vite UI
├── README.md         # Overview
├── SETUP.md         # Full setup guide
├── USAGE.md         # How to use
└── start.sh         # Startup script
```

---

## 🔧 Configuration

### Backend (.env)
```env
PORT=5000
SIGNAL_API_URL=http://localhost:8080
SIGNAL_NUMBER=+12345678900
```

---

## 🌐 Ports

| Service | Port | URL |
|---------|------|-----|
| Frontend | 3000 | http://localhost:3000 |
| Backend | 5000 | http://localhost:5000 |
| Signal API | 8080 | http://localhost:8080 |

---

## 📡 API Endpoints

```bash
# Health
GET /api/health

# Groups
GET /api/groups

# Send
POST /api/send
{
  "groupId": "base64-id",
  "message": "text"
}
```

---

## 🐛 Common Commands

```bash
# Check status
docker ps | grep signal
lsof -i :5000
curl http://localhost:8080/v1/health
curl http://localhost:5000/api/health

# Restart backend
pkill -f "node server.js"
cd backend && npm start

# View logs
docker logs signal-api
# Backend: check terminal
# Frontend: F12 → Console

# Stop everything
pkill -f "node server.js"
pkill -f vite
docker-compose down
```

---

## ❌ Common Errors

| Error | Fix |
|-------|-----|
| Cannot connect to Signal API | `docker-compose up -d` |
| SIGNAL_NUMBER not configured | Edit `backend/.env` |
| No groups found | Create group in Signal app |
| Port in use | `lsof -i :5000` → `kill PID` |

---

## 📚 Documentation

- **README.md** - Overview & quick start
- **SETUP.md** - Complete setup instructions
- **USAGE.md** - Detailed usage guide
- **TROUBLESHOOTING.md** - Problem solving
- **PROJECT_SUMMARY.md** - Technical overview

---

## 🎯 Answer to Your Questions

### Do I need a database?
**No!** This PoC is stateless. Groups are fetched from Signal API in real-time.

### How to connect with Signal?
Via **signal-cli-rest-api** running in Docker. The backend proxies requests to it.

### Error messages?
- ✅ Logged to backend console (JSON format)
- ✅ Shown in browser alert box (red)
- ✅ Visible in browser console (F12)

### Simple design?
- ✅ Clean gradient UI
- ✅ Text boxes for input
- ✅ Click-to-select groups
- ✅ One-click send

---

## 🎨 Features

✅ View all Signal groups  
✅ Select group from list  
✅ Write message in text box  
✅ Send with one click  
✅ Real-time errors/success  
✅ Status indicators  

---

## 🔑 Key Files

- `backend/server.js` - Express API server
- `frontend/src/App.jsx` - React main component
- `backend/.env` - Configuration (create from env.example)
- `start.sh` - Startup script

---

## 📞 Testing

```bash
# Test full flow
curl http://localhost:5000/api/groups
curl -X POST http://localhost:5000/api/send \
  -H 'Content-Type: application/json' \
  -d '{"groupId":"xxx","message":"Test"}'
```

Or use the web UI at http://localhost:3000

---

**Need more help?** Check TROUBLESHOOTING.md

