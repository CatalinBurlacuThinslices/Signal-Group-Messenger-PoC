# Network Setup for Signal Device Linking

## The Problem

When linking a Signal device, your phone needs to communicate with the Signal API running on your computer. If it's only accessible via `localhost`, the linking will fail with a network error.

## The Solution

### Your Computer's Network Info

**Local IP Address:** 192.168.0.66

The Signal API is now accessible on your local network at:
- `http://localhost:8080` (from your computer)
- `http://192.168.0.66:8080` (from other devices on your network)

### Requirements for Successful Linking

1. ✅ **Same WiFi Network**
   - Your phone and computer MUST be on the same WiFi network
   - Won't work if phone is on cellular data

2. ✅ **Firewall Settings**
   - macOS Firewall might block incoming connections
   - Check: System Preferences → Security & Privacy → Firewall
   - Either disable temporarily or allow incoming connections

3. ✅ **Signal API Accessibility**
   - The API is now bound to `0.0.0.0:8080` (accessible from network)
   - Test from your phone's browser: http://192.168.0.66:8080/v1/health

## Testing Network Access

### From Your Computer:
```bash
curl http://localhost:8080/v1/health
# Should return: {"status":"ok"}
```

### From Your Phone:
Open Safari/Chrome on your phone and visit:
```
http://192.168.0.66:8080/v1/health
```

If you see `{"status":"ok"}`, the network connection works! ✅

## Steps to Link Device

1. **Ensure both devices are on the same WiFi** 📶
   - Phone: Settings → WiFi → Check network name
   - Computer: WiFi icon → Check network name
   - They MUST match!

2. **Generate new QR code** in the web app
   - Click "📱 Link Device" button
   - Or run: `./link-device.sh`

3. **Scan with Signal app**
   - Signal → Settings → Linked Devices → +
   - Scan the QR code
   - Should work now!

## Troubleshooting

### Still Getting Network Error?

**Check macOS Firewall:**
```bash
# Check firewall status
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# Temporarily disable (for testing)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off

# Re-enable after linking
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```

**Test from phone manually:**
1. Open browser on phone
2. Visit: `http://192.168.0.66:8080/v1/health`
3. Should see: `{"status":"ok"}`
4. If not, firewall is blocking it

**Check Docker container:**
```bash
docker ps | grep signal-api
# Should show: 0.0.0.0:8080->8080/tcp
```

### Phone Can't Reach Computer?

**Option 1: Check Router Settings**
- Some routers have "AP Isolation" or "Client Isolation" enabled
- This prevents devices from talking to each other
- Disable in router settings

**Option 2: Use USB Tethering (Advanced)**
- Connect phone to computer via USB
- Enable USB tethering on phone
- Computer will get a new network interface
- Find new IP: `ifconfig` and look for interface like `en5` or similar

**Option 3: Temporary Hotspot**
- Create hotspot from your computer
- Connect phone to computer's hotspot
- Then try linking

## After Successful Linking

Once linked, you can:
- Close the firewall again (if you opened it)
- Use the web app normally
- The phone doesn't need constant network access to the API
- Only needed during initial linking

## Security Note

The Signal API is now accessible on your local network. This is safe for:
- Home WiFi networks
- Trusted networks

But DON'T do this on:
- Public WiFi (coffee shops, airports)
- Untrusted networks
- If concerned, re-enable firewall after linking

