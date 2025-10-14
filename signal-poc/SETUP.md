# Signal Group Messenger - Complete Setup Guide

Step-by-step instructions to get the Signal Group Messenger PoC running.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Signal API Setup](#signal-api-setup)
3. [Application Setup](#application-setup)
4. [Testing](#testing)
5. [Quick Commands](#quick-commands)

---

## Prerequisites

### Required Software

- ✅ **Docker** - For running signal-cli-rest-api
  - Download: https://www.docker.com/products/docker-desktop
  
- ✅ **Node.js** (v16 or higher)
  - Download: https://nodejs.org/
  - Verify: `node --version`
  
- ✅ **npm** (comes with Node.js)
  - Verify: `npm --version`

### Required Resources

- ✅ **Phone number** for Signal (can receive SMS)
- ✅ **Signal mobile app** (to create groups)

---

## Signal API Setup

### Step 1: Create Signal API Directory

```bash
# Navigate to a location for Signal API
mkdir ~/signal-api
cd ~/signal-api
mkdir signal-cli-config
```

### Step 2: Create Docker Compose File

Create `docker-compose.yml`:

```yaml
version: "3"
services:
  signal-cli-rest-api:
    image: bbernhard/signal-cli-rest-api:latest
    container_name: signal-api
    ports:
      - "8080:8080"
    volumes:
      - "./signal-cli-config:/home/.local/share/signal-cli"
    environment:
      - MODE=native
    restart: unless-stopped
```

### Step 3: Start Signal API

```bash
# Start the container
docker-compose up -d

# Verify it's running
docker ps

# Test health endpoint
curl http://localhost:8080/v1/health
# Should return: {"status":"ok"}
```

### Step 4: Register Your Phone Number

**Important:** Use a dedicated phone number, not your personal Signal number!

```bash
# Replace with your actual number (E.164 format: +CountryCode + Number)
SIGNAL_NUMBER="+12345678900"

# Request verification code
curl -X POST http://localhost:8080/v1/register/${SIGNAL_NUMBER} \
  -H 'Content-Type: application/json' \
  -d '{"use_voice": false}'

# You'll receive an SMS with a 6-digit code
# Verify (replace 123456 with your code)
curl -X POST http://localhost:8080/v1/register/${SIGNAL_NUMBER}/verify/123456

# Should return: {"status":"verified"}
```

### Step 5: Create Groups in Signal App

1. Open Signal mobile app
2. Create a new group (or use existing)
3. Add at least one contact
4. Give the group a name

**Note:** You need to do this in the mobile app. The PoC will display these groups.

---

## Application Setup

### Step 1: Navigate to PoC Directory

```bash
cd ~/projects/safe-poc/signal-poc
```

### Step 2: Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp env.example .env

# Edit .env file
nano .env
# OR
code .env  # if using VS Code

# Set your Signal number:
# SIGNAL_NUMBER=+12345678900
# (same number you registered in Signal API step)

# Verify .env contents
cat .env
# Should show:
# PORT=5000
# SIGNAL_API_URL=http://localhost:8080
# SIGNAL_NUMBER=+12345678900
```

### Step 3: Frontend Setup

```bash
cd ../frontend

# Install dependencies
npm install

# No configuration needed for frontend
# It proxies to backend automatically
```

---

## Starting the Application

### Option 1: Using Start Script (Recommended)

**macOS/Linux:**
```bash
cd ~/projects/safe-poc/signal-poc
./start.sh
```

**Windows:**
```batch
cd C:\projects\safe-poc\signal-poc
start.bat
```

The script will:
- ✅ Check prerequisites
- ✅ Install dependencies
- ✅ Start backend server
- ✅ Start frontend server
- ✅ Open browser automatically

### Option 2: Manual Start

**Terminal 1 - Backend:**
```bash
cd ~/projects/safe-poc/signal-poc/backend
npm start

# Should see:
# Server running on port 5000
# ✅ Signal API connection successful
```

**Terminal 2 - Frontend:**
```bash
cd ~/projects/safe-poc/signal-poc/frontend
npm run dev

# Should see:
# Local: http://localhost:3000
```

**Terminal 3 - Keep Signal API running:**
```bash
# Verify Signal API is still running
docker ps | grep signal
```

### Step 4: Access the Application

Open your browser to: **http://localhost:3000**

You should see:
- 📱 Signal Group Messenger title
- Status indicators (both should be green)
- Your groups listed
- Send message form

---

## Testing

### Test 1: Health Check

```bash
# Test Signal API
curl http://localhost:8080/v1/health

# Test Backend
curl http://localhost:5000/api/health

# Test Frontend (in browser)
# http://localhost:3000
```

### Test 2: Fetch Groups

```bash
curl http://localhost:5000/api/groups
```

Should return JSON with your groups.

### Test 3: Send Test Message

In the web UI:
1. Click on a group
2. Type "Test message from Signal PoC"
3. Click "Send Message"
4. Check your Signal mobile app
5. Message should appear in the group!

---

## Quick Commands

### Start Everything

```bash
# Start Signal API
cd ~/signal-api && docker-compose up -d

# Start PoC
cd ~/projects/safe-poc/signal-poc && ./start.sh
```

### Stop Everything

```bash
# Stop PoC
pkill -f "node server.js"
pkill -f vite

# Stop Signal API
cd ~/signal-api && docker-compose down
```

### Restart Backend Only

```bash
pkill -f "node server.js"
cd ~/projects/safe-poc/signal-poc/backend
npm start
```

### View Logs

```bash
# Backend logs (in terminal where it's running)

# Signal API logs
docker logs signal-api --tail 50 --follow

# Frontend logs (browser console - press F12)
```

### Check Status

```bash
# Check all services
docker ps | grep signal           # Signal API
lsof -i :5000                     # Backend
lsof -i :3000                     # Frontend

# Health checks
curl http://localhost:8080/v1/health  # Signal API
curl http://localhost:5000/api/health # Backend
```

---

## Common Issues

### Issue: "Cannot connect to Signal API"

**Solution:**
```bash
# Start Signal API
cd ~/signal-api
docker-compose up -d
```

### Issue: "SIGNAL_NUMBER not configured"

**Solution:**
```bash
# Edit backend .env
cd ~/projects/safe-poc/signal-poc/backend
nano .env

# Add your number:
# SIGNAL_NUMBER=+12345678900

# Restart backend
pkill -f "node server.js"
npm start
```

### Issue: "No groups found"

**Solution:**
1. Create a group in Signal mobile app
2. Click "Refresh" button in web UI

### Issue: Port already in use

**Solution:**
```bash
# Kill process on port 5000
lsof -i :5000
kill -9 <PID>

# Or change port in backend/.env
echo "PORT=5001" >> backend/.env
```

For more issues, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

## Directory Structure

```
signal-poc/
├── backend/
│   ├── server.js           # Express server
│   ├── package.json        # Dependencies
│   ├── .env               # Configuration (create from env.example)
│   └── env.example        # Configuration template
├── frontend/
│   ├── src/
│   │   ├── App.jsx        # Main component
│   │   ├── App.css        # Styles
│   │   ├── main.jsx       # Entry point
│   │   └── index.css      # Global styles
│   ├── index.html         # HTML template
│   ├── package.json       # Dependencies
│   └── vite.config.js     # Vite config
├── README.md              # Overview
├── SETUP.md              # This file
├── USAGE.md              # Usage instructions
├── TROUBLESHOOTING.md    # Common issues
├── start.sh              # Start script (Unix)
├── start.bat             # Start script (Windows)
└── .gitignore           # Git ignore rules
```

---

## Architecture Overview

```
┌─────────────────────────────────────────┐
│  Browser (localhost:3000)               │
│  - React UI                             │
│  - Group selection                      │
│  - Message composition                  │
└────────────┬────────────────────────────┘
             │ HTTP (proxied)
             ↓
┌────────────────────────────────────────┐
│  Backend (localhost:5000)              │
│  - Express API                         │
│  - /api/groups - Fetch groups          │
│  - /api/send - Send messages           │
│  - /api/health - Health check          │
└────────────┬───────────────────────────┘
             │ HTTP
             ↓
┌────────────────────────────────────────┐
│  Signal API (localhost:8080)           │
│  - signal-cli-rest-api                 │
│  - Docker container                    │
│  - Signal protocol handler             │
└────────────┬───────────────────────────┘
             │ Signal Protocol
             ↓
┌────────────────────────────────────────┐
│  Signal Servers                        │
│  - Official Signal infrastructure      │
└────────────────────────────────────────┘
```

---

## What You Get

After setup, you can:

✅ View all your Signal groups  
✅ Select any group  
✅ Send messages to groups  
✅ See real-time status  
✅ Get error messages if something fails  
✅ Refresh groups list  

---

## Next Steps

1. ✅ Complete this setup
2. 📖 Read [USAGE.md](./USAGE.md) for detailed usage
3. 🔧 If issues, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
4. 📚 Learn more in [../output/signal_documentation/](../output/signal_documentation/)

---

## Security Notes

⚠️ **This is a Proof of Concept!**

For production:
- Add authentication
- Use HTTPS
- Implement rate limiting
- Add input validation
- Secure credentials
- Add logging
- Set up monitoring

---

## Support

If you need help:

1. Check [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
2. Review logs (backend terminal + browser console)
3. Verify Signal API is running: `docker ps`
4. Check configuration in `backend/.env`

---

**Ready to send Signal messages! 📱✨**

