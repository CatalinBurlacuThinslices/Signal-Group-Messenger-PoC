# How to Share Signal Group Invite Links

## 📱 **What are Invite Links?**

Signal group invite links allow anyone to join a group by clicking a link - no need to manually add them!

**Example link:**
```
https://signal.group/#CjQKIDVGVwQ9ZAcV-mAfwoXoS7ez...
```

---

## 🔍 **Get Your Group Invite Links**

### Quick Command:
```bash
cd <project-root>/signal-api
./get-invite-links.sh
```

This shows all your groups and their invite links!

---

## 📤 **How to Share Invite Links**

### Method 1: Copy & Paste

**1. Get the link:**
```bash
cd signal-api
./get-invite-links.sh
```

**2. Copy the link** (looks like `https://signal.group/#...`)

**3. Share it via:**
- 📧 Email
- 💬 SMS / Text message
- 📱 WhatsApp, Telegram, etc.
- 💻 Slack, Discord
- 📋 Any messaging platform

**4. Recipients:**
- Click the link
- Opens Signal app
- Tap "Join Group"
- Done! ✅

---

### Method 2: QR Code

You can also create a QR code from the link:

**1. Get the link:**
```bash
./get-invite-links.sh
```

**2. Create QR code:**
```bash
# Install qrencode if needed
brew install qrencode  # macOS
# OR
sudo apt-get install qrencode  # Linux

# Generate QR code
echo "https://signal.group/#YOUR_LINK_HERE" | qrencode -o group-invite-qr.png

# Open it
open group-invite-qr.png
```

**3. People scan the QR code** and join!

---

### Method 3: Via Signal App

**On your phone:**
1. Open the group
2. Tap group name
3. Tap "Group link"
4. Tap "Share link"
5. Choose how to share

---

## 🔧 **If Groups Have No Invite Links**

### Enable Invite Links:

**Option 1: Via Signal App**
1. Open group on your phone
2. Tap group name → Settings
3. Enable "Group link"
4. Copy the link

**Option 2: Via API** (if primary registration)
```bash
# Update group to enable invite link
curl -X POST http://localhost:8080/v1/groups/+40751770274/GROUP_ID \
  -H 'Content-Type: application/json' \
  -d '{
    "resetLink": true
  }'
```

---

## 📊 **Current Groups Status**

Run this to see your groups:
```bash
cd <project-root>/signal-api
./get-invite-links.sh
```

---

## ✉️ **Example: How to Share**

### Via Email:
```
Subject: Join our Signal group!

Hi,

Click this link to join our Signal group:
https://signal.group/#CjQKIDVGVwQ9ZAcV-mAfwoXoS7ez...

See you there!
```

### Via SMS:
```
Hey! Join our Signal group: https://signal.group/#CjQKI...
```

### Via Any App:
Just paste the link - Signal handles the rest!

---

## 🎯 **Quick Reference**

**Get links:**
```bash
cd signal-api
./get-invite-links.sh
```

**Create new group with link:**
```bash
./create-group-with-link.sh "My New Group"
```

**Share:**
- Copy the `https://signal.group/#...` link
- Send it to anyone
- They click and join!

---

## ⚠️ **Security Notes**

**Invite links:**
- ✅ Can be shared publicly
- ✅ Anyone with link can join
- ⚠️ Can be reset/revoked if needed
- 🔒 Admins can control who stays

**To revoke a link:**
- Reset it in Signal app
- Or create a new one via API

---

**First, make sure Docker is running, then run `./get-invite-links.sh` to see your invite links!** 📱

