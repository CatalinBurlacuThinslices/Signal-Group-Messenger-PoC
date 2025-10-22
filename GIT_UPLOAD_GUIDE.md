# Git Upload Guide

## 📤 How to Upload This Project to GitHub

### Step 1: Initialize Git Repository

```bash
cd <project-root>
git init
```

### Step 2: Add All Files

```bash
git add .
```

### Step 3: Create First Commit

```bash
git commit -m "Initial commit: Signal Group Messenger PoC

- Complete React + Node.js web application
- Signal API integration via Docker
- Group messaging functionality
- Comprehensive documentation (30+ files)
- One-command startup scripts
- Complete helper utilities"
```

### Step 4: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `Signal-Group-Messenger-PoC` (or your choice)
3. Description: "Web application for sending messages to Signal groups"
4. **Keep it Public** or Private
5. **DON'T initialize** with README (you already have one)
6. Click "Create repository"

### Step 5: Push to GitHub

```bash
# Replace with YOUR GitHub username and repo name
git remote add origin https://github.com/YOUR_USERNAME/Signal-Group-Messenger-PoC.git
git branch -M main
git push -u origin main
```

---

## ⚠️ Before Uploading - Security Check

### Files That Are Gitignored (Won't Upload):

✅ **Automatically excluded:**
- `node_modules/` - Dependencies (will be npm installed)
- `.env` files - Your configuration
- `*.log` - Log files
- `signal-api/signal-cli-config/` - **CRITICAL: Contains your keys!**
- QR code images
- Build files

### Verify Gitignore Works:

```bash
cd <project-root>

# Check what will be committed
git status

# Make sure these DON'T appear:
# - signal-api/signal-cli-config/
# - .env files
# - node_modules/
# - *.log files
# - qr*.png files
```

**If they appear, they'll be uploaded!** Run:
```bash
git rm -r --cached signal-api/signal-cli-config
git rm -r --cached node_modules
git rm --cached signal-poc/backend/.env
git commit -m "Remove sensitive files"
```

### Double-Check Before Push:

```bash
# List all files that will be committed
git ls-files

# Search for sensitive patterns
git ls-files | grep -E "(\.env|signal-cli-config|node_modules)"

# If this returns ANYTHING, DO NOT PUSH!
# Remove those files first
```

---

## 📝 Recommended README Additions

Add these badges to your GitHub README:

```markdown
![Status](https://img.shields.io/badge/Status-PoC-yellow)
![License](https://img.shields.io/badge/License-MIT-blue)
![Node](https://img.shields.io/badge/Node.js-16+-green)
![React](https://img.shields.io/badge/React-18-blue)
![Docker](https://img.shields.io/badge/Docker-Required-blue)
```

---

## 🎯 Repository Description

**For GitHub repository description, use:**

```
Web application for sending messages to Signal groups. Built with React, Node.js, and signal-cli-rest-api. Complete PoC with full documentation.
```

**Topics/Tags:**
- signal
- messaging
- react
- nodejs
- express
- docker
- signal-protocol
- group-messaging
- proof-of-concept

---

## 📊 What Will Be Uploaded

### Source Code:
- ✅ React frontend (all .jsx, .css files)
- ✅ Node.js backend (server.js, etc.)
- ✅ Docker configuration
- ✅ Package.json files

### Documentation:
- ✅ 30+ markdown files
- ✅ Setup guides
- ✅ API references
- ✅ Troubleshooting guides

### Scripts:
- ✅ Startup scripts
- ✅ Helper utilities
- ✅ Signal API helpers

### NOT Uploaded (Gitignored):
- ❌ node_modules/
- ❌ Signal registration data
- ❌ .env files
- ❌ Logs
- ❌ Sensitive data

---

## 🔒 Security Reminders

**Before pushing:**
1. ✅ Check .gitignore is working
2. ✅ No .env files committed
3. ✅ No signal-cli-config/ uploaded
4. ✅ No API keys or passwords
5. ✅ No phone numbers in code (use env vars)

**After pushing:**
- Anyone can clone and use
- They need their own Signal number
- They run npm install for dependencies
- They configure their own .env

---

## 🚀 Clone Instructions (For Others)

Add this to your README:

```markdown
## Installation

\`\`\`bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/Signal-Group-Messenger-PoC.git
cd Signal-Group-Messenger-PoC

# Install dependencies
cd signal-poc/backend && npm install
cd ../frontend && npm install
cd ../..

# Setup Signal API
cd signal-api
docker-compose up -d

# Register your number (see GETTING_STARTED.md)

# Start application
cd ..
./START_PROJECT.sh
\`\`\`
```

---

## 📋 Git Commands Summary

```bash
# Initialize
cd <project-root>
git init

# Add files
git add .

# Commit
git commit -m "Initial commit: Signal Group Messenger PoC"

# Add remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push
git branch -M main
git push -u origin main
```

---

## ✅ Final Checklist

Before git push:
- [ ] Reviewed what's being committed (`git status`)
- [ ] No sensitive data (signal-cli-config, .env)
- [ ] No node_modules
- [ ] No log files
- [ ] No QR code images
- [ ] No phone numbers in code (replaced with placeholders like +[YOUR_NUMBER])
- [ ] README.md is clear and complete
- [ ] .gitignore is working
- [ ] Tested that .gitignore excludes sensitive files
- [ ] Ran: `git ls-files | grep -E "(\.env|signal-cli-config|node_modules)"`
- [ ] Above command returns NOTHING (if it shows files, remove them!)

---

## 🔐 Emergency: Already Pushed Sensitive Data?

**If you accidentally pushed sensitive data:**

```bash
# 1. Remove the sensitive file
git rm --cached path/to/sensitive/file

# 2. Commit the removal
git commit -m "Remove sensitive data"

# 3. Force push (⚠️ WARNING: This rewrites history!)
git push origin main --force

# 4. IMPORTANT: Rotate your credentials!
# - Re-register a new Signal number
# - Generate new tokens/keys
# - Update all .env files
```

**Better solution: Delete the repository and start fresh if it contained keys!**

---

**Your project is ready to upload to GitHub!** 🎉

Just run the git commands above and you're done!

