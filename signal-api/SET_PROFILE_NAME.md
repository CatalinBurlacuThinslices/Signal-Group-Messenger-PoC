# Setting Your Signal Profile Name

Change the display name that appears when you send Signal messages.

---

## 🎭 Why Set a Profile Name?

When you send messages, recipients will see your profile name instead of just your phone number. This makes your messages more personal and professional.

**Example:**
- Without profile name: "+40751770274"
- With profile name: "Amatsu" ✨

---

## 🚀 Quick Setup

### Method 1: Using the Script (Easiest)

```bash
cd signal-api

# Set name to "Amatsu"
./set-profile-name.sh Amatsu

# Or any other name
./set-profile-name.sh "Your Name Here"
```

That's it! Your name is now set.

---

### Method 2: Using cURL Directly

```bash
curl -X PUT \
  http://localhost:8080/v1/profiles/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Amatsu"
  }'
```

---

### Method 3: Set Profile with More Details

You can also set additional profile information:

```bash
curl -X PUT \
  http://localhost:8080/v1/profiles/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Amatsu",
    "about": "Available 24/7",
    "emoji": "🌟"
  }'
```

**Available fields:**
- `name` - Your display name (required)
- `about` - Status message/bio
- `emoji` - Emoji that appears with your status
- `avatar` - Profile picture (base64 encoded image)

---

## 📝 Examples

### Set Simple Name
```bash
./set-profile-name.sh "Amatsu"
```

### Set Professional Name
```bash
./set-profile-name.sh "Support Team"
```

### Set with Emoji
```bash
curl -X PUT \
  http://localhost:8080/v1/profiles/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "name": "Amatsu 🎮",
    "about": "Gamer & Developer",
    "emoji": "🎮"
  }'
```

---

## ✅ Verify It Worked

After setting your name:

1. Send a test message to any Signal contact or group
2. They will see your new name instead of your phone number
3. The change may take a few moments to sync

**Note:** Recipients need to be connected to the internet for the name to update.

---

## 🔄 Change Your Name Anytime

You can change your name as many times as you want:

```bash
# Morning
./set-profile-name.sh "Amatsu (Available)"

# Evening
./set-profile-name.sh "Amatsu (Away)"

# Weekend
./set-profile-name.sh "Amatsu (Off Duty)"
```

---

## 🐛 Troubleshooting

### Profile name not updating

**Check Signal API is running:**
```bash
docker ps | grep signal
```

**Restart Signal API:**
```bash
cd signal-api
docker-compose restart
```

### Recipients still see my phone number

- Wait 5-10 minutes for sync
- Have recipients restart Signal app
- Make sure they have internet connection

### Error: "Number not registered"

Your Signal number needs to be registered or linked first:
```bash
# Check if linked
docker exec signal-api signal-cli -a +40751770274 listGroups

# If not, link your device
./link-device.sh
```

---

## 📱 Update Profile Picture

To set a profile picture (avatar):

1. Convert your image to base64:
```bash
base64 -i your-picture.jpg | tr -d '\n' > avatar.txt
```

2. Set profile with avatar:
```bash
AVATAR_BASE64=$(cat avatar.txt)
curl -X PUT \
  http://localhost:8080/v1/profiles/+40751770274 \
  -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"Amatsu\",
    \"avatar\": \"$AVATAR_BASE64\"
  }"
```

---

## 💡 Pro Tips

1. **Keep it short** - Long names get truncated on mobile
2. **Use emojis** - Makes your messages stand out 🌟
3. **Match your brand** - Use your business or project name
4. **Update status** - Change your "about" to show availability
5. **Professional context** - Use formal names for business use

---

## 🎯 Quick Reference

```bash
# Set name to Amatsu
./set-profile-name.sh Amatsu

# Set custom name
./set-profile-name.sh "Your Name"

# Set full profile
curl -X PUT http://localhost:8080/v1/profiles/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{"name": "Amatsu", "about": "Developer", "emoji": "💻"}'
```

---

## 🔗 Related Guides

- [Quick Commands](QUICK_COMMANDS.md) - Common Signal API commands
- [Linking Guide](LINKING_GUIDE.md) - Link your Signal account
- [API Reference](../signal_documentation/API_REFERENCE.md) - Full API documentation

---

**Ready to set your name?**

```bash
cd signal-api
./set-profile-name.sh Amatsu
```

Then send a message and see your new name in action! 🎉

