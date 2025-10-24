# 🎭 Complete Profile Setup Guide

Set your Signal profile with **name**, **status**, **emoji**, AND **profile picture**!

---

## ⚡ Quick Start (Choose One)

### Option 1: Just Your Name
```bash
cd signal-api
./set-profile-name.sh "Amatsu"
```

### Option 2: Just Your Picture
```bash
cd signal-api
./set-profile-avatar.sh ~/Pictures/your-photo.jpg
```

### Option 3: Everything at Once! ⭐
```bash
cd signal-api
./set-full-profile.sh "Amatsu" "Gamer & Developer" "🎮" ~/Pictures/photo.jpg
```

---

## 📋 What You Can Set

| Field | Required | Example | Command |
|-------|----------|---------|---------|
| **Name** | ✅ Yes | Amatsu | `./set-profile-name.sh "Amatsu"` |
| **About** | ❌ Optional | "Available 24/7" | Use full-profile script |
| **Emoji** | ❌ Optional | 🎮 | Use full-profile script |
| **Picture** | ❌ Optional | photo.jpg | `./set-profile-avatar.sh photo.jpg` |

---

## 🎯 Examples

### Minimal (Name Only)
```bash
./set-profile-name.sh "Amatsu"
```
**Result:** `Amatsu` appears in messages

### With Emoji
```bash
./set-profile-name.sh "Amatsu 🎮"
```
**Result:** `Amatsu 🎮` appears in messages

### With Picture
```bash
./set-profile-name.sh "Amatsu"
./set-profile-avatar.sh ~/Pictures/gaming-avatar.png
```
**Result:** `[Your Picture] Amatsu` appears in messages

### Complete Profile
```bash
./set-full-profile.sh "Amatsu" "Twitch Streamer" "🎮" ~/Pictures/avatar.jpg
```
**Result:** 
```
[Your Picture] Amatsu 🎮
Twitch Streamer
```

---

## 🖼️ Profile Picture Tips

### Recommended Image Specs:
- **Format:** JPEG or PNG
- **Size:** Under 1MB (max 5MB)
- **Dimensions:** 640x640 pixels
- **Aspect Ratio:** Square (1:1)

### Quick Image Optimization:
```bash
# Install ImageMagick (if needed)
brew install imagemagick

# Resize and optimize
convert large-photo.jpg -resize 640x640 -quality 85 optimized.jpg

# Then upload
./set-profile-avatar.sh optimized.jpg
```

---

## 📱 What Recipients See

### Before Setting Profile:
```
+40751770274
Hey there!
```

### After Setting Name:
```
Amatsu
Hey there!
```

### After Adding Picture:
```
[Your Avatar] Amatsu
Hey there!
```

### Complete Profile:
```
[Your Avatar] Amatsu 🎮
Hey there!

Status: Twitch Streamer
```

---

## 🔧 All Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `set-profile-name.sh` | Set display name | `./set-profile-name.sh "Name"` |
| `set-profile-avatar.sh` | Set profile picture | `./set-profile-avatar.sh photo.jpg` |
| `set-full-profile.sh` | Set everything | `./set-full-profile.sh "Name" "About" "Emoji" photo.jpg` |

---

## 💻 Using the Web Interface

Don't like command line? Use the web UI!

1. Open: **http://localhost:3000**
2. Click: **"🎭 Set Profile Name"** button
3. Fill in:
   - Display Name: `Amatsu`
   - About: `Available 24/7` (optional)
   - Emoji: `🌟` (optional)
4. Click: **"Save Profile"**

**Note:** Profile picture upload in web UI coming soon! For now, use the scripts.

---

## 🎨 Profile Examples by Use Case

### Personal/Gaming
```bash
./set-full-profile.sh "Amatsu" "Gamer" "🎮" ~/Pictures/gaming.jpg
```

### Professional
```bash
./set-full-profile.sh "John Smith" "Sales Manager" "💼" ~/Pictures/headshot.jpg
```

### Support/Bot
```bash
./set-full-profile.sh "Support Bot" "24/7 Assistance" "🤖" ~/Pictures/logo.png
```

### Content Creator
```bash
./set-full-profile.sh "Amatsu" "Twitch Streamer" "📺" ~/Pictures/avatar.png
```

### Casual
```bash
./set-full-profile.sh "Amatsu" "" "😎" ~/Pictures/selfie.jpg
```

---

## 🔄 Updating Your Profile

### Change Just Your Name:
```bash
./set-profile-name.sh "New Name"
```
*Picture and status remain unchanged*

### Change Just Your Picture:
```bash
./set-profile-avatar.sh ~/Pictures/new-photo.jpg
```
*Name and status remain unchanged*

### Change Everything:
```bash
./set-full-profile.sh "New Name" "New Status" "🌟" ~/Pictures/new-pic.jpg
```
*Everything updates*

---

## ✅ Verification Checklist

After setting your profile:

- [ ] Wait 1-2 minutes for sync
- [ ] Send a test message to any contact
- [ ] Check on your phone/other devices
- [ ] Verify name appears correctly
- [ ] Verify picture shows up (if set)
- [ ] Confirm emoji displays (if set)

---

## 🐛 Common Issues

### Profile not updating?

**Check Signal API:**
```bash
docker ps | grep signal
# Should show signal-api running
```

**Restart if needed:**
```bash
cd signal-api
docker-compose restart
```

### Picture too large?

**Compress it:**
```bash
# Reduce quality
convert photo.jpg -quality 75 -resize 640x640 compressed.jpg
./set-profile-avatar.sh compressed.jpg
```

### Name contains quotes or special characters?

**Escape them:**
```bash
./set-profile-name.sh "Amatsu \"The Gamer\""
./set-profile-name.sh 'Amatsu & Friends'
```

---

## 📚 Documentation

| Document | Purpose | Time to Read |
|----------|---------|--------------|
| **SET_PROFILE_COMPLETE.md** | This guide - complete overview | 5 min |
| **QUICK_SET_NAME.md** | Quick name setup | 1 min |
| **PROFILE_NAME_GUIDE.md** | Detailed name guide | 10 min |
| **SET_PROFILE_NAME.md** | Technical name docs | 10 min |
| **SET_PROFILE_PICTURE.md** | Detailed picture guide | 15 min |

---

## 🎯 Quick Reference

```bash
# Navigate to scripts
cd signal-api

# Name only
./set-profile-name.sh "Amatsu"

# Picture only
./set-profile-avatar.sh ~/Pictures/photo.jpg

# Everything
./set-full-profile.sh "Amatsu" "Gamer" "🎮" ~/Pictures/photo.jpg

# Verify (check docker logs)
docker logs signal-api | tail -20
```

---

## 💡 Pro Tips

1. **Start simple** - Set your name first, add picture later
2. **Test images** - Try a small file first (< 500KB)
3. **Square photos** - Work best for circular avatars
4. **Keep names short** - Under 25 characters display better
5. **Update seasonally** - Change picture for holidays/events
6. **Be consistent** - Use same name across all platforms
7. **Compress images** - Smaller files upload faster
8. **Good lighting** - Well-lit photos look better small

---

## 🚀 Try It Now!

**Quick 2-Minute Setup:**

```bash
# 1. Go to signal-api directory
cd /Users/thinslicesacademy8/projects/Signal_PoC/signal-api

# 2. Set your complete profile
./set-full-profile.sh "Amatsu" "Gamer" "🎮" ~/Pictures/your-photo.jpg

# 3. Send a test message and check your phone!
```

---

## 📊 What This Feature Includes

### Scripts (3):
- ✅ `set-profile-name.sh` - Name only
- ✅ `set-profile-avatar.sh` - Picture only  
- ✅ `set-full-profile.sh` - Complete profile

### Documentation (5):
- ✅ Complete guides
- ✅ Quick references
- ✅ Troubleshooting
- ✅ Examples
- ✅ Best practices

### Features:
- ✅ Set display name
- ✅ Set status message
- ✅ Set emoji
- ✅ Set profile picture
- ✅ Update anytime
- ✅ Remove/change easily

---

## 🎉 You're Ready!

You now have everything you need to create a complete, personalized Signal profile:

✅ **Display Name** - Show "Amatsu" instead of phone number  
✅ **Status Message** - Let people know your availability  
✅ **Emoji** - Add personality to your profile  
✅ **Profile Picture** - Be recognizable in messages  

**Ready to set it up?**
```bash
cd signal-api
./set-full-profile.sh "Amatsu" "Available 24/7" "🎮" ~/Pictures/avatar.jpg
```

Enjoy your fully personalized Signal profile! 🎭📸✨

