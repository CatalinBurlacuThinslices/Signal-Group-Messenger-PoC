# Getting Started - Signal Group Messenger PoC

Complete guide to set up and run the Signal Group Messenger web application.

---

## 📋 Prerequisites

Before starting, make sure you have:

- ✅ **Docker Desktop** installed and running
- ✅ **Node.js** 16+ and npm
- ✅ **Phone number** for Signal registration
- ✅ Terminal/command line access

---

## 🚀 Quick Start (5 Minutes)

### Step 1: Clone/Download This Project

```bash
cd /Users/thinslicesacademy8/projects/Signal_PoC
```

### Step 2: Install Dependencies

```bash
# Backend
cd signal-poc/backend
npm install

# Frontend
cd ../frontend
npm install

# Return to root
cd ../..
```

### Step 3: Start Signal API

```bash
cd signal-api
docker-compose up -d
cd ..
```

### Step 4: Register Your Phone Number

**Get captcha token:**
1. Visit: https://signalcaptchas.org/registration/generate.html
2. Solve captcha
3. Right-click "Open Signal" → Copy link

**Register:**
```bash
cd signal-api
./register.sh 'signalcaptcha://YOUR_CAPTCHA_TOKEN'
```

**Verify with SMS code:**
```bash
./verify.sh 123456  # Replace with your code
cd ..
```

### Step 5: Start the Application

```bash
./START_PROJECT.sh
```

**Opens automatically at:** http://localhost:3000

---

## 🎯 First Use

### Create or Join Groups

**Option 1: Create a group**
```bash
cd signal-api
curl -X POST http://localhost:8080/v1/groups/+YOUR_NUMBER \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "My First Group",
    "members": ["+FRIEND_NUMBER"]
  }'
```

**Option 2: Get invited to existing groups**
- Ask someone to add your number to their group
- Run `./sync-groups.sh`
- Group appears in web app!

### Send Your First Message

1. **Refresh browser:** http://localhost:3000
2. **Click refresh (🔄)** to sync groups
3. **Select a group**
4. **Type:** "Hello from Signal PoC!"
5. **Click "Send Message"**
6. **Check Signal app** - everyone sees it! ✅

---

## 📁 Project Structure

```
Signal_PoC/
├── README.md                  # Project overview
├── GETTING_STARTED.md         # This file
├── START_PROJECT.sh           # Start script
├── STOP_PROJECT.sh            # Stop script
│
├── signal-api/                # Signal backend
├── signal-poc/                # Web app
└── signal_documentation/      # Guides
```

---

## 🔧 Configuration

### Backend Configuration

Create `signal-poc/backend/.env`:

```env
PORT=5001
SIGNAL_API_URL=http://localhost:8080
SIGNAL_NUMBER=+YOUR_PHONE_NUMBER
```

**Note:** START_PROJECT.sh uses environment variables, so .env is optional.

---

## 🌐 Access Points

After starting:
- **Web App:** http://localhost:3000
- **Backend API:** http://localhost:5001
- **Signal API:** http://localhost:8080

---

## 📚 Documentation

- **README.md** - Project overview
- **START_HERE.md** - Detailed guide
- **COMMANDS.md** - All commands
- **PROJECT_COMPLETE.md** - Complete docs
- **signal_documentation/** - Deep dive

---

## 🐛 Troubleshooting

### Docker not starting
```bash
# Check Docker Desktop is running
docker ps

# Restart Signal API
cd signal-api
docker-compose restart
```

### Port already in use
```bash
# Check what's using ports
lsof -i :5001  # Backend
lsof -i :3000  # Frontend
lsof -i :8080  # Signal API

# Kill and restart
./STOP_PROJECT.sh
./START_PROJECT.sh
```

### No groups showing
```bash
# Sync with Signal
cd signal-api
./sync-groups.sh

# Refresh browser
```

---

## ✅ Success Checklist

- [ ] Docker running
- [ ] Dependencies installed (npm install)
- [ ] Signal API started (docker-compose up -d)
- [ ] Number registered and verified
- [ ] Groups created or joined
- [ ] App started (./START_PROJECT.sh)
- [ ] Can access http://localhost:3000
- [ ] Groups visible in UI
- [ ] Can send messages
- [ ] Messages visible to all members

---

## 🎉 Next Steps

Once running:
1. Create groups or get invited
2. Send messages via web interface
3. Invite others to your groups
4. Explore the documentation
5. Customize for your needs!

---

**Need help?** Check COMMANDS.md for all available commands!

