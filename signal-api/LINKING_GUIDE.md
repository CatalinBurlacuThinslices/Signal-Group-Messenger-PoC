# Linking Your Existing Signal Account

Instead of registering a new number, you can link your existing Signal account (like Signal Desktop does).

## 🔗 Quick Link Process

### Step 1: Generate QR Code

```bash
cd /Users/thinslicesacademy8/projects/safe-poc/signal-api

# Make sure Signal API is running
docker-compose up -d

# Generate QR code
./link-device.sh
```

Or manually:
```bash
curl -X GET "http://localhost:8080/v1/qrcodelink?device_name=SignalPoC" > qr.png
open qr.png
```

### Step 2: Scan with Your Phone

1. **Open Signal app** on your phone
2. **Go to Settings** (tap your profile picture)
3. **Tap "Linked Devices"**
4. **Tap the "+" button** (or "Link New Device")
5. **Scan the QR code** displayed on your computer

### Step 3: Confirm on Phone

- Your phone will show "Link [device name]?"
- Tap "Link Device" or "Confirm"
- Wait a few seconds for synchronization

### Step 4: Verify It Worked

```bash
# Check if your number is registered
docker exec signal-api signal-cli -u YOUR_PHONE_NUMBER listGroups

# Or use the API
curl http://localhost:8080/v1/groups/YOUR_PHONE_NUMBER
```

## ✅ After Linking

You can now:
- ✅ Access all your existing groups
- ✅ Send messages to any group
- ✅ Use the web UI at http://localhost:3000
- ✅ Everything syncs with your phone

## 🔍 Finding Your Phone Number

Your Signal phone number is shown in:
- Signal app → Settings → Account
- It's the number you registered Signal with

Update this in:
```bash
# Edit backend/.env
cd /Users/thinslicesacademy8/projects/safe-poc/signal-poc/backend
nano .env

# Set:
SIGNAL_NUMBER=+40751770274  # Your actual Signal number
```

## 🐛 Troubleshooting

### QR code not generating

```bash
# Check Signal API is running
docker ps | grep signal

# Check logs
docker logs signal-api

# Restart if needed
docker-compose restart
```

### Phone can't scan QR code

- Make sure QR code image is large and clear
- Try regenerating: `./link-device.sh`
- Ensure good lighting when scanning
- Hold phone steady

### Linking fails

- Make sure Signal app is updated
- Try closing and reopening Signal app
- Generate fresh QR code (they expire quickly)
- Check internet connection on phone

### "Device already linked" error

```bash
# List linked devices
docker exec signal-api signal-cli -u YOUR_NUMBER listDevices

# Unlink old devices if needed (careful!)
docker exec signal-api signal-cli -u YOUR_NUMBER removeDevice -d DEVICE_ID
```

## 📝 Notes

**Important:**
- QR codes expire after ~60 seconds - scan quickly!
- You can link up to 5 devices per Signal account
- Linking is one-way - unlink from phone if needed
- All messages sync with your phone

**Your phone remains the primary device:**
- If you uninstall Signal from phone, linked devices stop working
- Linked devices can't make voice/video calls
- Some features may be limited compared to phone app

## 🎯 Next Steps

After successful linking:

1. **Verify in web UI:**
   - Open http://localhost:3000
   - Status should show "Signal API: connected" 🟢
   - Your groups should appear

2. **Test sending a message:**
   - Select a group
   - Type a message
   - Click "Send Message"
   - Check your phone to confirm it arrived

3. **Enjoy!** 🎉
   You can now send Signal messages from the web interface!

