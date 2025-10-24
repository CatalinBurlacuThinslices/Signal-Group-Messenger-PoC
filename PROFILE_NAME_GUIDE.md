# How to Set Your Profile Name to "Amatsu" (or any name)

Want your Signal messages to show "Amatsu" instead of your phone number? Here's how! 🎭

---

## ⚡ Quick Method: Use the Web Interface

The **easiest way** is through the web interface:

### Steps:

1. **Start your project** (if not already running):
```bash
cd signal-poc
./start-all.sh
```

2. **Open the web app** in your browser:
```
http://localhost:3000
```

3. **Click the "🎭 Set Profile Name" button** in the top bar

4. **Fill in the form:**
   - Display Name: `Amatsu` (or your preferred name)
   - About (optional): `Available 24/7`
   - Emoji (optional): `🌟`

5. **Click "Save Profile"**

6. **Done!** Your name is now set. 🎉

All your future messages will appear as coming from "Amatsu"!

---

## 🖥️ Alternative Method: Use the Command Line

If you prefer the terminal:

### Option 1: Using the Script

```bash
cd signal-api
./set-profile-name.sh Amatsu
```

### Option 2: Using cURL

```bash
curl -X PUT \
  http://localhost:8080/v1/profiles/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Amatsu"
  }'
```

**Note:** Replace `+40751770274` with your actual Signal phone number if different.

---

## 🎨 Advanced: Set Name with Status and Emoji

Make your profile more expressive:

```bash
curl -X PUT \
  http://localhost:8080/v1/profiles/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Amatsu",
    "about": "Gamer & Developer",
    "emoji": "🎮"
  }'
```

---

## ✅ Verify It's Working

### Test by Sending a Message:

1. Go to http://localhost:3000
2. Select a group or enter a phone number
3. Send a test message
4. Check on your phone - you should see "Amatsu" as the sender!

### What Recipients See:

**Before setting name:**
```
+40751770274
Hello!
```

**After setting name to "Amatsu":**
```
Amatsu
Hello!
```

**With emoji and status:**
```
Amatsu 🎮
Hello!
```

---

## 🔄 Change Your Name Anytime

You can update your profile name as many times as you want:

### Through Web Interface:
1. Click "🎭 Set Profile Name"
2. Enter new name
3. Save

### Through Command Line:
```bash
./set-profile-name.sh "New Name"
```

### Examples:
```bash
# Professional name
./set-profile-name.sh "Support Team"

# Gaming name
./set-profile-name.sh "Amatsu Gaming"

# With emoji
./set-profile-name.sh "Amatsu 🎮"
```

---

## 📋 Name Ideas

Here are some ideas for profile names:

**Gaming:**
- Amatsu
- Amatsu Gaming 🎮
- [Clan] Amatsu
- Amatsu | Streaming

**Professional:**
- Support Team 📞
- Customer Service
- Sales Department
- Tech Support Bot 🤖

**Personal:**
- Your Name
- Nickname
- Your Name | Status
- Your Name 🌟

**Bot/Automated:**
- Notification Bot 🔔
- Alert System ⚠️
- Status Updates 📊
- Reminder Bot ⏰

---

## 🐛 Troubleshooting

### Name not showing up?

1. **Wait a moment** - Changes can take 1-2 minutes to sync
2. **Check Signal API is running:**
```bash
docker ps | grep signal
```

3. **Restart your app:**
```bash
cd signal-poc
./start-all.sh
```

### Getting errors?

**Error: "Signal API unreachable"**
```bash
cd signal-api
docker-compose up -d
```

**Error: "Number not registered"**

Make sure your number is linked or registered:
```bash
cd signal-api
./link-device.sh
```

### Recipients still see my number?

- Have them restart Signal app
- Wait 5-10 minutes for sync
- Make sure they're connected to internet
- Try sending another message

---

## 📸 Add a Profile Picture Too!

Want to add a profile picture along with your name? We've got you covered!

### Quick Method:
```bash
cd signal-api
./set-profile-avatar.sh ~/Pictures/your-photo.jpg
```

### Set Everything at Once:
```bash
./set-full-profile.sh "Amatsu" "Gamer" "🎮" ~/Pictures/photo.jpg
```

This sets your name, status, emoji, AND profile picture in one command!

**For detailed instructions, see:** [signal-api/SET_PROFILE_PICTURE.md](signal-api/SET_PROFILE_PICTURE.md)

---

## 💡 Pro Tips

1. **Keep it short** - Long names get truncated on mobile (max ~25 chars)
2. **Use emojis wisely** - One or two emojis make your name memorable 
3. **Be consistent** - Use the same name across platforms
4. **Update for context** - Change your status based on availability
5. **Test it** - Send yourself a message to see how it looks
6. **Add a picture** - Profile pictures make your messages more recognizable 📸

---

## 🎯 Quick Reference Card

| Method | Command | Time |
|--------|---------|------|
| **Web UI** | Click "🎭 Set Profile Name" | 30 sec |
| **Script** | `./set-profile-name.sh Amatsu` | 10 sec |
| **cURL** | `curl -X PUT http://localhost:8080/v1/profiles/+40751770274 -H 'Content-Type: application/json' -d '{"name": "Amatsu"}'` | 15 sec |

---

## 📚 Related Documentation

- [SET_PROFILE_NAME.md](signal-api/SET_PROFILE_NAME.md) - Detailed profile guide
- [SET_PROFILE_PICTURE.md](signal-api/SET_PROFILE_PICTURE.md) - Add profile picture
- [API_REFERENCE.md](signal_documentation/API_REFERENCE.md) - Full API documentation
- [QUICK_COMMANDS.md](signal-poc/QUICK_COMMANDS.md) - Common commands

---

## 🎉 You're All Set!

Your profile name is now "Amatsu" (or whatever you chose). Every message you send will show this name instead of your phone number.

**Next steps:**
- Send a message to test it
- Add an emoji to make it unique
- Update your "about" status
- Add a profile picture (see above)
- Change it anytime you want!

Enjoy your personalized Signal experience! 🚀

