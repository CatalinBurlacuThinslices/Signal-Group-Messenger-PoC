# Signal PoC - Quick Reference

## 🚀 **Start the Project**

```bash
cd <project-root>
./START_PROJECT.sh
```

Opens automatically at: **http://localhost:3000**

---

## 🛑 **Stop the Project**

```bash
./STOP_PROJECT.sh
```

---

## 📊 **What's Included**

- ✅ Signal Group Messenger web app (React + Node.js)
- ✅ Complete Signal integration documentation
- ✅ Device linking functionality
- ✅ Demo mode & real mode
- ✅ Comprehensive guides

---

## 📁 **Project Structure**

```
Signal_PoC/
├── START_PROJECT.sh       ← Run this to start
├── STOP_PROJECT.sh        ← Run this to stop
├── COMMANDS.md            ← All commands reference
├── START_HERE.md          ← Complete guide
│
├── signal-api/            ← Signal API (Docker)
│   ├── docker-compose.yml
│   ├── link-device.sh     ← Link your Signal account
│   ├── sync-groups.sh     ← Sync new groups
│   └── check-link.sh      ← Check if linked
│
├── signal-poc/            ← Web Application
│   ├── backend/           ← Node.js API
│   ├── frontend/          ← React UI
│   ├── switch-mode.sh     ← Switch demo/real mode
│   └── README.md          ← App documentation
│
└── output/signal_documentation/  ← Complete Signal guides
```

---

## ⚡ **Quick Commands**

```bash
# Start everything
./START_PROJECT.sh

# Stop everything
./STOP_PROJECT.sh

# Check status
docker ps | grep signal
ps aux | grep "node\|vite" | grep -v grep

# View logs
docker logs signal-api
```

---

## 🌐 **Access Points**

- **Web App:** http://localhost:3000
- **Backend API:** http://localhost:5001
- **Signal API:** http://localhost:8080

---

## ⚠️ **Known Limitation**

**Linked Device Mode:**
- Messages send successfully ✅
- Appear in your Signal app ✅
- **But show as "notes to self" in groups** ⚠️
- This is a signal-cli linked device limitation
- Other members can't see messages sent from linked devices

**For Full Functionality:**
- Use demo mode (shows how it works)
- Or register a test number as primary device
- See `signal-api/QUICK_REGISTER.md` for details

---

## 📚 **Documentation**

- **COMMANDS.md** - Complete command reference
- **START_HERE.md** - Full getting started guide
- **signal-poc/README.md** - Web app documentation
- **output/signal_documentation/** - Complete Signal integration guides

---

## 🎯 **Daily Workflow**

```bash
# Morning: Start
./START_PROJECT.sh

# Use the app
# Go to http://localhost:3000

# Evening: Stop
./STOP_PROJECT.sh
```

---

## ✅ **Features**

✅ View Signal groups  
✅ Select group (click or dropdown)  
✅ Write and send messages  
✅ Error handling  
✅ Status indicators  
✅ Link Device button with QR code  
✅ Demo & Real modes  
✅ Complete documentation  

---

**Everything starts with one command: `./START_PROJECT.sh`** 🚀

