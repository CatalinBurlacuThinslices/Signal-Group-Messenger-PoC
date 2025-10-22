# What's New - Broadcast Feature

## 🎉 New Features Added

### 1. Web Interface - Broadcast to Phone Numbers

The web app now has **two modes**:
- **👥 Send to Group** (original feature)
- **📞 Send to Phone Numbers** (NEW!)

### 2. Backend API - Broadcast Endpoint

New endpoint: `POST /api/broadcast`
- Send the same message to multiple phone numbers
- Support for comma, space, or newline-separated numbers
- Auto-formatting of phone numbers

### 3. Command Line Scripts

Two new scripts for broadcasting:
- `broadcast.sh` - Shell script
- `broadcast.js` - Node.js script

## Quick Start

### Use the Web Interface

1. **Start backend** (if not running):
   ```bash
   cd signal-poc/backend
   node server.js &
   ```

2. **Start frontend** (if not running):
   ```bash
   cd signal-poc/frontend
   npm run dev
   ```

3. **Open browser**: http://localhost:5173

4. **Click the "📞 Send to Phone Numbers" tab**

5. **Enter phone numbers** (one per line or comma-separated):
   ```
   +40751770274
   +12025551234
   +447700900123
   ```

6. **Type your message** and click "📤 Broadcast Message"

### Use the Command Line

```bash
cd signal-poc

# Send to multiple people
./broadcast.sh "+40751770274,+12025551234" "Hello everyone!"

# OR use Node.js
node broadcast.js "+40751770274,+12025551234" "Hello team!"
```

## Files Added/Modified

### ✅ Backend
- **Modified**: `backend/server.js` - Added `/api/broadcast` endpoint

### ✅ Frontend  
- **Modified**: `frontend/src/App.jsx` - Added broadcast UI with tab toggle
- **Modified**: `frontend/src/App.css` - Added styles for new UI elements

### ✅ Scripts
- **New**: `broadcast.sh` - Shell script for broadcasting
- **New**: `broadcast.js` - Node.js script for broadcasting
- **New**: `send-to-phone.sh` - Shell script for single phone
- **New**: `send-to-phone.js` - Node.js script for single phone

### ✅ Documentation
- **New**: `BROADCAST_GUIDE.md` - Complete broadcast guide
- **New**: `SEND_TO_PHONE_GUIDE.md` - Single phone message guide
- **New**: `WEB_BROADCAST_GUIDE.md` - Web interface guide
- **New**: `MESSAGING_SUMMARY.md` - Overview of all options
- **New**: `QUICK_COMMANDS.md` - Quick reference
- **New**: `WHATS_NEW.md` - This file

## Key Features

### Web Interface
✅ **Tab Toggle**: Switch between "Send to Group" and "Send to Phone Numbers"  
✅ **Smart Input**: Accepts comma, space, or newline-separated phone numbers  
✅ **Real-time Count**: Shows how many recipients as you type  
✅ **Reuses Message Field**: Same textarea for both modes  
✅ **Validation**: Real-time validation with helpful error messages  
✅ **Success Feedback**: Clear confirmation after sending  

### Command Line
✅ **Two Scripts**: Shell and Node.js versions  
✅ **Flexible Input**: Support for comma or space-separated numbers  
✅ **Error Handling**: Clear error messages  
✅ **Success Output**: Shows recipient count and timestamp  

### Backend API
✅ **New Endpoint**: `POST /api/broadcast`  
✅ **Array Support**: Accepts array of phone numbers  
✅ **Auto-format**: Automatically adds `+` if missing  
✅ **Validation**: Validates phone numbers and message  
✅ **Error Handling**: Detailed error messages and hints  

## Phone Number Format

**Required Format**: `+[country code][number]`

Examples:
- ✅ `+40751770274` (Romania)
- ✅ `+12025551234` (USA)
- ✅ `+447700900123` (UK)
- ❌ `40751770274` (missing +)
- ❌ `0751770274` (missing country code)

## API Endpoint

### Request
```bash
POST http://localhost:5001/api/broadcast
Content-Type: application/json

{
  "phoneNumbers": ["+40751770274", "+12025551234"],
  "message": "Your message here"
}
```

### Success Response
```json
{
  "success": true,
  "message": "Message broadcast to 2 recipients",
  "timestamp": "1761121081823",
  "recipients": ["+40751770274", "+12025551234"],
  "recipientCount": 2,
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "error": "Failed to broadcast message",
  "details": "Error details",
  "hint": "Helpful hint"
}
```

## Use Cases

### 1. Quick Team Notifications
Web UI: Enter team phone numbers → Type message → Send

### 2. Event Reminders  
Script: `./broadcast.sh "+NUM1,+NUM2" "Event at 7pm"`

### 3. Status Updates
Web UI: Toggle to phone mode → Enter numbers → Update message

### 4. Automated Alerts
Script in cron or CI/CD: `node broadcast.js "$NUMBERS" "$ALERT"`

## Testing

### Test Web Interface
1. Open http://localhost:5173
2. Click "📞 Send to Phone Numbers"
3. Enter your own number: `+YOUR_NUMBER`
4. Type "Test message"
5. Click "Broadcast Message"
6. Check your phone!

### Test Command Line
```bash
cd signal-poc
./broadcast.sh "+YOUR_NUMBER" "Test from command line"
```

### Test API Directly
```bash
curl -X POST http://localhost:5001/api/broadcast \
  -H "Content-Type: application/json" \
  -d '{
    "phoneNumbers": ["+YOUR_NUMBER"],
    "message": "Test from API"
  }'
```

## Comparison

| Feature | Web Interface | Scripts | Original (Groups) |
|---------|---------------|---------|-------------------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Recipients** | Multiple phones | Multiple phones | Group members |
| **Input Method** | Text field | Command args | Dropdown select |
| **Automation** | Manual | Good | Manual |
| **Visual Feedback** | Yes | Terminal | Yes |

## What's NOT Changed

✅ Original group messaging works exactly the same  
✅ All existing endpoints unchanged  
✅ No breaking changes  
✅ Backward compatible  

## Troubleshooting

### Backend Not Starting
```bash
# Check if port 5001 is in use
lsof -i :5001

# Kill old process if needed
pkill -f "node.*server.js"

# Start fresh
cd signal-poc/backend
node server.js
```

### Broadcast Endpoint Not Found
**Issue**: "Cannot POST /api/broadcast"  
**Solution**: Restart the backend server to load the new code

### Frontend Not Showing New Tab
**Issue**: Don't see "Send to Phone Numbers" tab  
**Solution**: 
1. Make sure frontend is rebuilt
2. Hard refresh browser (Cmd+Shift+R / Ctrl+Shift+R)
3. Clear browser cache

## Documentation

For detailed guides, see:
- `WEB_BROADCAST_GUIDE.md` - Web interface guide
- `BROADCAST_GUIDE.md` - Complete broadcast documentation
- `SEND_TO_PHONE_GUIDE.md` - Single phone message guide
- `MESSAGING_SUMMARY.md` - Overview of all messaging options
- `QUICK_COMMANDS.md` - Quick command reference

## Summary

You now have **3 ways to send Signal messages**:

1. **Web UI → Groups**
   - Select group from your list
   - Type message
   - Send

2. **Web UI → Phone Numbers** ⭐ NEW!
   - Click "📞 Send to Phone Numbers" tab
   - Enter phone numbers
   - Type message
   - Broadcast

3. **Command Line Scripts** ⭐ NEW!
   - `./broadcast.sh "+NUM1,+NUM2" "Message"`
   - `node broadcast.js "+NUM1,+NUM2" "Message"`

Choose the method that works best for you!

---

**Ready to try it?**

```bash
# Start backend (if needed)
cd signal-poc/backend
node server.js &

# Open web interface
# Go to http://localhost:5173
# Click "📞 Send to Phone Numbers"
# Enter phone numbers
# Send message!
```

🎉 **Enjoy your new broadcast feature!**

