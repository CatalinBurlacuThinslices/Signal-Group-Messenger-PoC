# 📸 Web UI Profile Picture Upload - Complete Guide

## ✨ What's New

You can now **upload profile pictures directly from the web interface**! No need to use command line scripts anymore. 🎉

---

## 🚀 Quick Start

### Step 1: Open the Web App
```
http://localhost:3000
```

### Step 2: Click "Set Profile Name" Button
Look for the **"🎭 Set Profile Name"** button in the top header bar.

### Step 3: Fill in Your Profile
The modal now includes:
- ✅ **Display Name** (required) - e.g., "Amatsu"
- ✅ **About** (optional) - e.g., "Available 24/7"
- ✅ **Emoji** (optional) - e.g., "🎮"
- ✅ **Profile Picture** (optional) - Upload your image! 📸

### Step 4: Upload Your Picture
1. Click "Choose File" button
2. Select an image from your computer
3. See instant preview
4. Click "Save Profile"

### Step 5: Done!
Your profile (name + picture) is now set! 🎊

---

## 🎯 Features

### Real-Time Preview
- ✅ See your profile picture immediately after selecting
- ✅ Preview shows exactly how it will look
- ✅ Preview includes your name, emoji, and about text
- ✅ Circular avatar preview (just like in Signal)

### File Validation
- ✅ Automatic file size check (max 5MB)
- ✅ File type validation (JPEG, PNG, GIF, WebP)
- ✅ Clear error messages if something's wrong
- ✅ Helpful hints for best results

### Easy Management
- ✅ Remove button to clear selected image
- ✅ Re-upload to change your picture
- ✅ Update name without changing picture
- ✅ Update picture without changing name

---

## 📸 Supported Image Formats

✅ **JPEG/JPG** - Best for photos  
✅ **PNG** - Supports transparency  
✅ **GIF** - Animated (first frame used)  
✅ **WebP** - Modern format  

**Recommended:**
- Size: Under 1MB (max 5MB)
- Dimensions: 640x640 pixels
- Aspect ratio: Square (1:1)

---

## 💡 Tips for Best Results

### Image Quality
1. **Use clear, well-lit photos**
2. **Square format works best** (1:1 ratio)
3. **Keep file size under 1MB** for faster uploads
4. **Simple backgrounds** look better in small sizes

### Before Uploading
```
✅ Good lighting
✅ Centered subject
✅ High contrast
✅ Square crop
✅ Compressed file
```

### Optimization (Optional)
If your image is too large, resize it first:
- macOS Preview: Tools → Adjust Size → 640x640
- Online: Use [Squoosh.app](https://squoosh.app) or [TinyPNG.com](https://tinypng.com)

---

## 🎨 Example Profiles

### Gaming Profile
```
Name: Amatsu
About: Twitch Streamer
Emoji: 🎮
Picture: Your gaming avatar
```

### Professional Profile
```
Name: John Smith
About: Sales Manager
Emoji: 💼
Picture: Professional headshot
```

### Personal Profile
```
Name: Amatsu
About: Available 24/7
Emoji: 😎
Picture: Your favorite photo
```

---

## 📱 What Recipients See

After uploading, recipients will see:

```
[Your Picture] Amatsu 🎮
Hey there!

Status: Available 24/7
```

Your profile appears:
- ✅ In message threads
- ✅ In group member lists
- ✅ In contact lists
- ✅ In notifications

---

## 🔄 How to Update Your Profile

### Change Picture Only:
1. Click "🎭 Set Profile Name"
2. Enter your existing name
3. Upload new picture
4. Save

### Change Name Only:
1. Click "🎭 Set Profile Name"
2. Enter new name
3. Don't upload picture
4. Save (existing picture remains)

### Change Everything:
1. Click "🎭 Set Profile Name"
2. Update all fields
3. Upload new picture
4. Save

---

## ✅ Step-by-Step Example

Let's set up a complete profile:

### 1. Open Web App
```
http://localhost:3000
```

### 2. Click Profile Button
Click **"🎭 Set Profile Name"** in the header

### 3. Fill in Details
- Display Name: `Amatsu`
- About: `Gamer & Developer`
- Emoji: `🎮`

### 4. Upload Picture
- Click "Choose File"
- Select: `~/Pictures/gaming-avatar.jpg`
- See preview appear ✨

### 5. Review Preview
Check the preview box shows:
- Your picture (circular)
- Name: "Amatsu 🎮"
- Status: "Gamer & Developer"

### 6. Save
Click **"💾 Save Profile"**

### 7. Success!
See: "✅ Profile updated successfully!"

### 8. Test
Send a message and check your phone - your picture and name appear! 🎉

---

## 🐛 Troubleshooting

### "Image is too large"

**Problem:** File over 5MB

**Solutions:**
```bash
# Option 1: Use online tool
Visit squoosh.app → Upload → Compress → Download

# Option 2: Use Preview (macOS)
Open in Preview → Tools → Adjust Size → Set to 640x640

# Option 3: Use command line
brew install imagemagick
convert large.jpg -resize 640x640 -quality 75 small.jpg
```

### "Please select an image file"

**Problem:** Wrong file type

**Solution:** Use JPEG, PNG, GIF, or WebP files only

### Image not showing in preview?

**Check:**
1. File is valid image format
2. File isn't corrupted
3. Browser has permissions
4. Try different image

### Upload seems stuck?

**Try:**
1. Wait a moment (large files take time)
2. Check Signal API is running: `docker ps | grep signal`
3. Check browser console for errors (F12)
4. Try smaller image

### Picture appears blurry?

**Fix:**
1. Use higher resolution source (at least 640x640)
2. Don't over-compress
3. Use good lighting
4. Try PNG instead of JPEG

---

## 🔒 Privacy & Security

### Your Profile Picture:
- ✅ Encrypted during upload
- ✅ Stored securely on Signal servers
- ✅ Only visible to your contacts
- ✅ Can be changed anytime
- ✅ Can be removed anytime

### What Happens:
1. You select image in browser
2. Converted to base64 locally
3. Sent encrypted to Signal API
4. Signal optimizes and stores
5. Syncs to all your devices
6. Recipients download optimized version

---

## 💻 Technical Details

### How It Works:

```
User selects image
    ↓
Browser reads file
    ↓
Validates size/type
    ↓
Converts to base64
    ↓
Shows preview
    ↓
User clicks save
    ↓
Sends to backend (/api/profile)
    ↓
Backend sends to Signal API
    ↓
Signal processes and stores
    ↓
Syncs to devices
```

### File Processing:

```javascript
// Browser converts image to base64
FileReader → base64 string

// Sent to backend
POST /api/profile
{ avatar: "base64data..." }

// Backend forwards to Signal
PUT /v1/profiles/{number}
{ avatar: "base64data..." }
```

---

## 📊 Size Guidelines

| Original Size | Status | Action |
|--------------|--------|--------|
| < 500 KB | ✅ Perfect | Upload directly |
| 500 KB - 1 MB | ✅ Good | Upload or compress |
| 1 MB - 2 MB | ⚠️ Large | Compress recommended |
| 2 MB - 5 MB | ⚠️ Very Large | Must compress |
| > 5 MB | ❌ Too Large | Cannot upload |

---

## 🎯 Quick Reference

### To Set Complete Profile:
1. Open http://localhost:3000
2. Click "🎭 Set Profile Name"
3. Enter name (required)
4. Enter about/emoji (optional)
5. Click "Choose File"
6. Select image
7. Review preview
8. Click "Save Profile"
9. Done! ✅

### To Remove Picture:
1. Open profile modal
2. Upload new picture (shows preview)
3. Click "✕ Remove" button
4. Picture cleared
5. Can upload different one or save without

---

## 🆚 Web UI vs Command Line

### Web UI (This Feature) ⭐
```
✅ Visual interface
✅ Instant preview
✅ Drag and drop support
✅ File validation
✅ Easy for everyone
✅ No terminal needed
```

### Command Line
```
✅ Faster for power users
✅ Good for automation
✅ Works remotely (SSH)
✅ Script integration
```

**Recommendation:** Use Web UI for interactive updates, command line for scripts/automation.

---

## 📚 Related Documentation

- [SET_PROFILE_COMPLETE.md](SET_PROFILE_COMPLETE.md) - Complete profile guide
- [SET_PROFILE_PICTURE.md](signal-api/SET_PROFILE_PICTURE.md) - Command line method
- [AVATAR_FEATURE_SUMMARY.md](AVATAR_FEATURE_SUMMARY.md) - Technical overview

---

## 🎉 Summary

You can now set your **complete Signal profile** directly from the web interface:

✅ **Display name** - "Amatsu"  
✅ **Profile picture** - Your photo  
✅ **Status message** - "Available 24/7"  
✅ **Emoji** - 🎮  

**All from your browser, no command line needed!**

---

## 💡 Pro Tips

1. **Test with small image first** - Make sure everything works
2. **Use square images** - They look best in circular frames
3. **Good lighting matters** - Photos show better when well-lit
4. **Keep it simple** - Simple backgrounds work best at small sizes
5. **Update regularly** - Keep your profile fresh
6. **Check preview** - Make sure it looks good before saving

---

## 🚀 Try It Now!

```
1. Open: http://localhost:3000
2. Click: "🎭 Set Profile Name"
3. Fill in: Name, about, emoji
4. Upload: Your picture
5. Save: Click save button
6. Done! 🎊
```

Your complete profile with picture is now active! Send a message and see it in action! 📸✨

---

**Enjoy your personalized Signal experience! 🎭📱🎉**

