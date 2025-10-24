# Setting Your Signal Profile Picture (Avatar)

Complete guide to adding a profile picture to your Signal account in this project.

---

## 🎨 Why Set a Profile Picture?

A profile picture makes your messages more personal and recognizable:

**Without picture:**
```
Amatsu
Hey, how are you?
```

**With picture:**
```
[Your Picture] Amatsu
Hey, how are you?
```

---

## 🚀 Quick Methods

### Method 1: Using the Script (Easiest)

```bash
cd signal-api

# Set avatar only
./set-profile-avatar.sh ~/Pictures/my-photo.jpg

# Or set name + avatar together
./set-full-profile.sh "Amatsu" "" "" ~/Pictures/my-photo.jpg
```

### Method 2: Set Everything at Once

```bash
./set-full-profile.sh "Amatsu" "Available 24/7" "🎮" ~/Pictures/avatar.jpg
```

This sets:
- Name: Amatsu
- About: Available 24/7
- Emoji: 🎮
- Picture: your avatar.jpg

---

## 📋 Supported Image Formats

✅ **JPEG/JPG** - Most common, good compression  
✅ **PNG** - Supports transparency  
✅ **GIF** - Animated (first frame used)  
✅ **WebP** - Modern format, good compression  

**Recommended:**
- Format: JPEG or PNG
- Size: Under 1MB (max 5MB)
- Dimensions: 640x640 pixels (will be resized)
- Aspect ratio: Square (1:1)

---

## 📝 Detailed Instructions

### Step 1: Prepare Your Image

**Option A: Use an existing photo**
```bash
# Your photo location
~/Pictures/profile.jpg
~/Downloads/avatar.png
./my-photo.jpeg
```

**Option B: Resize/optimize your image first**

Using macOS Preview:
1. Open image in Preview
2. Tools → Adjust Size
3. Set width/height to 640 pixels
4. Check "Scale proportionally"
5. Save

Using command line (requires ImageMagick):
```bash
# Install ImageMagick
brew install imagemagick

# Resize image
convert input.jpg -resize 640x640 -quality 85 output.jpg
```

### Step 2: Set Your Profile Picture

```bash
cd signal-api

# Simple: Just the avatar
./set-profile-avatar.sh ~/Pictures/profile.jpg

# Complete profile
./set-full-profile.sh "Amatsu" "Gamer" "🎮" ~/Pictures/profile.jpg
```

### Step 3: Verify

Send a message and check on your phone or other devices. Your picture should appear!

---

## 🔧 Using cURL Directly

### Convert Image to Base64

```bash
# Convert image
base64 -i ~/Pictures/profile.jpg | tr -d '\n' > avatar-base64.txt

# Check file size (should be reasonable)
wc -c avatar-base64.txt
```

### Upload via API

```bash
# Read base64 content
AVATAR_BASE64=$(cat avatar-base64.txt)

# Upload
curl -X PUT \
  http://localhost:8080/v1/profiles/+40751770274 \
  -H 'Content-Type: application/json' \
  -d "{
    \"name\": \"Amatsu\",
    \"avatar\": \"$AVATAR_BASE64\"
  }"
```

---

## 💡 Tips for Great Profile Pictures

### ✅ Do:
- Use a clear, well-lit photo
- Center your face/subject
- Use high contrast
- Keep it simple
- Use square format (1:1 ratio)
- Compress to under 1MB

### ❌ Don't:
- Use blurry photos
- Upload huge files (>5MB)
- Use heavily filtered images
- Use wide/tall formats
- Upload inappropriate content

---

## 🎯 Common Use Cases

### Personal Profile
```bash
./set-full-profile.sh "Amatsu" "Gamer & Developer" "🎮" ~/Pictures/me.jpg
```

### Gaming Profile
```bash
./set-full-profile.sh "Amatsu" "Twitch Streamer" "🎮" ~/Pictures/gaming-avatar.png
```

### Professional Profile
```bash
./set-full-profile.sh "John Doe" "Sales Manager" "💼" ~/Pictures/professional.jpg
```

### Team/Bot Profile
```bash
./set-full-profile.sh "Support Bot" "24/7 Support" "🤖" ~/Pictures/logo.png
```

---

## 🔄 Change Your Picture

You can update your profile picture anytime:

```bash
# Just run the script again with a new image
./set-profile-avatar.sh ~/Pictures/new-photo.jpg
```

The old picture will be replaced with the new one.

---

## 🗑️ Remove Your Picture

To remove your profile picture:

```bash
curl -X PUT \
  http://localhost:8080/v1/profiles/+40751770274 \
  -H 'Content-Type: application/json' \
  -d '{
    "avatar": null
  }'
```

Or just upload a blank/default image.

---

## 🐛 Troubleshooting

### Error: "File not found"

Check the file path:
```bash
# List your files
ls -la ~/Pictures/

# Use absolute path
./set-profile-avatar.sh /Users/yourusername/Pictures/photo.jpg

# Or relative path from current directory
./set-profile-avatar.sh ./my-photo.jpg
```

### Error: "File too large"

Reduce file size:
```bash
# Check current size
ls -lh ~/Pictures/photo.jpg

# Resize with Preview (macOS) or use ImageMagick:
convert photo.jpg -resize 640x640 -quality 70 photo-small.jpg
```

### Picture not showing up?

1. **Wait a few minutes** - Updates can take 1-5 minutes to sync
2. **Check Signal API logs:**
   ```bash
   docker logs signal-api
   ```
3. **Verify image format:**
   ```bash
   file ~/Pictures/your-photo.jpg
   # Should show: JPEG image data or PNG image data
   ```
4. **Try a different image** - Some images may have compatibility issues

### Picture appears pixelated?

- Use higher quality source image
- Resize to exactly 640x640 before uploading
- Use JPEG quality 85-90
- Don't over-compress

---

## 📊 Image Size Guidelines

| Original Size | Action | Result |
|--------------|--------|--------|
| < 500 KB | ✅ Upload directly | Fast, good quality |
| 500 KB - 1 MB | ✅ Upload or compress | Good quality |
| 1 MB - 2 MB | ⚠️ Compress recommended | Slower upload |
| 2 MB - 5 MB | ⚠️ Compress required | Very slow |
| > 5 MB | ❌ Must compress | May fail |

**Compression commands:**
```bash
# JPEG - good compression
convert input.jpg -resize 640x640 -quality 75 output.jpg

# PNG - smaller file
convert input.png -resize 640x640 output.png
pngquant output.png --quality=70-85 --output compressed.png
```

---

## 🔒 Privacy & Security

**Your profile picture:**
- ✅ Is visible to all your Signal contacts
- ✅ Is encrypted in transit
- ✅ Is stored on Signal's servers (encrypted)
- ✅ Can be changed or removed anytime
- ❌ Is NOT public (only contacts see it)

**Best practices:**
- Don't use sensitive/private images
- Consider what all your contacts will see
- Update regularly if needed
- Remove if you don't want it anymore

---

## 📱 How It Looks

Your profile picture will appear:
- ✅ In message threads (next to your name)
- ✅ In group member lists
- ✅ In contact lists
- ✅ In notifications (on some devices)
- ✅ When you send messages

---

## 🎯 Quick Reference

```bash
# Avatar only
./set-profile-avatar.sh ~/Pictures/photo.jpg

# Name + avatar
./set-full-profile.sh "Amatsu" "" "" ~/Pictures/photo.jpg

# Everything
./set-full-profile.sh "Amatsu" "Available 24/7" "🎮" ~/Pictures/photo.jpg

# Check if it worked (send a test message and check your phone)
```

---

## 📚 Related Documentation

- [SET_PROFILE_NAME.md](SET_PROFILE_NAME.md) - Set your display name
- [PROFILE_NAME_GUIDE.md](../PROFILE_NAME_GUIDE.md) - Complete profile guide
- [API_REFERENCE.md](../signal_documentation/API_REFERENCE.md) - API documentation

---

## 💡 Pro Tips

1. **Test with small file first** - Try a 100KB image before larger ones
2. **Use square images** - Signal uses circular avatars, square works best
3. **Good lighting** - Well-lit photos look better in small sizes
4. **Simple backgrounds** - Plain backgrounds work better than busy ones
5. **Backup originals** - Keep your original high-res photos
6. **Update seasonally** - Some people change avatars for holidays/events

---

## ✅ Checklist

Before uploading:
- [ ] Image is in supported format (JPG, PNG, GIF, WebP)
- [ ] Image is under 1MB (ideally)
- [ ] Image is square or near-square
- [ ] Image is clear and well-lit
- [ ] Signal API is running (`docker ps | grep signal`)
- [ ] Your number is registered/linked

After uploading:
- [ ] Check logs for errors
- [ ] Wait 2-3 minutes for sync
- [ ] Send test message
- [ ] Verify on phone/other devices
- [ ] Confirm it looks good

---

## 🎉 You're All Set!

Your Signal profile now has a custom picture! Recipients will see your image next to "Amatsu" (or whatever name you chose) when you send messages.

**Next steps:**
- Send a message to see your new avatar
- Update it seasonally or as needed
- Set avatars for multiple accounts if you have them

Enjoy your personalized Signal profile! 📸✨

