# 📱 Signal Group Messenger - Complete PoC

A complete web application for sending messages to Signal groups, built with React and Node.js.

![Status](https://img.shields.io/badge/Status-Working-success)
![License](https://img.shields.io/badge/License-MIT-blue)
![Node](https://img.shields.io/badge/Node.js-16+-green)
![React](https://img.shields.io/badge/React-18-blue)
![Docker](https://img.shields.io/badge/Docker-Required-blue)

A complete web application for sending messages to Signal groups, built with React and Node.js.

## 🚀 Quick Start

```bash
cd Signal_PoC
./START_PROJECT.sh
```

Opens automatically at: **http://localhost:3000**

---

## ✨ Features

✅ View all your Signal groups  
✅ Select groups (click or dropdown)  
✅ Send messages to groups  
✅ Broadcast to multiple phone numbers  
✅ **Set custom profile name** (e.g., "Amatsu" instead of phone number) 🎭  
✅ **Upload profile picture from web UI** 📸 ⭐ NEW!  
✅ Messages visible to all members  
✅ Real-time error handling  
✅ Status indicators  
✅ Auto-sync on refresh  
✅ Beautiful modern UI  
✅ Complete documentation  

---

## 📁 Project Structure

```
Signal_PoC/
├── README.md                     ← Start here
├── COMPLETE_DOCUMENTATION.md     ← 📖 Master doc (3000+ lines!)
├── START_PROJECT.sh              ← Run this to start
├── STOP_PROJECT.sh               ← Stop everything
├── COMMANDS.md                   ← All commands
├── PROJECT_COMPLETE.md           ← Complete documentation
├── GIT_UPLOAD_GUIDE.md           ← GitHub upload guide
│
├── signal-api/                   ← Signal API (Docker)
│   ├── docker-compose.yml
│   ├── register.sh               ← Register phone number
│   ├── verify.sh                 ← Verify SMS code
│   ├── sync-groups.sh            ← Sync groups
│   ├── add-member-to-group.sh    ← Invite members
│   └── ... (15+ helper scripts)
│
├── signal-poc/                   ← Web Application
│   ├── backend/                  ← Node.js/Express API
│   ├── frontend/                 ← React UI
│   └── ... (12+ docs)
│
└── signal_documentation/         ← Complete Signal guides
    └── ... (10 comprehensive files)
```

---

## 🛠️ Tech Stack

- **Frontend:** React 18, Vite
- **Backend:** Node.js, Express
- **Signal:** signal-cli-rest-api (Docker)
- **Styling:** Vanilla CSS

---

## 📋 Prerequisites

- Docker Desktop
- Node.js 16+
- npm
- Signal phone number

---

## 🔧 Setup

### First Time Setup:

**1. Install dependencies:**
```bash
cd signal-poc/backend && npm install
cd ../frontend && npm install
cd ../..
```

**2. Start Signal API:**
```bash
cd signal-api
docker-compose up -d
```

**3. Register your phone number:**
```bash
# Get captcha from: https://signalcaptchas.org/registration/generate.html
./register.sh 'signalcaptcha://YOUR_TOKEN'

# Verify with SMS code
./verify.sh 123456
```

**4. Start the app:**
```bash
cd ..
./START_PROJECT.sh
```

**5. Create/join groups and start messaging!**

---

## 📱 Usage

### Start Everything:
```bash
./START_PROJECT.sh
```

### Use the Web App:
- Open: http://localhost:3000
- **Set your profile:** Click "🎭 Set Profile Name"
  - Enter name (e.g., "Amatsu")
  - Upload profile picture 📸
  - Add status/emoji
  - Save!
- Click refresh to sync groups
- Select a group or enter phone numbers
- Type message
- Send!

### Set Your Profile (Name + Picture):
```bash
cd signal-api

# Just name
./set-profile-name.sh Amatsu

# Just picture
./set-profile-avatar.sh ~/Pictures/photo.jpg

# Everything at once
./set-full-profile.sh "Amatsu" "Gamer" "🎮" ~/Pictures/photo.jpg
```

See [SET_PROFILE_COMPLETE.md](SET_PROFILE_COMPLETE.md) for detailed instructions.

### Stop Everything:
```bash
./STOP_PROJECT.sh
```

---

## 📚 Documentation

- **COMPLETE_DOCUMENTATION.md** - 📖 **Master documentation (3000+ lines!)** - Everything your team needs
- **START_HERE.md** - Complete getting started guide
- **COMMANDS.md** - All commands reference
- **PROJECT_COMPLETE.md** - Full project documentation
- **GIT_UPLOAD_GUIDE.md** - How to upload to GitHub safely
- **signal-poc/README.md** - Web app details
- **signal_documentation/** - Deep dive (10 files)

---

## 🎯 What It Does

This PoC demonstrates:
- Signal messaging integration
- Web-based group communication
- Real-time messaging
- Modern UI/UX
- Full-stack development
- API integration patterns

Perfect for:
- Safe wallet transaction alerts
- System monitoring notifications
- Team collaboration
- Automated messaging systems

---

## ⚠️ Known Limitations

**signal-cli limitations (not code issues):**
- Invite link generation is limited
- Some GroupsV2 features incomplete
- **Workaround:** Add members directly (works perfectly!)

**Recommended:**
- Use for outgoing messages (works great!)
- Use Signal mobile app for complex group admin tasks

---

## 🔐 Security Notes

**For Production:**
- Add authentication
- Use HTTPS
- Implement rate limiting
- Secure credentials
- Add monitoring

**Current:** PoC/Demo purposes only

---

## 📊 Project Stats

- **Lines of Code:** 3,500+
- **Documentation:** 30+ files
- **Scripts:** 15+ helpers
- **Components:** 3 (Frontend, Backend, Signal API)
- **Setup Time:** ~15 minutes
- **Start Time:** 1 command

---

## 🤝 Contributing

This is a complete PoC. Feel free to extend it!

Possible enhancements:
- Message history
- Scheduled messages
- File attachments
- User authentication
- Analytics
- Message templates

---

## 📄 License

MIT License - Free to use and modify

---

## 🆘 Support

- **First:** Read COMPLETE_DOCUMENTATION.md (comprehensive guide with everything!)
- Check COMMANDS.md for all commands
- See PROJECT_COMPLETE.md for project summary
- Review GIT_UPLOAD_GUIDE.md before pushing to GitHub
- Review signal_documentation/ for Signal details

---

## ✅ Success Criteria

You know it's working when:
- ✅ Can view groups
- ✅ Can select groups
- ✅ Can send messages
- ✅ Everyone in group sees messages
- ✅ Status shows green
- ✅ No errors in console

---

**Start with:** `./START_PROJECT.sh`  
**Access at:** http://localhost:3000  
**Documentation:** Read COMPLETE_DOCUMENTATION.md for everything!

---

**A complete, working Signal Group Messenger PoC!** 🎉📱

